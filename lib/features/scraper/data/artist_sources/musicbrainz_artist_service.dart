import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/features/settings/presentation/settings_providers.dart';
import 'package:jmusic/features/scraper/data/artist_sources/artist_models.dart';

final musicBrainzArtistServiceProvider = Provider((ref) {
  final proxySettings = ref.watch(proxySettingsProvider);
  return MusicBrainzArtistService(proxySettings);
});

class MusicBrainzArtistService {
  late final Dio _dio;
  final ProxySettings proxySettings;

  MusicBrainzArtistService(this.proxySettings) {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://musicbrainz.org/ws/2',
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

  Future<List<ArtistSearchResult>> searchArtists(String name) async {
    final query = name.trim();
    if (query.isEmpty) return [];
    try {
      final response = await _dio.get(
        '/artist',
        queryParameters: {
          'query': 'artist:"$query"',
          'fmt': 'json',
          'limit': 20,
        },
        options: Options(validateStatus: (status) => status == 200),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map && data['artists'] is List) {
          final list = data['artists'] as List;
          return list.whereType<Map>().map((m) {
            final id = m['id']?.toString() ?? '';
            final name = m['name']?.toString() ?? '';
            final disambiguation = m['disambiguation']?.toString();
            final type = m['type']?.toString();
            final country = m['country']?.toString();
            return ArtistSearchResult(
              id: id,
              name: name,
              source: ArtistSource.musicBrainz,
              disambiguation: disambiguation,
              type: type,
              country: country,
            );
          }).where((r) => r.id.isNotEmpty && r.name.isNotEmpty).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  Future<String?> searchArtistId(String artist) async {
    final query = artist.trim();
    if (query.isEmpty) return null;
    try {
      final response = await _dio.get(
        '/artist',
        queryParameters: {
          'query': 'artist:"$query"',
          'fmt': 'json',
          'limit': 1,
        },
        options: Options(validateStatus: (status) => status == 200),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map && data['artists'] is List) {
          final list = data['artists'] as List;
          if (list.isNotEmpty && list.first is Map) {
            return list.first['id']?.toString();
          }
        }
      }
    } catch (_) {}
    return null;
  }

  Future<String?> _getWikidataId(String artistId) async {
    try {
      final response = await _dio.get(
        '/artist/$artistId',
        queryParameters: {'inc': 'url-rels', 'fmt': 'json'},
        options: Options(validateStatus: (status) => status == 200),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map && data['relations'] is List) {
          final relations = data['relations'] as List;
          for (final rel in relations) {
            if (rel is Map && rel['type'] == 'wikidata') {
              final url = rel['url']?['resource']?.toString();
              if (url != null && url.contains('/wiki/')) {
                return url.split('/wiki/').last;
              }
            }
            if (rel is Map && rel['type'] == 'image') {
              final url = rel['url']?['resource']?.toString();
              if (url != null && url.startsWith('http')) {
                return url; // direct image url
              }
            }
          }
        }
      }
    } catch (_) {}
    return null;
  }

  Future<String?> _getWikidataImageUrl(String wikidataId) async {
    if (wikidataId.startsWith('http')) return wikidataId;
    try {
      final response = await _dio.get(
        'https://www.wikidata.org/w/api.php',
        queryParameters: {
          'action': 'wbgetentities',
          'ids': wikidataId,
          'props': 'claims',
          'format': 'json',
        },
        options: Options(validateStatus: (status) => status == 200),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final entities = data['entities'];
        if (entities is Map && entities[wikidataId] is Map) {
          final claims = entities[wikidataId]['claims'];
          if (claims is Map && claims['P18'] is List && claims['P18'].isNotEmpty) {
            final mainsnak = claims['P18'][0]['mainsnak'];
            final value = mainsnak?['datavalue']?['value']?.toString();
            if (value != null && value.isNotEmpty) {
              return _resolveCommonsFileUrl(value);
            }
          }
        }
      }
    } catch (_) {}
    return null;
  }

  Future<String?> _resolveCommonsFileUrl(String filename) async {
    try {
      final response = await _dio.get(
        'https://commons.wikimedia.org/w/api.php',
        queryParameters: {
          'action': 'query',
          'titles': 'File:$filename',
          'prop': 'imageinfo',
          'iiprop': 'url',
          'format': 'json',
        },
        options: Options(validateStatus: (status) => status == 200),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final pages = data['query']?['pages'];
        if (pages is Map) {
          for (final entry in pages.values) {
            if (entry is Map && entry['imageinfo'] is List && entry['imageinfo'].isNotEmpty) {
              final url = entry['imageinfo'][0]['url']?.toString();
              if (url != null && url.isNotEmpty) return url;
            }
          }
        }
      }
    } catch (_) {}
    return null;
  }

  Future<String?> fetchArtistImageUrl(String artistName) async {
    final artistId = await searchArtistId(artistName);
    if (artistId == null) return null;
    final wikidataOrImage = await _getWikidataId(artistId);
    if (wikidataOrImage == null) return null;
    return await _getWikidataImageUrl(wikidataOrImage);
  }

  Future<String?> fetchArtistImageUrlById(String artistId) async {
    if (artistId.trim().isEmpty) return null;
    final wikidataOrImage = await _getWikidataId(artistId);
    if (wikidataOrImage == null) return null;
    return await _getWikidataImageUrl(wikidataOrImage);
  }
}
