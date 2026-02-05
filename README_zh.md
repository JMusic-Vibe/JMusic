# JMusic

[English](README.md) | 中文

一个跨平台的本地音乐播放器，支持 WebDAV 同步，并内置 OpenList 本地服务用于高级文件访问。

## 项目特色

- 本地音乐库扫描与管理
- 播放队列、迷你播放器、视频播放
- 播放列表与基本库管理
- WebDAV 同步与配置
- 内置 OpenList 服务管理（本地服务）
- 元数据刮削与 ID3 标签解析
- OpenList 代理支持
- 已测试平台：Windows、Android（iOS/macOS/Linux 仍在完善中）

## OpenList 集成说明

本项目将 OpenList 作为本地服务嵌入：

- 后端源码：`openlist-backend/`
- 前端资源：由 `openlist-jmusic-lib/frontends/dist` 缓存
- Android 以 AAR + 本地资源方式打包，资源位于 `android/app/src/main/assets/openlist/`
- 桌面端运行时路径（Windows/macOS/Linux）：`~/Documents/j_music/openlist/`

内嵌 WebView 仅在 Android 与 iOS 启用，桌面端将使用外部浏览器打开管理页面。

## 目录结构

- `lib/core`：公共服务、主题、工具、组件
- `lib/features`：功能模块（库、播放器、同步、刮削、设置）
- `openlist-backend`：OpenList 后端源码（第三方）
- `openlist-jmusic-lib`：OpenList 多平台统一编译脚本

## 开发环境

### 依赖

- Flutter SDK（3.2+）
- Dart SDK（Flutter 自带）
- Android SDK + NDK（`android/app/build.gradle.kts` 使用 NDK 27.0.12077973）
- Go 工具链（用于 OpenList）
- bash 环境（Git Bash / WSL / macOS / Linux）

### 快速开始

```bash
flutter pub get
dart run build_runner build
flutter run
```

## OpenList 编译脚本

所有 OpenList 编译步骤集中在 `openlist-jmusic-lib/`：

```bash
# 初始化 OpenList 源码（写入 openlist-backend）
./openlist-jmusic-lib/build.sh init

# 下载前端资源
./openlist-jmusic-lib/build.sh frontend

# 构建 Android AAR
./openlist-jmusic-lib/build.sh android

# 构建 iOS xcframework（仅 macOS）
./openlist-jmusic-lib/build.sh ios

# 构建桌面/服务端二进制
./openlist-jmusic-lib/build.sh desktop release
```

产物位置：

- Android AAR：`android/app/libs`
- Android OpenList 资源：`android/app/src/main/assets/openlist/dist`
- iOS xcframework：`ios/Frameworks`
- 桌面端运行时：
  - Windows：`C:\Users\<user>\Documents\j_music\openlist\openlist.exe`
  - macOS/Linux：`~/Documents/j_music/openlist/openlist`

更多平台依赖请查看 `openlist-jmusic-lib/README.md`（MSYS2 UCRT64、gomobile 等）。

## 贡献说明

- 代码生成：`dart run build_runner build`
- OpenList 资源与二进制不提交仓库，使用脚本本地构建
- Android 使用 AAR + 本地资源；桌面端使用用户 Documents 下的 OpenList 运行目录

## 第三方项目引用

本项目集成了以下上游项目：

- OpenList 后端：https://github.com/OpenListTeam/OpenList（AGPL-3.0）
- OpenList 前端：https://github.com/OpenListTeam/OpenList-Frontend

发布或分发时请遵循其许可证与引用要求。
