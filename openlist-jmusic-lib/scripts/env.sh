#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR/.." && pwd)

MOBILE_ROOT="$ROOT_DIR/.."
OPENLIST_LIB="$MOBILE_ROOT/openlist-backend"
FRONTEND_CACHE_DIR="$ROOT_DIR/frontends/dist"
FRONTEND_CACHE_TAR="$ROOT_DIR/frontends/dist.tar.gz"

FRONTEND_REPO="OpenListTeam/OpenList-Frontend"
OPENLIST_REPO="OpenListTeam/OpenList"

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd"
    exit 1
  fi
}

ensure_dir() {
  local dir="$1"
  mkdir -p "$dir"
}
