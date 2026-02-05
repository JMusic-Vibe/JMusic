#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

if [ ! -d "$FRONTEND_CACHE_DIR" ] || [ -z "$(ls -A "$FRONTEND_CACHE_DIR" 2>/dev/null)" ]; then
  echo "Frontend cache is empty. Run fetch_frontend.sh first."
  exit 1
fi

if [ ! -d "$OPENLIST_LIB" ]; then
  echo "OpenList lib not found at: $OPENLIST_LIB"
  exit 1
fi

ensure_dir "$OPENLIST_LIB/public"
rm -rf "$OPENLIST_LIB/public/dist"

cp -R "$FRONTEND_CACHE_DIR" "$OPENLIST_LIB/public/dist"

echo "Frontend synced to: $OPENLIST_LIB/public/dist"
