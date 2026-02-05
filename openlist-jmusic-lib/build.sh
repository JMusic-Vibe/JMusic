#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

usage() {
  cat <<'EOF'
Usage: ./openlist-jmusic-lib/build.sh <command> [args]

Commands:
  init                 Init OpenList source in OpenList-Mobile-main/openlist-lib
  frontend             Fetch frontend to cache and sync into openlist-lib
  android              Build Android AAR via gomobile
  ios                  Build iOS xcframework via gomobile (macOS only)
  desktop <args...>    Build desktop/server binaries (pass-through to build.sh)
  all                  Run init + frontend + android + ios + desktop release
  help                 Show this help

Examples:
  ./openlist-jmusic-lib/build.sh init
  ./openlist-jmusic-lib/build.sh frontend
  ./openlist-jmusic-lib/build.sh android
  ./openlist-jmusic-lib/build.sh ios
  ./openlist-jmusic-lib/build.sh desktop release
EOF
}

cmd=${1:-help}
shift || true

case "$cmd" in
  init)
    "$ROOT_DIR/scripts/init_openlist_source.sh" "$@"
    ;;
  frontend)
    "$ROOT_DIR/scripts/fetch_frontend.sh" "$@"
    "$ROOT_DIR/scripts/apply_frontend.sh" "$@"
    ;;
  android)
    "$ROOT_DIR/scripts/build_android_aar.sh" "$@"
    ;;
  ios)
    "$ROOT_DIR/scripts/build_ios_xcframework.sh" "$@"
    ;;
  desktop)
    "$ROOT_DIR/scripts/build_desktop.sh" "$@"
    ;;
  all)
    "$ROOT_DIR/scripts/init_openlist_source.sh"
    "$ROOT_DIR/scripts/fetch_frontend.sh"
    "$ROOT_DIR/scripts/apply_frontend.sh"
    "$ROOT_DIR/scripts/build_android_aar.sh"
    "$ROOT_DIR/scripts/build_ios_xcframework.sh"
    "$ROOT_DIR/scripts/build_desktop.sh" release
    ;;
  help|--help|-h)
    usage
    ;;
  *)
    echo "Unknown command: $cmd"
    usage
    exit 1
    ;;
esac
