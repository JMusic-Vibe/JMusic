import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/features/settings/presentation/settings_providers.dart';
import 'package:jmusic/features/scraper/data/artist_sources/artist_models.dart';

final itunesArtistServiceProvider = Provider((ref) {
  final proxySettings = ref.watch(proxySettingsProvider);
  return ItunesArtistService(proxySettings);
});

class ItunesArtistService {
  late final Dio _itunesDio;
  final ProxySettings proxySettings;

  ItunesArtistService(this.proxySettings) {
    _itunesDio = Dio(BaseOptions(
      baseUrl: 'https://itunes.apple.com',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
        'Accept': 'application/json',
        'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
      },
    ));

    (_itunesDio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      client.idleTimeout = const Duration(seconds: 15);
      client.connectionTimeout = const Duration(seconds: 15);
      return client;
    };
  }

  Future<List<ArtistSearchResult>> searchArtists(String name) async {
    final query = name.trim();
    if (query.isEmpty) return [];
    try {
      final response = await _itunesDio.get(
        '/search',
        queryParameters: {
          'term': query,
          'entity': 'song',
          'attribute': 'artistTerm',
          'limit': 25,
          'media': 'music',
          'country': 'CN',
          'lang': 'zh_cn',
        },
        options: Options(validateStatus: (status) => status == 200),
      );

      if (response.statusCode == 200 && response.data != null) {
        Map<String, dynamic>? json;
        final data = response.data;
        if (data is String) {
          json = jsonDecode(data) as Map<String, dynamic>;
        } else if (data is Map<String, dynamic>) {
          json = data;
        } else if (data is Map) {
          json = Map<String, dynamic>.from(data);
        }

        final List results = (json?['results'] as List?) ?? [];
        final Map<String, ArtistSearchResult> byArtist = {};
        for (final item in results) {
          if (item is! Map) continue;
          final artistName = item['artistName']?.toString() ?? '';
          final artistId = item['artistId']?.toString() ?? artistName;
          final artwork = item['artworkUrl100']?.toString();
          final imageUrl = artwork?.replaceAll('100x100bb', '600x600bb');
          if (artistName.isEmpty) continue;
          byArtist.putIfAbsent(
            artistId,
            () => ArtistSearchResult(
              id: artistId,
              name: artistName,
              source: ArtistSource.itunes,
              imageUrl: imageUrl,
            ),
          );
        }
        return byArtist.values.toList();
      }
    } catch (_) {}
    return [];
  }

  Future<String?> fetchArtistImageUrlFromItunes(String artistName) async {
    final results = await searchArtists(artistName);
    if (results.isEmpty) return null;
    return results.first.imageUrl;
  }
}
