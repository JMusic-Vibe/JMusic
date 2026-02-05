#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

skip_init=false
skip_frontend=false
debug_mode=false

for arg in "$@"; do
  case "$arg" in
    --skip-init) skip_init=true ;;
    --skip-frontend) skip_frontend=true ;;
    --debug) debug_mode=true ;;
  esac
done

if [ "$skip_init" = false ]; then
  "$SCRIPT_DIR/init_openlist_source.sh"
fi

if [ "$skip_frontend" = false ]; then
  "$SCRIPT_DIR/fetch_frontend.sh"
  "$SCRIPT_DIR/apply_frontend.sh"
fi

if [ ! -d "$OPENLIST_LIB/scripts" ]; then
  echo "OpenList lib scripts not found at: $OPENLIST_LIB/scripts"
  exit 1
fi

chmod +x "$OPENLIST_LIB/scripts"/*.sh || true

pushd "$OPENLIST_LIB/scripts" >/dev/null
./init_gomobile.sh

if [ "$debug_mode" = true ]; then
  ./gobind.sh debug
else
  ./gobind.sh
fi
popd >/dev/null

echo "Android AAR output: $MOBILE_ROOT/android/app/libs"
