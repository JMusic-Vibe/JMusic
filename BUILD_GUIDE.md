# 构建和运行指南

## 准备工作

### 1. 清理旧的构建文件

```powershell
# Windows PowerShell
flutter clean
Remove-Item -Recurse -Force pubspec.lock
```

### 2. 获取新的依赖

```powershell
flutter pub get
```

### 3. 重新生成Isar数据库代码（如果需要）

```powershell
flutter pub run build_runner build --delete-conflicting-outputs
```

## Android配置

### 权限已配置

AndroidManifest.xml中已包含必要权限：
- ✅ `FOREGROUND_SERVICE`
- ✅ `FOREGROUND_SERVICE_MEDIA_PLAYBACK`
- ✅ `WAKE_LOCK`
- ✅ `READ_EXTERNAL_STORAGE`
- ✅ `READ_MEDIA_AUDIO`

### 运行Android应用

```powershell
# 连接Android设备或启动模拟器
flutter devices

# 运行应用
flutter run
```

## iOS配置（如需支持）

### Info.plist配置

需要在 `ios/Runner/Info.plist` 中添加：

```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>

<key>NSMicrophoneUsageDescription</key>
<string>用于音频播放控制</string>
```

### 运行iOS应用

```bash
cd ios
pod install
cd ..
flutter run
```

## Windows配置

Windows平台可直接运行，无需额外配置：

```powershell
flutter run -d windows
```

## 测试功能

### 1. 基本播放测试

```dart
// 在应用中测试
1. 导入音乐文件
2. 点击播放
3. 验证播放/暂停功能
4. 测试上一曲/下一曲
```

### 2. 后台播放测试（Android）

```
1. 开始播放音乐
2. 按Home键回到桌面
3. 下拉通知栏
4. 验证播放控制是否显示
5. 测试通知栏的播放/暂停按钮
6. 测试上一曲/下一曲按钮
```

### 3. 淡入淡出测试

```
1. 进入 设置 > 音频与播放 > 播放设置
2. 启用淡入淡出
3. 设置时长为5秒
4. 播放歌曲并切换到下一首
5. 观察音量变化是否平滑
```

### 4. 蓝牙耳机测试

```
1. 连接蓝牙耳机
2. 播放音乐
3. 使用耳机上的按键控制播放
4. 验证播放/暂停、切歌等功能
```

## 常见构建问题

### 问题1: 依赖冲突

```
解决方案：
flutter clean
flutter pub get
```

### 问题2: Android构建失败

```
可能原因：
- Gradle版本不兼容
- NDK版本问题
- 缓存问题

解决方案：
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### 问题3: just_audio插件错误

```
确保以下配置正确：
1. android/build.gradle 中 minSdkVersion >= 21
2. compileSdkVersion >= 33
3. 清理并重新构建
```

### 问题4: audio_service初始化失败

```
检查：
1. AndroidManifest.xml中的service配置
2. FOREGROUND_SERVICE权限
3. 确保在main()中正确初始化
```

## 性能优化建议

### 1. Release构建

```powershell
flutter build apk --release
# 或
flutter build appbundle --release
```

### 2. 减小APK大小

在 `android/app/build.gradle` 中：

```gradle
android {
    buildTypes {
        release {
            shrinkResources true
            minifyEnabled true
        }
    }
}
```

### 3. 启用分包

```gradle
android {
    defaultConfig {
        multiDexEnabled true
    }
}
```

## 调试技巧

### 查看日志

```powershell
# Android
adb logcat | Select-String "flutter"

# 或在VS Code中使用Debug Console
```

### 性能分析

```powershell
flutter run --profile
# 然后在DevTools中查看性能
```

### 内存分析

```powershell
flutter run --profile
# 打开 DevTools > Memory
```

## 发布准备

### Android签名配置

1. 创建签名密钥：
```powershell
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

2. 在 `android/key.properties` 中配置：
```
storePassword=<密码>
keyPassword=<密码>
keyAlias=key
storeFile=<密钥路径>
```

3. 构建签名APK：
```powershell
flutter build apk --release
```

### 版本号管理

在 `pubspec.yaml` 中更新：
```yaml
version: 0.2.0+2  # 0.2.0 是版本名，2 是版本号
```

## 下一步

1. ✅ 完成基本功能测试
2. ⏳ 进行性能测试
3. ⏳ 收集用户反馈
4. ⏳ 修复发现的问题
5. ⏳ 准备发布

---

**更新时间**: 2024年1月29日
**维护者**: JMusic开发团队
