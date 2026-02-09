import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/features/scraper/domain/scrape_result.dart';
import 'package:jmusic/features/settings/presentation/settings_providers.dart';
import 'package:jmusic/core/utils/scraper_utils.dart';

final itunesServiceProvider = Provider((ref) {
  final proxySettings = ref.watch(proxySettingsProvider);
  return ItunesSearchService(proxySettings);
});

class ItunesSearchService {
  late final Dio _dio;
  final ProxySettings proxySettings;

  ItunesSearchService(this.proxySettings) {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://itunes.apple.com',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
        'Accept': 'application/json',
        'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
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

  Future<List<ScrapeResult>> searchTrack(String title, {String? artist, String? album}) async {
    final cleanTitle = sanitizeTitleForSearch(title);
    final cleanArtist = artist == null ? '' : sanitizeArtistForSearch(artist);
    final cleanAlbum = album == null ? '' : sanitizeAlbumForSearch(album);

    final keyword = [cleanTitle, cleanArtist, cleanAlbum]
      .where((s) => s.isNotEmpty)
      .join(' ');

    if (keyword.isEmpty) return [];

    try {
      final response = await _dio.get(
        '/search',
        queryParameters: {
          'term': keyword,
          'entity': 'song',
          'limit': 30,
          'media': 'music',
          'country': 'CN',
          'lang': 'zh_cn',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        Map<String, dynamic>? json;
        if (data is String) {
          json = jsonDecode(data) as Map<String, dynamic>;
        } else if (data is Map<String, dynamic>) {
          json = data;
        } else if (data is Map) {
          json = Map<String, dynamic>.from(data);
        }

        final List results = (json?['results'] as List?) ?? [];
        return results.map((item) {
          final trackName = item['trackName']?.toString() ?? title;
          final artistName = item['artistName']?.toString() ?? (artist ?? 'Unknown');
          final albumName = item['collectionName']?.toString() ?? (album ?? 'Unknown');
          final date = item['releaseDate']?.toString();
          final artwork = item['artworkUrl100']?.toString();
          final coverUrl = artwork?.replaceAll('100x100bb', '600x600bb');
          final durationMs = item['trackTimeMillis'] is int
              ? item['trackTimeMillis'] as int
              : int.tryParse(item['trackTimeMillis']?.toString() ?? '');

          return ScrapeResult(
            source: ScrapeSource.itunes,
            id: item['trackId']?.toString() ?? '',
            title: trackName,
            artist: artistName,
            album: albumName,
            date: date,
            coverUrl: coverUrl,
            durationMs: durationMs,
          );
        }).toList();
      }
    } catch (e) {
      print('iTunes Search Error: $e');
    }
    return [];
  }
}
