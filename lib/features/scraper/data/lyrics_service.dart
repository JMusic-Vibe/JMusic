import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/features/settings/presentation/settings_providers.dart';
import 'package:jmusic/core/services/preferences_service.dart';
import 'package:jmusic/core/utils/scraper_utils.dart';

import 'lyrics_sources/lrclib_service.dart';
import 'lyrics_sources/rangotec_service.dart';
import 'lyrics_sources/itunes_lyrics_service.dart';
import 'lyrics_sources/qq_music_lyrics_service.dart';

final lyricsServiceProvider = Provider((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  return LyricsService(ref, prefs);
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
  final Ref ref;
  final PreferencesService prefs;

  LyricsService(this.ref, this.prefs);

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

  String _sanitizeQuery(String input) => sanitizeTitleForSearch(input);

  String _normalizeTimeBrackets(String lrc) =>
      (!lrc.contains('<') && !lrc.contains('>'))
          ? lrc
          : lrc.replaceAll('<', '[').replaceAll('>', ']');

  bool _hasMeaningfulLyrics(String lrc) {
    final normalized = _normalizeTimeBrackets(lrc);
    final lines = normalized.split(RegExp(r'\r?\n'));
    final metaTag =
        RegExp(r'^\[(ti|ar|al|by|offset|re|ve):', caseSensitive: false);
    final timeTag = RegExp(
        r'\[(\d{1,2}):(\d{2})(?:[\.:](\d{1,3}))?(?:-\d+)?(?:\s*,\s*(\d{1,2}):(\d{2})(?:[\.:](\d{1,3}))?)?\]');
    final creditLine = RegExp(
        r'^(作词|作詞|作曲|编曲|編曲|词|曲|lyrics|lyricist|composer|arranger|arranged)\s*[:：]',
        caseSensitive: false);

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

  bool _isValidDuration(int? durationMs) {
    if (durationMs == null || durationMs <= 0 || durationMs < 30000) {
      return false;
    }
    return true;
  }

  Future<LyricsResult?> fetchLyrics({
    required String title,
    required String artist,
    String? album,
  }) async {
    final cleanTitle = _sanitizeQuery(title).toLowerCase();
    final cleanArtist = _sanitizeQuery(artist).toLowerCase();
    final cleanAlbum =
        album == null ? null : _sanitizeQuery(album).toLowerCase();
    if (cleanTitle.isEmpty) return null;

    try {
      final useItunes = prefs.scraperLyricsSourceItunes;
      final useLrclib = prefs.scraperLyricsSourceLrclib;
      final useRangotec = prefs.scraperLyricsSourceRangotec;
      final useQQ = prefs.scraperLyricsSourceQQMusic;

      if (useItunes) {
        final itunesSvc = ref.read(itunesLyricsServiceProvider);
        final results = await itunesSvc.searchItunesApi(
            title: cleanTitle, artist: cleanArtist);
        for (final item in results) {
          final trackUrl = item['trackViewUrl']?.toString();
          if (trackUrl == null) continue;
          final pages = await itunesSvc.fetchFromItunesPage(trackUrl: trackUrl);
          for (final p in pages) {
            final normalized = _normalizeTimeBrackets(p);
            if (_hasMeaningfulLyrics(normalized)) {
              final durationMs = _calcLrcDurationMs(normalized);
              if (!_isValidDuration(durationMs)) continue;
              return LyricsResult(
                  text: normalized,
                  durationMs: durationMs,
                  source: 'itunes',
                  title: item['trackName']?.toString(),
                  artist: item['artistName']?.toString(),
                  album: item['collectionName']?.toString());
            }
          }
        }
      }

      if (useQQ) {
        final qq = ref.read(qqLyricsServiceProvider);
        final list = await qq.search(
            title: cleanTitle, artist: cleanArtist, resultNum: 6, page: 1);
        for (final item in list) {
          final songmid = item['songmid']?.toString() ?? '';
          if (songmid.isEmpty) continue;
          final raw = await qq.fetchLyricBySongmid(songmid);
          if (raw == null) continue;
          final normalized = _normalizeTimeBrackets(raw);
          if (!_hasMeaningfulLyrics(normalized)) continue;
          final durationMs = _calcLrcDurationMs(normalized);
          if (!_isValidDuration(durationMs)) continue;
          return LyricsResult(
              text: normalized,
              durationMs: durationMs,
              source: 'qqmusic',
              title: item['songname']?.toString(),
              artist: item['singers']?.toString(),
              album: item['albumname']?.toString());
        }
      }

      if (useLrclib && cleanArtist.isNotEmpty) {
        final lr = ref.read(lrclibLyricsServiceProvider);
        final raw = await lr.fetch(
            title: cleanTitle, artist: cleanArtist, album: cleanAlbum);
        if (raw != null) {
          final normalized = _normalizeTimeBrackets(raw);
          if (_hasMeaningfulLyrics(normalized)) {
            final durationMs = _calcLrcDurationMs(normalized);
            if (!_isValidDuration(durationMs)) return null;
            return LyricsResult(
                text: normalized, durationMs: durationMs, source: 'lrclib');
          }
        }
      }

      if (useRangotec) {
        final rg = ref.read(rangotecLyricsServiceProvider);
        final list = await rg.search(
            title: cleanTitle,
            artist: cleanArtist.isEmpty ? null : cleanArtist);
        for (final item in list) {
          final lrc = item['lrc']?.toString();
          if (lrc == null || lrc.trim().isEmpty) continue;
          final normalized = _normalizeTimeBrackets(lrc);
          if (!_hasMeaningfulLyrics(normalized)) continue;
          final durationMs = _calcLrcDurationMs(normalized);
          if (!_isValidDuration(durationMs)) continue;
          return LyricsResult(
              text: normalized,
              durationMs: durationMs,
              source: 'rangotec',
              title: item['title']?.toString(),
              artist: item['artist']?.toString(),
              album: item['album']?.toString());
        }
      }
    } catch (e) {
      print('Lyrics fetch error: $e');
    }
    return null;
  }

  Future<List<LyricsResult>> fetchAllCandidates({
    required String title,
    required String artist,
    String? album,
  }) async {
    final candidates = <LyricsResult>[];
    final cleanTitle = _sanitizeQuery(title).toLowerCase();
    final cleanArtist = _sanitizeQuery(artist).toLowerCase();
    final cleanAlbum =
        album == null ? null : _sanitizeQuery(album).toLowerCase();
    if (cleanTitle.isEmpty) return candidates;

    final useItunes = prefs.scraperLyricsSourceItunes;
    final useLrclib = prefs.scraperLyricsSourceLrclib;
    final useRangotec = prefs.scraperLyricsSourceRangotec;
    final useQQ = prefs.scraperLyricsSourceQQMusic;

    if (useItunes) {
      final itunesSvc = ref.read(itunesLyricsServiceProvider);
      final results = await itunesSvc.searchItunesApi(
          title: cleanTitle, artist: cleanArtist);
      for (final item in results) {
        final trackUrl = item['trackViewUrl']?.toString();
        if (trackUrl == null) continue;
        final pages = await itunesSvc.fetchFromItunesPage(trackUrl: trackUrl);
        for (final p in pages) {
          final normalized = _normalizeTimeBrackets(p);
          if (_hasMeaningfulLyrics(normalized)) {
            final durationMs = _calcLrcDurationMs(normalized);
            if (!_isValidDuration(durationMs)) continue;
            candidates.add(LyricsResult(
                text: normalized,
                durationMs: durationMs,
                source: 'itunes',
                title: item['trackName']?.toString(),
                artist: item['artistName']?.toString(),
                album: item['collectionName']?.toString()));
            break;
          }
        }
      }
    }

    if (useLrclib && cleanArtist.isNotEmpty) {
      final lr = ref.read(lrclibLyricsServiceProvider);
      final raw = await lr.fetch(
          title: cleanTitle, artist: cleanArtist, album: cleanAlbum);
      if (raw != null) {
        final normalized = _normalizeTimeBrackets(raw);
        if (_hasMeaningfulLyrics(normalized)) {
          final durationMs = _calcLrcDurationMs(normalized);
          if (_isValidDuration(durationMs)) {
            candidates.add(LyricsResult(
                text: normalized, durationMs: durationMs, source: 'lrclib'));
          }
        }
      }
    }

    if (useRangotec) {
      final rg = ref.read(rangotecLyricsServiceProvider);
      final list = await rg.search(
          title: cleanTitle, artist: cleanArtist.isEmpty ? null : cleanArtist);
      for (final item in list) {
        final lrc = item['lrc']?.toString();
        if (lrc == null || lrc.trim().isEmpty) continue;
        final normalized = _normalizeTimeBrackets(lrc);
        if (!_hasMeaningfulLyrics(normalized)) continue;
        final durationMs = _calcLrcDurationMs(normalized);
        if (!_isValidDuration(durationMs)) continue;
        candidates.add(LyricsResult(
            text: normalized,
            durationMs: durationMs,
            source: 'rangotec',
            title: item['title']?.toString(),
            artist: item['artist']?.toString(),
            album: item['album']?.toString()));
      }
    }

    if (useQQ) {
      final qq = ref.read(qqLyricsServiceProvider);
      final list = await qq.search(
          title: cleanTitle, artist: cleanArtist, resultNum: 8, page: 1);
      for (final item in list) {
        final songmid = item['songmid']?.toString() ?? '';
        if (songmid.isEmpty) continue;
        final raw = await qq.fetchLyricBySongmid(songmid);
        if (raw == null) continue;
        final normalized = _normalizeTimeBrackets(raw);
        if (!_hasMeaningfulLyrics(normalized)) continue;
        final durationMs = _calcLrcDurationMs(normalized);
        if (!_isValidDuration(durationMs)) continue;
        candidates.add(LyricsResult(
            text: normalized,
            durationMs: durationMs,
            source: 'qqmusic',
            title: item['songname']?.toString(),
            artist: item['singers']?.toString(),
            album: item['albumname']?.toString()));
      }
    }

    return candidates;
  }
}
