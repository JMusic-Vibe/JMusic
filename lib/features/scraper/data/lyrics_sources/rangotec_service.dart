import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/features/settings/presentation/settings_providers.dart';

final rangotecLyricsServiceProvider = Provider((ref) {
  final proxySettings = ref.watch(proxySettingsProvider);
  return RangotecLyricsService(proxySettings);
});

class RangotecLyricsService {
  late final Dio _dio;
  final ProxySettings proxySettings;

  RangotecLyricsService(this.proxySettings) {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://tools.rangotec.com/api/anon',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
        'Accept': 'application/json',
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

  Future<List<Map<String, dynamic>>> search({
    required String title,
    String? artist,
    String? album,
  }) async {
    final pTitle = title.trim();
    final pArtist = artist?.trim() ?? '';
    final pAlbum = album?.trim() ?? '';

    //final keywords = pTitle + (pArtist.isNotEmpty ? ' ' + pArtist : '') + (pAlbum.isNotEmpty ? ' ' + pAlbum : '');
    final response = await _dio.get(
      '/lrc',
      queryParameters: {
        'title': pTitle,
        'artist': pArtist,
        'album': pAlbum,
        'od': 'desc',
      },
      options: Options(validateStatus: (status) => status == 200),
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      if (data is Map && data['code'] == 200 && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
    }
    return [];
  }
}
