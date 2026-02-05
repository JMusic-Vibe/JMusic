#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

WINDOWS_RELEASE_DIR=${1:-"$MOBILE_ROOT/build/windows/x64/runner/Release"}

find_openlist_exe() {
  local candidates=(
    "$OPENLIST_LIB/build/openlist-windows-amd64.exe"
    "$OPENLIST_LIB/build/openlist-windows7-amd64.exe"
    "$OPENLIST_LIB/build/openlist-windows-arm64.exe"
  )
  for candidate in "${candidates[@]}"; do
    if [ -f "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  done
  return 1
}

ensure_dir "$WINDOWS_RELEASE_DIR"

OPENLIST_EXE=$(find_openlist_exe || true)
if [ -z "$OPENLIST_EXE" ]; then
  echo "OpenList EXE not found. Build it first: ./openlist-jmusic-lib/build.sh desktop release"
  exit 1
fi

FRONTEND_SRC=""
if [ -d "$OPENLIST_LIB/public/dist" ]; then
  FRONTEND_SRC="$OPENLIST_LIB/public/dist"
elif [ -d "$FRONTEND_CACHE_DIR" ]; then
  FRONTEND_SRC="$FRONTEND_CACHE_DIR"
fi

if [ -z "$FRONTEND_SRC" ]; then
  echo "Frontend assets not found. Run: ./openlist-jmusic-lib/build.sh frontend"
  exit 1
fi

INSTALL_OPENLIST_DIR="$WINDOWS_RELEASE_DIR/openlist"
ensure_dir "$INSTALL_OPENLIST_DIR"

cp -f "$OPENLIST_EXE" "$INSTALL_OPENLIST_DIR/openlist.exe"

rm -rf "$INSTALL_OPENLIST_DIR/public/dist"
ensure_dir "$INSTALL_OPENLIST_DIR/public"
cp -R "$FRONTEND_SRC" "$INSTALL_OPENLIST_DIR/public/dist"

echo "Packaged OpenList into: $INSTALL_OPENLIST_DIR"
