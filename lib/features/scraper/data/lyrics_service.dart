import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/features/settings/presentation/settings_providers.dart';
import 'package:jmusic/core/services/preferences_service.dart';
import 'package:jmusic/core/utils/scraper_utils.dart';

final lyricsServiceProvider = Provider((ref) {
  final proxySettings = ref.watch(proxySettingsProvider);
  final prefs = ref.watch(preferencesServiceProvider);
  return LyricsService(proxySettings, prefs);
});

class LyricsResult {
  final String? text;
  final int? durationMs;
  final String? source; // e.g. 'lrclib', 'rangotec', 'itunes'
  final String? title;
  final String? artist;
  final String? album;
  LyricsResult({
    this.text,
    this.durationMs,
    this.source,
    this.title,
    this.artist,
    this.album,
  });
}

class LyricsService {
  late final Dio _dio;
  late final Dio _fallbackDio;
  final ProxySettings proxySettings;
  final PreferencesService prefs;

  LyricsService(this.proxySettings, this.prefs) {
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

  int? _calcLrcDurationMs(String lrc) {
    final timeTag = RegExp(
        r'\[(\d{1,2}):(\d{2})(?:[\.:](\d{1,3}))?(?:,(\d{1,2}):(\d{2})(?:[\.:](\d{1,3}))?)?\]');
    final times = <int>[];
    for (final m in timeTag.allMatches(lrc)) {
      final startMs = _timeToMilliseconds(
        m.group(1) ?? '0',
        m.group(2) ?? '0',
        m.group(3),
      );
      final endMs = _timeToMilliseconds(
        m.group(4) ?? m.group(1) ?? '0',
        m.group(5) ?? m.group(2) ?? '0',
        m.group(6) ?? m.group(3),
      );
      times.add(startMs);
      times.add(endMs);
    }
    return _pickDurationMs(times);
  }

  int? _pickDurationMs(List<int> times) {
    if (times.isEmpty) return null;
    times.sort();
    final maxMs = times.last;
    if (times.length < 2) return maxMs > 0 ? maxMs : null;
    final secondMax = times[times.length - 2];
    // Ignore exaggerated tail timestamps (e.g., last line stretched for sync).
    if (maxMs - secondMax > 60000) {
      return secondMax > 0 ? secondMax : null;
    }
    return maxMs > 0 ? maxMs : null;
  }

  int _timeToMilliseconds(String min, String sec, String? frac) {
    final minutes = int.tryParse(min) ?? 0;
    final seconds = int.tryParse(sec) ?? 0;
    final milliRaw = frac?.padRight(3, '0') ?? '0';
    final millis = int.tryParse(milliRaw) ?? 0;
    return minutes * 60 * 1000 + seconds * 1000 + millis;
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
    final results = await _fetchAllFromRangotec(title: title, artist: artist);
    if (results.isEmpty) return null;
    return results.first.text;
  }

  Future<List<LyricsResult>> _fetchAllFromRangotec({
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

    final candidates = <LyricsResult>[];
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      if (data is Map && data['code'] == 200 && data['data'] is List) {
        final list = data['data'] as List;
        for (final item in list) {
          if (item is Map) {
            final lrc = item['lrc']?.toString();
            if (lrc == null || lrc.trim().isEmpty) continue;
            final normalized = _normalizeTimeBrackets(lrc);
            if (!_hasMeaningfulLyrics(normalized)) continue;
            candidates.add(
              LyricsResult(
                text: normalized,
                durationMs: _calcLrcDurationMs(normalized),
                source: 'rangotec',
                title: item['title']?.toString(),
                artist: item['artist']?.toString(),
                album: item['album']?.toString(),
              ),
            );
          }
        }
      }
    }
    return candidates;
  }

  Future<String?> _fetchFromItunes({
    required String title,
    required String artist,
  }) async {
    final results = await _fetchAllFromItunes(title: title, artist: artist);
    if (results.isEmpty) return null;
    return results.first.text;
  }

  Future<List<LyricsResult>> _fetchAllFromItunes({
    required String title,
    required String artist,
  }) async {
    final candidates = <LyricsResult>[];
    try {
      final query = '$artist $title'.trim();
      if (query.isEmpty) return candidates;

      final resp = await _fallbackDio.get(
        'https://itunes.apple.com/search',
        queryParameters: {
          'term': query,
          'entity': 'song',
          'limit': 5,
        },
        options: Options(validateStatus: (s) => s == 200),
      );

      if (resp.statusCode != 200 || resp.data == null) return candidates;
      // resp.data can be Map, List or String depending on Dio parsing
      dynamic parsed = resp.data;
      if (parsed is String) {
        try {
          parsed = jsonDecode(parsed);
        } catch (_) {
          // leave as string
        }
      }
      List results;
      if (parsed is Map && parsed['results'] is List) {
        results = parsed['results'] as List;
      } else if (parsed is List) {
        results = parsed as List;
      } else {
        return candidates;
      }
      if (results.isEmpty) return candidates;

      for (final item in results) {
        if (item is Map) {
          final trackUrl = item['trackViewUrl']?.toString();
          if (trackUrl == null) continue;

          final pageResp = await _fallbackDio.get<String>(
            trackUrl,
            options: Options(
                responseType: ResponseType.plain, validateStatus: (s) => s == 200),
          );
          final html = pageResp.data ?? '';
          if (html.isEmpty) continue;

          // Try several heuristics to extract lyrics from Apple Music / iTunes page
          final patterns = [
            RegExp(r'<section[^>]*class="lyrics"[^>]*>([\s\S]*?)<\/section>',
                caseSensitive: false),
            RegExp(r'<div[^>]*class="songs-lyrics"[^>]*>([\s\S]*?)<\/div>',
                caseSensitive: false),
            RegExp(r'data-lyrics="([^"]+)"', caseSensitive: false),
            RegExp(r'"lyrics"\s*:\s*"([^"]+)"', caseSensitive: false),
          ];

          for (final pat in patterns) {
            final m = pat.firstMatch(html);
            if (m == null) continue;
            var found = m.groupCount >= 1 ? m.group(1) ?? '' : m.group(0) ?? '';
            if (found.trim().isEmpty) continue;

            // Strip HTML tags if present
            found = found.replaceAll(RegExp(r'<[^>]*>'), '');
            // Basic unescape
            found = found
                .replaceAll('&amp;', '&')
                .replaceAll('&lt;', '<')
                .replaceAll('&gt;', '>')
                .replaceAll('&quot;', '"')
                .replaceAll('&#39;', "'");

            final normalized = _normalizeTimeBrackets(found);
            if (_hasMeaningfulLyrics(normalized)) {
              candidates.add(
                LyricsResult(
                  text: normalized,
                  durationMs: _calcLrcDurationMs(normalized),
                  source: 'itunes',
                  title: item['trackName']?.toString(),
                  artist: item['artistName']?.toString(),
                  album: item['collectionName']?.toString(),
                ),
              );
              break;
            }
          }
        }
      }
    } catch (e) {
      print('iTunes fetch error: $e');
    }
    return candidates;
  }

  Future<LyricsResult?> fetchLyrics({
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
      final useItunes = prefs.scraperLyricsSourceItunes;
      final useLrclib = prefs.scraperLyricsSourceLrclib;
      final useRangotec = prefs.scraperLyricsSourceRangotec;

      if (useItunes) {
        final fromItunes = await _fetchFromItunes(title: cleanTitle, artist: cleanArtist);
        if (fromItunes != null) return LyricsResult(text: fromItunes, durationMs: _calcLrcDurationMs(fromItunes), source: 'itunes');
      }

      if (useLrclib && cleanArtist.isNotEmpty) {
        final fromLrclib = await _fetchFromLrclib(
          title: cleanTitle,
          artist: cleanArtist,
          album: cleanAlbum,
        );
        if (fromLrclib != null) return LyricsResult(text: fromLrclib, durationMs: _calcLrcDurationMs(fromLrclib), source: 'lrclib');
      }

      if (useRangotec) {
        final fromRangotec = await _fetchFromRangotec(
          title: cleanTitle,
          artist: cleanArtist.isEmpty ? null : cleanArtist,
        );
        if (fromRangotec != null) return LyricsResult(text: fromRangotec, durationMs: _calcLrcDurationMs(fromRangotec), source: 'rangotec');
      }
    } catch (e) {
      print('Lyrics fetch error: $e');
    }
    return null;
  }

  /// Fetch lyrics from all enabled sources and return candidates.
  Future<List<LyricsResult>> fetchAllCandidates({
    required String title,
    required String artist,
    String? album,
  }) async {
    final candidates = <LyricsResult>[];
    try {
      final cleanTitle = _sanitizeQuery(title).toLowerCase();
      final cleanArtist = _sanitizeQuery(artist).toLowerCase();
      final cleanAlbum = album == null ? null : _sanitizeQuery(album).toLowerCase();
      if (cleanTitle.isEmpty) return candidates;

      final useItunes = prefs.scraperLyricsSourceItunes;
      final useLrclib = prefs.scraperLyricsSourceLrclib;
      final useRangotec = prefs.scraperLyricsSourceRangotec;

      if (useItunes) {
        final itList =
            await _fetchAllFromItunes(title: cleanTitle, artist: cleanArtist);
        candidates.addAll(itList);
      }

      if (useLrclib && cleanArtist.isNotEmpty) {
        final lr = await _fetchFromLrclib(
            title: cleanTitle, artist: cleanArtist, album: cleanAlbum);
        if (lr != null) {
          candidates.add(LyricsResult(
              text: lr,
              durationMs: _calcLrcDurationMs(lr),
              source: 'lrclib'));
        }
      }

      if (useRangotec) {
        final rgList = await _fetchAllFromRangotec(
            title: cleanTitle,
            artist: cleanArtist.isEmpty ? null : cleanArtist);
        candidates.addAll(rgList);
      }
    } catch (e) {
      print('fetchAllCandidates error: $e');
    }
    return candidates;
  }
}
