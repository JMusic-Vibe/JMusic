#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

if [ ! -d "$OPENLIST_LIB/scripts" ]; then
  echo "OpenList lib scripts not found at: $OPENLIST_LIB/scripts"
  exit 1
fi

chmod +x "$OPENLIST_LIB/scripts"/*.sh || true

pushd "$OPENLIST_LIB/scripts" >/dev/null
./init_openlist.sh
popd >/dev/null

