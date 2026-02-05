import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/features/settings/presentation/settings_providers.dart';
import 'package:jmusic/core/utils/scraper_utils.dart';

final lyricsServiceProvider = Provider((ref) {
  final proxySettings = ref.watch(proxySettingsProvider);
  return LyricsService(proxySettings);
});

class LyricsService {
  late final Dio _dio;
  late final Dio _fallbackDio;
  final ProxySettings proxySettings;

  LyricsService(this.proxySettings) {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://lrclib.net/api',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
        'Accept': 'application/json',
      },
    ));

    _fallbackDio = Dio(BaseOptions(
      baseUrl: 'https://tools.rangotec.com/api/anon',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
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

    (_fallbackDio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      client.idleTimeout = const Duration(seconds: 15);
      client.connectionTimeout = const Duration(seconds: 15);
      return client;
    };
  }

  // Use shared sanitizer for better results
  String _sanitizeQuery(String input) {
    return sanitizeTitleForSearch(input);
  }

  String _normalizeTimeBrackets(String lrc) {
    if (!lrc.contains('<') && !lrc.contains('>')) return lrc;
    return lrc.replaceAll('<', '[').replaceAll('>', ']');
  }

  bool _hasMeaningfulLyrics(String lrc) {
    final normalized = _normalizeTimeBrackets(lrc);
    final lines = normalized.split(RegExp(r'\r?\n'));
    final metaTag = RegExp(r'^\[(ti|ar|al|by|offset|re|ve):', caseSensitive: false);
    final timeTag = RegExp(r'\[(\d{1,2}):(\d{2})(?:[\.:](\d{1,3}))?(?:-\d+)?(?:\s*,\s*(\d{1,2}):(\d{2})(?:[\.:](\d{1,3}))?)?\]');
    final creditLine = RegExp(r'^(作词|作詞|作曲|编曲|編曲|词|曲|lyrics|lyricist|composer|arranger|arranged)\s*[:：]', caseSensitive: false);

    for (final raw in lines) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) continue;
      if (metaTag.hasMatch(trimmed)) continue;

      final text = trimmed.replaceAll(timeTag, '').trim();
      if (text.isEmpty) continue;
      if (creditLine.hasMatch(text)) continue;
      return true;
    }
    return false;
  }

  Future<String?> _fetchFromLrclib({
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
        final normalized = _normalizeTimeBrackets(synced);
        if (_hasMeaningfulLyrics(normalized)) return normalized;
      }
    }
    return null;
  }

  Future<String?> _fetchFromRangotec({
    required String title,
    String? artist,
  }) async {
    final response = await _fallbackDio.get(
      '/lrc',
      queryParameters: {
        'title': title,
        if (artist != null && artist.trim().isNotEmpty) 'artist': artist,
        'od': 'desc',
      },
      options: Options(validateStatus: (status) => status == 200),
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      if (data is Map && data['code'] == 200 && data['data'] is List) {
        final list = data['data'] as List;
        for (final item in list) {
          if (item is Map) {
            final lrc = item['lrc']?.toString();
            if (lrc != null && lrc.trim().isNotEmpty) {
              final normalized = _normalizeTimeBrackets(lrc);
              if (_hasMeaningfulLyrics(normalized)) return normalized;
              continue;
            }
          }
        }
      }
    }
    return null;
  }

  Future<String?> fetchLyrics({
    required String title,
    required String artist,
    String? album,
  }) async {
    print('Lyrics scraping - Incoming parameters: title="$title", artist="$artist", album="$album"');
    final cleanTitle = _sanitizeQuery(title).toLowerCase();
    final cleanArtist = _sanitizeQuery(artist).toLowerCase();
    final cleanAlbum = album == null ? null : _sanitizeQuery(album).toLowerCase();
    print('Lyrics scraping - Processed parameters: cleanTitle="$cleanTitle", cleanArtist="$cleanArtist", cleanAlbum="$cleanAlbum"');
    if (cleanTitle.isEmpty) return null;

    try {
      if (cleanArtist.isNotEmpty) {
        final fromLrclib = await _fetchFromLrclib(
          title: cleanTitle,
          artist: cleanArtist,
          album: cleanAlbum,
        );
        if (fromLrclib != null) return fromLrclib;
      }

      final fromRangotec = await _fetchFromRangotec(
        title: cleanTitle,
        artist: cleanArtist.isEmpty ? null : cleanArtist,
      );
      if (fromRangotec != null) return fromRangotec;
    } catch (e) {
      print('Lyrics fetch error: $e');
    }
    return null;
  }
}
