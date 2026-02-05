#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

if [ ! -f "$OPENLIST_LIB/build.sh" ]; then
  echo "OpenList build.sh not found at: $OPENLIST_LIB/build.sh"
  exit 1
fi

chmod +x "$OPENLIST_LIB/build.sh" || true

cd "$OPENLIST_LIB"

# Pass through arguments, example: release, dev, release linux_musl, etc.
./build.sh "$@"
