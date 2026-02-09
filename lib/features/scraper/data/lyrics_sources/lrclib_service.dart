import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/features/settings/presentation/settings_providers.dart';

final lrclibLyricsServiceProvider = Provider((ref) {
  final proxySettings = ref.watch(proxySettingsProvider);
  return LrclibLyricsService(proxySettings);
});

class LrclibLyricsService {
  late final Dio _dio;
  final ProxySettings proxySettings;

  LrclibLyricsService(this.proxySettings) {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://lrclib.net/api',
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

  Future<String?> fetch({
    required String title,
    required String artist,
    String? album,
  }) async {
    if (title.trim().isEmpty || artist.trim().isEmpty) return null;
    final response = await _dio.get(
      '/get',
      queryParameters: {
        'track_name': title,
        'artist_name': artist,
        if (album != null && album.trim().isNotEmpty) 'album_name': album,
      },
      options: Options(validateStatus: (status) => status == 200 || status == 404 || status == 400),
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      final synced = data['syncedLyrics']?.toString();
      if (synced != null && synced.trim().isNotEmpty) {
        return synced;
      }
    }
    return null;
  }
}
