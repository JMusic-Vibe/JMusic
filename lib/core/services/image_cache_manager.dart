import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// 自定义图片缓存管理器
/// 1. 解决 Windows/Android 下的代理与 SSL 问题
/// 2. 提供长期的图片缓存（默认 365 天），避免重复下载
class ImageCacheManager {
  static const key = 'j_music_image_cache';
  
  // 单例实例
  static final CacheManager instance = CacheManager(
    Config(
      key, 
      // 缓存过期时间：365天，实现"不用每次都下载"
      stalePeriod: const Duration(days: 365), 
      // 最大缓存数量：1000张封面
      maxNrOfCacheObjects: 1000, 
      // 使用自定义的文件服务（包含代理和超时处理）
      fileService: HttpFileService(
        httpClient: _createHttpClient(),
      ),
    ),
  );

  /// 创建带有代理感知和超时优化的 HttpClient
  static http.Client _createHttpClient() {
    // 优先使用全局 HttpOverrides（由 GlobalHttpOverrides 管理代理/证书/超时等）。
    // 避免直接 new HttpClient() 导致绕过全局代理配置的问题
    final baseClient = HttpOverrides.current?.createHttpClient(null) ?? HttpClient();

    // 保证常用的健壮性配置（如果 GlobalHttpOverrides 已设置，这些设置会被覆盖为同样或更合适的值）
    // 直接设置回退值，避免在某些平台上读取不存在的 getter 导致编译错误
    try {
      baseClient.badCertificateCallback = (cert, host, port) => true;
    } catch (_) {
      // ignore: no-op if platform doesn't expose the setter
    }
    try {
      baseClient.idleTimeout = const Duration(seconds: 15);
    } catch (_) {}
    try {
      baseClient.connectionTimeout = baseClient.connectionTimeout ?? const Duration(seconds: 15);
    } catch (_) {
      // 某些平台或 dart 版本可能不支持直接设置 connectionTimeout，忽略错误
    }

    return IOClient(baseClient);
  }
}

