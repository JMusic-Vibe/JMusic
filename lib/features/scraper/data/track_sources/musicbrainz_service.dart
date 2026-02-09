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
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
        'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
        'Sec-Fetch-Dest': 'document',
        'Sec-Fetch-Mode': 'navigate',
        'Sec-Fetch-Site': 'none',
        'Sec-Fetch-User': '?1',
        'Upgrade-Insecure-Requests': '1',
        'Connection': 'close', 
      },
    ));

    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      client.idleTimeout = const Duration(seconds: 15);
      client.connectionTimeout = const Duration(seconds: 15);
      return client;
    };
  }

  Future<List<MusicBrainzResult>> searchRecording(String title, [String? artist, String? album]) async {
    final cleanTitle = sanitizeTitleForSearch(title);
    final cleanArtist = artist == null ? null : sanitizeArtistForSearch(artist);
    final cleanAlbum = album == null ? null : sanitizeAlbumForSearch(album);

    final queryBuffer = StringBuffer();
    queryBuffer.write('recording:"$cleanTitle"');
    queryBuffer.write(' AND video:false'); 

    bool _isMeaningful(String? s) {
      if (s == null) return false;
      final v = s.trim();
      if (v.isEmpty) return false;
      final lower = v.toLowerCase();
      if (lower.contains('unknown')) return false;
      return true;
    }

    if (_isMeaningful(cleanArtist)) {
      queryBuffer.write(' AND artist:"$cleanArtist"');
    }
    if (_isMeaningful(cleanAlbum)) {
      queryBuffer.write(' AND release:"$cleanAlbum"');
    }

    try {
      final response = await _dio.get(
        '/recording',
        queryParameters: {
          'query': queryBuffer.toString(),
          'fmt': 'json',
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

  Future<String?> getCoverArtUrl(String releaseId) async {
    try {
      final response = await _dio.get(
        'https://coverartarchive.org/release/$releaseId',
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
            'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
            'Sec-Fetch-Dest': 'document',
            'Sec-Fetch-Mode': 'navigate',
            'Sec-Fetch-Site': 'none',
            'Sec-Fetch-User': '?1',
            'Upgrade-Insecure-Requests': '1',
            'Connection': 'keep-alive', 
          },
          validateStatus: (status) {
            return status != null && (status >= 200 && status < 300 || status == 404);
          },
        ),
      );

      if (response.statusCode == 200) {
        if (response.realUri.host.contains('archive.org')) {
           print('[MusicBrainzService] Successfully followed redirect to: ${response.realUri}');
        }
        final images = response.data['images'] as List;
        if (images.isNotEmpty) {
           final front = images.firstWhere(
             (img) => img['front'] == true, 
             orElse: () => images.first
           );
           print('[MusicBrainzService] Found cover URL: ${front['image']}');
           return front['image'];
        }
      } else if (response.statusCode == 404) {
        print('[MusicBrainzService] No cover art found for releaseId: $releaseId (404 Not Found)');
        return null;
      }
    } catch (e) {
      print('[MusicBrainzService] Cover Art Error ($releaseId)');
      if (e is DioException) {
        print('  - Type: ${e.type}');
        print('  - Message: ${e.message}');
        if (e.response != null) {
             print('  - Final URI: ${e.response?.realUri}');
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
