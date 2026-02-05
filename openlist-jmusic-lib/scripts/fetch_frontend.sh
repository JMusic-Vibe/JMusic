#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

require_cmd curl
require_cmd tar

ensure_dir "$ROOT_DIR/frontends"
ensure_dir "$FRONTEND_CACHE_DIR"

fetch_release_info() {
  local attempt=1
  local max_attempts=3
  local api_url="https://api.github.com/repos/${FRONTEND_REPO}/releases/latest"
  local proxy_url="https://ghproxy.lvedong.eu.org/${api_url}"

  while [ $attempt -le $max_attempts ]; do
    RELEASE_INFO=$(curl -fsSL --max-time 10 -H "Accept: application/vnd.github.v3+json" "$api_url" 2>/dev/null || true)
    if [ -n "$RELEASE_INFO" ]; then
      return 0
    fi
    attempt=$((attempt + 1))
    sleep 2
  done

  attempt=1
  while [ $attempt -le $max_attempts ]; do
    RELEASE_INFO=$(curl -fsSL --max-time 15 -H "Accept: application/vnd.github.v3+json" "$proxy_url" 2>/dev/null || true)
    if [ -n "$RELEASE_INFO" ]; then
      return 0
    fi
    attempt=$((attempt + 1))
    sleep 3
  done

  return 1
}

fetch_assets_info() {
  local assets_url="$1"
  local attempt=1
  local max_attempts=3
  local proxy_assets_url="https://ghproxy.lvedong.eu.org/${assets_url}"

  while [ $attempt -le $max_attempts ]; do
    ASSETS_INFO=$(curl -fsSL --max-time 10 -H "Accept: application/vnd.github.v3+json" "$assets_url" 2>/dev/null || true)
    if [ -n "$ASSETS_INFO" ]; then
      return 0
    fi
    attempt=$((attempt + 1))
    sleep 2
  done

  attempt=1
  while [ $attempt -le $max_attempts ]; do
    ASSETS_INFO=$(curl -fsSL --max-time 15 -H "Accept: application/vnd.github.v3+json" "$proxy_assets_url" 2>/dev/null || true)
    if [ -n "$ASSETS_INFO" ]; then
      return 0
    fi
    attempt=$((attempt + 1))
    sleep 3
  done

  return 1
}

parse_download_url() {
  local url=""
  local payload="${RELEASE_INFO}"
  local is_array=false

  if echo "$payload" | grep -q '^[[:space:]]*\['; then
    is_array=true
  fi
  if command -v jq >/dev/null 2>&1; then
    if [ "$is_array" = true ]; then
      url=$(echo "$payload" | jq -r '.[] | select(.browser_download_url | test("openlist-frontend-dist.*\\.tar\\.gz$") and (test("lite") | not)) | .browser_download_url' | head -1)
    else
      url=$(echo "$payload" | jq -r '.assets[] | select(.browser_download_url | test("openlist-frontend-dist.*\\.tar\\.gz$") and (test("lite") | not)) | .browser_download_url' | head -1)
    fi
  else
    url=$(echo "$payload" | grep -o '"browser_download_url"[[:space:]]*:[[:space:]]*"[^"]*openlist-frontend-dist[^\"]*\.tar\.gz"' | grep -v 'lite' | head -1 | sed 's/.*"browser_download_url"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
  fi
  echo "$url"
}

parse_download_url_from_html() {
  local html="$1"
  local url
  url=$(echo "$html" | grep -o 'href="/OpenListTeam/OpenList-Frontend/releases/download/[^"]*openlist-frontend-dist[^\"]*\.tar\.gz"' | grep -v 'lite' | head -1 | sed 's/href="/https:\/\/github.com/')
  echo "$url"
}

try_latest_direct() {
  local candidate="https://github.com/OpenListTeam/OpenList-Frontend/releases/latest/download/openlist-frontend-dist.tar.gz"
  if curl -fsSLI --max-time 10 "$candidate" >/dev/null 2>&1; then
    echo "$candidate"
    return 0
  fi
  return 1
}

if ! fetch_release_info; then
  echo "Failed to fetch frontend release info."
  exit 1
fi

ASSETS_INFO="$RELEASE_INFO"
if command -v jq >/dev/null 2>&1; then
  ASSETS_URL=$(echo "$RELEASE_INFO" | jq -r '.assets_url' | head -1)
else
  ASSETS_URL=$(echo "$RELEASE_INFO" | grep -o '"assets_url"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/"assets_url"[[:space:]]*:[[:space:]]*"\([^"]*\)"/\1/')
fi
if [ -n "$ASSETS_URL" ] && [ "$ASSETS_URL" != "null" ]; then
  if fetch_assets_info "$ASSETS_URL"; then
    :
  fi
fi

RELEASE_INFO="$ASSETS_INFO"
DOWNLOAD_URL=$(parse_download_url)
if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" = "null" ]; then
  echo "Failed to parse frontend download URL from API. Trying HTML fallback."
  RELEASE_HTML=$(curl -fsSL --max-time 15 "https://github.com/${FRONTEND_REPO}/releases/latest" 2>/dev/null || true)
  if [ -z "$RELEASE_HTML" ]; then
    RELEASE_HTML=$(curl -fsSL --max-time 20 "https://ghproxy.lvedong.eu.org/https://github.com/${FRONTEND_REPO}/releases/latest" 2>/dev/null || true)
  fi
  if [ -n "$RELEASE_HTML" ]; then
    DOWNLOAD_URL=$(parse_download_url_from_html "$RELEASE_HTML")
  fi
fi

if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" = "null" ]; then
  echo "HTML fallback failed. Trying latest direct download URL."
  DOWNLOAD_URL=$(try_latest_direct || true)
fi

if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" = "null" ]; then
  echo "Failed to parse frontend download URL."
  echo "API response preview:"
  echo "$RELEASE_INFO" | head -20
  exit 1
fi

echo "Downloading frontend: $DOWNLOAD_URL"
rm -f "$FRONTEND_CACHE_TAR"

if ! curl -fsSL --max-time 45 -o "$FRONTEND_CACHE_TAR" "$DOWNLOAD_URL"; then
  echo "Direct download failed, trying proxy."
  if ! curl -fsSL --max-time 60 -o "$FRONTEND_CACHE_TAR" "https://ghproxy.lvedong.eu.org/$DOWNLOAD_URL"; then
    echo "Failed to download frontend assets."
    exit 1
  fi
fi

rm -rf "$FRONTEND_CACHE_DIR"
ensure_dir "$FRONTEND_CACHE_DIR"

tar -zxf "$FRONTEND_CACHE_TAR" -C "$FRONTEND_CACHE_DIR"

echo "Frontend cached at: $FRONTEND_CACHE_DIR"
