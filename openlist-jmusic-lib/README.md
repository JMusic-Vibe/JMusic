# OpenList JMusic Lib

This folder provides unified, local build scripts for OpenList across platforms.
It is designed to work with the local openlist-backend source copy and keeps
frontend assets in one cache location.

## Layout

- openlist-jmusic-lib/
  - build.sh
  - frontends/
    - dist/               # cached OpenList-Frontend files
  - scripts/
    - env.sh
    - fetch_frontend.sh
    - apply_frontend.sh
    - init_openlist_source.sh
    - build_android_aar.sh
    - build_ios_xcframework.sh
    - build_desktop.sh

## Prerequisites

- bash (WSL, Git Bash, macOS, or Linux)
- git, curl, tar, unzip
- Go toolchain
- For Android AAR: Android NDK, gomobile, gobind
- For iOS: macOS + Xcode + gomobile
- For Windows EXE (CGO): MSYS2 UCRT64 + mingw toolchain

Required tools by platform:

- Android (AAR)
  - Go
  - gomobile, gobind
  - Android NDK
- iOS (xcframework)
  - macOS
  - Xcode
  - Go
  - gomobile, gobind
- Windows (EXE, CGO sqlite)
  - MSYS2 UCRT64 terminal
  - mingw-w64-ucrt-x86_64-toolchain
  - Go (either system Go on PATH or mingw-w64-ucrt-x86_64-go)
- Linux/macOS (desktop/server)
  - Go
  - Optional: jq (for build.sh release web fetch)

## Quick Start

From the JMusic repo root:

- Initialize OpenList source inside openlist-backend
  ./openlist-jmusic-lib/build.sh init

- Fetch and cache OpenList-Frontend assets (stored in openlist-jmusic-lib/frontends/dist)
  ./openlist-jmusic-lib/build.sh frontend

- Build Android AAR
  ./openlist-jmusic-lib/build.sh android

- Build iOS xcframework (macOS only)
  ./openlist-jmusic-lib/build.sh ios

- Build OpenList desktop/server binaries (uses OpenList build.sh)
  ./openlist-jmusic-lib/build.sh desktop release

- Run all (init + frontend + android + ios + desktop)
  ./openlist-jmusic-lib/build.sh all

## Notes

- Frontend assets are cached in openlist-jmusic-lib/frontends/dist and synced to
  openlist-backend/public/dist before mobile builds.
- Desktop/server builds use the upstream OpenList build.sh, which downloads its
  own web assets. Use mobile cache only for Android/iOS builds.

## Output locations (where to place build results)

- Android
  - AAR output: android/app/libs
  - Frontend assets (optional, for Android packaging): android/app/src/main/assets/openlist

- iOS
  - xcframework output: ios/Frameworks

- Windows (runtime)
  - EXE runtime path: 优先使用应用可执行文件所在目录的 `openlist\openlist.exe`（若存在），否则使用 `C:\Users\<username>\Documents\j_music\openlist\openlist.exe`
  - Frontend runtime path: 优先使用应用可执行文件所在目录的 `openlist\public\dist`（若存在），否则使用 `C:\Users\<username>\Documents\j_music\openlist\public\dist`

- Linux/macOS (runtime)
  - Binary runtime path: 优先使用应用可执行文件所在目录的 `openlist/openlist`（若存在），否则使用 `~/Documents/j_music/openlist/openlist`
  - Frontend runtime path: 优先使用应用可执行文件所在目录的 `openlist/public/dist`（若存在），否则使用 `~/Documents/j_music/openlist/public/dist`
