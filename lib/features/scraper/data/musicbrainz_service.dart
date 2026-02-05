import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/network/system_proxy_helper.dart';
import 'package:jmusic/features/scraper/domain/musicbrainz_result.dart';

import 'package:jmusic/features/settings/presentation/settings_providers.dart';
import 'package:jmusic/core/utils/scraper_utils.dart';

final musicBrainzServiceProvider = Provider((ref) {
  final proxySettings = ref.watch(proxySettingsProvider);
  return MusicBrainzService(proxySettings);
});

class MusicBrainzService {
  late final Dio _dio;
  final ProxySettings proxySettings;

  MusicBrainzService(this.proxySettings) {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://musicbrainz.org/ws/2',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        // 伪装成现代浏览器 Header，避免被 archive.org 等作为爬虫拦截
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
        'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
        'Sec-Fetch-Dest': 'document',
        'Sec-Fetch-Mode': 'navigate',
        'Sec-Fetch-Site': 'none',
        'Sec-Fetch-User': '?1',
        'Upgrade-Insecure-Requests': '1',
        'Connection': 'close', // 保持关闭连接以解决信号灯超时
      },
    ));

    // 忽略 SSL 证书错误
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      // HttpClient() 会自动使用 GlobalHttpOverrides (在 main.dart 中初始化)
      // GlobalHttpOverrides 已经包含了完整的代理检测逻辑 (system, custom, none)
      final client = HttpClient();
      
      // 注意：这里显式触发一次代理查找，确保 Dio 创建的 client 也遵循全局策略
      // 虽然 HttpOverrides 应该是全局的，但某些版本的 Dio/adapter 可能会绕过
      client.badCertificateCallback = (cert, host, port) => true;

      // 关键修复：缩短空闲超时，避免 Windows 信号灯超时(Semaphore timeout)
      client.idleTimeout = const Duration(seconds: 15);
      client.connectionTimeout = const Duration(seconds: 15);

      return client;
    };
  }

  /// 刷新系统代理缓存并进行搜索
  ///
  /// 参数: title 必填, artist/album 可选。如果 artist 或 album 表示未知或为空
  /// 将不会被加入查询条件, 避免使用 "Unknown" 字样去搜索。
  Future<List<MusicBrainzResult>> searchRecording(String title, [String? artist, String? album]) async {
    // 移除：不要在每次请求时都刷新系统代理，使用启动时或全局缓存的配置即可
    // if (proxySettings.mode == 'system') { ... }

    // sanitize inputs to improve search matching
    final cleanTitle = sanitizeTitleForSearch(title);
    final cleanArtist = artist == null ? null : sanitizeArtistForSearch(artist);
    final cleanAlbum = album == null ? null : sanitizeAlbumForSearch(album);

    final queryBuffer = StringBuffer();
    // 基础查询: 歌名
    queryBuffer.write('recording:"$cleanTitle"');
    // 排除视频（MV等）
    queryBuffer.write(' AND video:false'); 
    
    bool _isMeaningful(String? s) {
      if (s == null) return false;
      final v = s.trim();
      if (v.isEmpty) return false;
      final lower = v.toLowerCase();
      // 排除常见的占位符，例如 Unknown, Unknown Artist/Album 等
      if (lower.contains('unknown')) return false;
      return true;
    }

    if (_isMeaningful(cleanArtist)) {
      queryBuffer.write(' AND artist:"$cleanArtist"');
    }
    if (_isMeaningful(cleanAlbum)) {
      // MusicBrainz uses 'release' to match album/release titles
      queryBuffer.write(' AND release:"$cleanAlbum"');
    }

    try {
      final response = await _dio.get(
        '/recording',
        queryParameters: {
          'query': queryBuffer.toString(),
          'fmt': 'json',
          // 不需要太多结果，只要最匹配的
          'limit': 30, 
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['recordings'] != null) {
          final list = List<Map<String, dynamic>>.from(data['recordings']);
          return list.map((json) => MusicBrainzResult.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('MusicBrainz Search Error: $e');
    }
    return [];
  }

  /// 获取封面 (通过 Cover Art Archive)
  Future<String?> getCoverArtUrl(String releaseId) async {
    // 移除：不要在每次请求时都刷新系统代理
    // if (proxySettings.mode == 'system') { ... }

    try {
      print('[MusicBrainzService] Fetching cover for releaseId: $releaseId');
      
      // 使用已配置好的 _dio (忽略 SSL 错误)
      // 显式指定 Header 确保跳转到 archive.org 时也能保持伪装
      final response = await _dio.get(
        'https://coverartarchive.org/release/$releaseId',
        options: Options(
          headers: {
            // 伪装成现代浏览器 Header，避免被 archive.org 等作为爬虫拦截
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
            'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
            'Sec-Fetch-Dest': 'document',
            'Sec-Fetch-Mode': 'navigate',
            'Sec-Fetch-Site': 'none',
            'Sec-Fetch-User': '?1',
            'Upgrade-Insecure-Requests': '1',
            'Connection': 'keep-alive', // 改为 keep-alive 尝试复用连接
          },
          // 允许 404 状态码不抛出异常，视为"正常"的业务逻辑（即：没有封面）
          validateStatus: (status) {
            return status != null && (status >= 200 && status < 300 || status == 404);
          },
        ),
      );
      
      // 成功获取
      if (response.statusCode == 200) {
        // 如果发生了重定向，打印最终的 URI 方便调试
        if (response.realUri.host.contains('archive.org')) {
           print('[MusicBrainzService] Successfully followed redirect to: ${response.realUri}');
        }
        
        final images = response.data['images'] as List;
        if (images.isNotEmpty) {
           // 优先找 Front
           final front = images.firstWhere(
             (img) => img['front'] == true, 
             orElse: () => images.first
           );
           print('[MusicBrainzService] Found cover URL: ${front['image']}');
           return front['image'];
        }
      } else if (response.statusCode == 404) {
        print('[MusicBrainzService] No cover art found for releaseId: $releaseId (404 Not Found)');
        return null; // 优雅返回 null，不再报错
      }
    } catch (e) {
      print('[MusicBrainzService] Cover Art Error ($releaseId)');
      if (e is DioException) {
        print('  - Type: ${e.type}');
        print('  - Message: ${e.message}');
        if (e.response != null) {
             print('  - Final URI: ${e.response?.realUri}'); // 打印最终跳转到的地址
        } else {
             print('  - Hint: Connection failed. This usually means the proxy settings did not apply to the redirected URL (archive.org).');
             print('  - Current proxy config: ${SystemProxyHelper.proxyDirective}');
        }
      } else {
        print('  - Error: $e');
      }
    }
    return null;
  }
}

