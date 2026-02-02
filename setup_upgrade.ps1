# JMusic 音频播放器升级 - 快速开始脚本

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  JMusic 音频播放器重大升级" -ForegroundColor Cyan
Write-Host "  从 media_kit 迁移到 just_audio" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 步骤1: 清理旧构建
Write-Host "[1/5] 清理旧的构建文件..." -ForegroundColor Yellow
flutter clean
if (Test-Path "pubspec.lock") {
    Remove-Item "pubspec.lock" -Force
    Write-Host "✓ 已删除 pubspec.lock" -ForegroundColor Green
}
Write-Host "✓ 清理完成" -ForegroundColor Green
Write-Host ""

# 步骤2: 获取依赖
Write-Host "[2/5] 获取新的依赖包..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ 依赖获取成功" -ForegroundColor Green
} else {
    Write-Host "✗ 依赖获取失败" -ForegroundColor Red
    exit 1
}
Write-Host ""

# 步骤3: 重新生成代码
Write-Host "[3/5] 重新生成 Isar 数据库代码..." -ForegroundColor Yellow
flutter pub run build_runner build --delete-conflicting-outputs
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ 代码生成成功" -ForegroundColor Green
} else {
    Write-Host "⚠ 代码生成可能失败,但可以继续" -ForegroundColor Yellow
}
Write-Host ""

# 步骤4: 检查设备
Write-Host "[4/5] 检查可用设备..." -ForegroundColor Yellow
flutter devices
Write-Host ""

# 步骤5: 询问是否运行
Write-Host "[5/5] 准备就绪!" -ForegroundColor Green
Write-Host ""
$run = Read-Host "是否立即运行应用? (y/n)"

if ($run -eq 'y' -or $run -eq 'Y') {
    Write-Host ""
    Write-Host "正在启动应用..." -ForegroundColor Cyan
    Write-Host ""
    flutter run
} else {
    Write-Host ""
    Write-Host "稍后可以使用以下命令运行:" -ForegroundColor Yellow
    Write-Host "  flutter run" -ForegroundColor White
    Write-Host ""
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "升级完成!" -ForegroundColor Green
Write-Host ""
Write-Host "新功能:" -ForegroundColor Yellow
Write-Host "  ✨ 后台播放与通知栏控制" -ForegroundColor White
Write-Host "  ✨ 锁屏播放控制" -ForegroundColor White
Write-Host "  ✨ 蓝牙耳机支持" -ForegroundColor White
Write-Host "  ✨ 歌曲淡入淡出效果" -ForegroundColor White
Write-Host ""
Write-Host "查看详细说明:" -ForegroundColor Yellow
Write-Host "  .\UPGRADE_GUIDE.md - 升级说明" -ForegroundColor White
Write-Host "  .\BUILD_GUIDE.md   - 构建指南" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
