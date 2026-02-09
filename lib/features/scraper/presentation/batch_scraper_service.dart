import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/services/database_service.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';
import 'package:jmusic/features/scraper/data/track_sources/musicbrainz_service.dart';
import 'package:jmusic/features/scraper/data/track_sources/itunes_service.dart';
import 'package:jmusic/features/scraper/data/lyrics_service.dart';
import 'package:jmusic/features/scraper/data/track_sources/qq_music_service.dart';
import 'package:jmusic/features/scraper/domain/musicbrainz_result.dart';
import 'package:jmusic/features/scraper/domain/scrape_result.dart';
import 'package:jmusic/features/scraper/presentation/scraper_providers.dart';
import 'package:jmusic/features/player/presentation/player_providers.dart';
import 'package:jmusic/features/home/presentation/home_controller.dart';
import 'package:jmusic/core/services/preferences_service.dart';

class BatchScraperState {
  final bool isRunning;
  final bool isMinimized;
  final int total;
  final int done;
  final int successCount;
  final int failCount;
  final String currentTitle;
  final Set<int> scrapingSongIds; // 用于互斥锁定
  final bool cancelled;
  final bool showResult;

  const BatchScraperState({
    this.isRunning = false,
    this.isMinimized = false,
    this.total = 0,
    this.done = 0,
    this.successCount = 0,
    this.failCount = 0,
    this.currentTitle = '',
    this.scrapingSongIds = const {},
    this.cancelled = false,
    this.showResult = false,
  });

  BatchScraperState copyWith({
    bool? isRunning,
    bool? isMinimized,
    int? total,
    int? done,
    int? successCount,
    int? failCount,
    String? currentTitle,
    Set<int>? scrapingSongIds,
    bool? cancelled,
    bool? showResult,
  }) {
    return BatchScraperState(
      isRunning: isRunning ?? this.isRunning,
      isMinimized: isMinimized ?? this.isMinimized,
      total: total ?? this.total,
      done: done ?? this.done,
      successCount: successCount ?? this.successCount,
      failCount: failCount ?? this.failCount,
      currentTitle: currentTitle ?? this.currentTitle,
      scrapingSongIds: scrapingSongIds ?? this.scrapingSongIds,
      cancelled: cancelled ?? this.cancelled,
      showResult: showResult ?? this.showResult,
    );
  }
}

class BatchScraperNotifier extends StateNotifier<BatchScraperState> {
  final Ref _ref;

  BatchScraperNotifier(this._ref) : super(const BatchScraperState());

  Future<void> startBatchScrape(List<int> songIds) async {
    if (state.isRunning) return; // 互斥：已有任务在运行

    state = BatchScraperState(
      isRunning: true,
      isMinimized: false,
      total: songIds.length,
      done: 0,
      successCount: 0,
      failCount: 0,
      scrapingSongIds: songIds.toSet(),
    );

    _runScrapeLoop(songIds);
  }

  Future<void> startSingleScrape(int songId) async {
      // 全局互斥
      if (state.isRunning) {
          // 如果已经在运行，就不允许开始新的任务
          // 实际应用中可能需要抛出异常或返回 false 给 UI 提示
          return;
      }
      await startBatchScrape([songId]);
  }

  /// Start a single-song lyrics-only scrape. This ignores the global
  /// `scraperLyricsEnabled` flag (user initiated), but respects per-source
  /// source toggles (lrclib/rangotec/itunes).
  Future<void> startSingleLyricsScrape(int songId) async {
    if (state.isRunning) return;

    state = BatchScraperState(
      isRunning: true,
      isMinimized: false,
      total: 1,
      done: 0,
      successCount: 0,
      failCount: 0,
      scrapingSongIds: {songId},
    );

    await _runLyricsScrape(songId);

    state = state.copyWith(
      isRunning: false,
      scrapingSongIds: {},
      done: 1,
      showResult: true,
    );

    _ref.invalidate(unscrapedSongsProvider);
    _ref.refresh(queueProvider);
    _ref.refresh(currentMediaItemProvider);
  }

  Future<void> startBatchLyricsScrape(List<int> songIds) async {
    if (state.isRunning) return;

    state = BatchScraperState(
      isRunning: true,
      isMinimized: false,
      total: songIds.length,
      done: 0,
      successCount: 0,
      failCount: 0,
      scrapingSongIds: songIds.toSet(),
    );

    int success = 0;
    int fail = 0;
    for (int i = 0; i < songIds.length; i++) {
      if (state.cancelled) break;
      final id = songIds[i];
      state = state.copyWith(done: i, currentTitle: '');
      try {
        await _runLyricsScrape(id);
        // _runLyricsScrape updates success/fail inside; but we also track here
        // Note: _runLyricsScrape increments counters via state updates.
        success = state.successCount;
        fail = state.failCount;
      } catch (e) {
        print('Batch lyrics scrape error for $id: $e');
        fail++;
        state = state.copyWith(failCount: fail);
      }
    }

    state = state.copyWith(
      isRunning: false,
      scrapingSongIds: {},
      done: songIds.length,
      successCount: success,
      failCount: fail,
      showResult: true,
    );

    _ref.invalidate(unscrapedSongsProvider);
    _ref.refresh(queueProvider);
    _ref.refresh(currentMediaItemProvider);
  }

  Future<void> _runLyricsScrape(int songId) async {
    final lyricsService = _ref.read(lyricsServiceProvider);
    final prefs = _ref.read(preferencesServiceProvider);
    final scraperController = _ref.read(scraperControllerProvider);
    final dbService = _ref.read(databaseServiceProvider);
    final db = await dbService.db;

    try {
      final song = await db.songs.get(songId);
      if (song == null) return;

      // Choose artist string according to preference
      final usePrimary = _ref.read(preferencesServiceProvider).scraperUsePrimaryArtist;
      final artistForQuery = usePrimary ? song.artist : (song.artists.isNotEmpty ? song.artists.join(' / ') : song.artist);

      final lyricsRes = await lyricsService.fetchLyrics(
        title: song.title,
        artist: artistForQuery,
        album: song.album,
      );

      if (lyricsRes?.text != null && lyricsRes!.text!.trim().isNotEmpty) {
        await scraperController.updateSongMetadata(
          songId,
          title: song.title,
          artist: artistForQuery,
          album: song.album,
          lyrics: lyricsRes.text,
          lyricsDurationMs: lyricsRes.durationMs,
        );
        state = state.copyWith(successCount: state.successCount + 1);
      } else {
        state = state.copyWith(failCount: state.failCount + 1);
      }
    } catch (e) {
      print('Error scraping lyrics for $songId: $e');
      state = state.copyWith(failCount: state.failCount + 1);
    }
  }

  void cancel() {
    state = state.copyWith(cancelled: true);
  }

  void minimize() {
    state = state.copyWith(isMinimized: true);
  }

  void maximize() {
    state = state.copyWith(isMinimized: false);
  }

  void closeResultDialog() {
    state = const BatchScraperState(); // Reset
  }

  Future<void> _runScrapeLoop(List<int> songIds) async {
    final mbService = _ref.read(musicBrainzServiceProvider);
    final itunesService = _ref.read(itunesServiceProvider);
    final lyricsService = _ref.read(lyricsServiceProvider);
    final prefs = _ref.read(preferencesServiceProvider);
    final useMb = prefs.scraperSourceMusicBrainz;
    final useItunes = prefs.scraperSourceItunes;
    final useQq = prefs.scraperSourceQQMusic;
    final lyricsEnabled = prefs.scraperLyricsEnabled;
    final scraperController = _ref.read(scraperControllerProvider);
    final dbService = _ref.read(databaseServiceProvider);
    final db = await dbService.db;

    // Removed requirement that at least one scraper source must be enabled.
    // If no sources enabled, the loop will simply try nothing and mark failures accordingly.
    
    int success = 0;
    int fail = 0;

    for (int i = 0; i < songIds.length; i++) {
      if (state.cancelled) break;
      final songId = songIds[i];

      final song = await db.songs.get(songId);
      
      // 更新当前状态
      state = state.copyWith(
        currentTitle: song?.title ?? 'Unknown',
        done: i, // 当前完成了 i 个(即第 i+1 个正在进行)
        successCount: success,
        failCount: fail,
      );

      bool scraped = false;
      if (song != null) {
        try {
          // Decide which artist string to use based on user preference
          final usePrimary = _ref.read(preferencesServiceProvider).scraperUsePrimaryArtist;
          final artistForQuery = usePrimary ? song.artist : (song.artists.isNotEmpty ? song.artists.join(' / ') : song.artist);
          final normalizedArtist = _normalizeQueryParam(artistForQuery);
          final normalizedAlbum = _normalizeQueryParam(song.album);
          ScrapeResult? bestResult;
          String? coverUrl;
          String? mbId;
          int? year;

            final mbResults = useMb
              ? await mbService.searchRecording(song.title, normalizedArtist, normalizedAlbum)
              : <MusicBrainzResult>[];
          if (mbResults.isNotEmpty) {
            final best = _pickMusicBrainzResult(mbResults, song.duration);
            if (best != null) {
              bestResult = ScrapeResult(
                source: ScrapeSource.musicBrainz,
                id: best.id,
                title: best.title,
                artist: best.artist,
                album: best.album,
                date: best.date,
                releaseId: best.releaseId,
                durationMs: best.durationMs,
              );
              if (best.releaseId != null) {
                coverUrl = await mbService.getCoverArtUrl(best.releaseId!);
              }
              mbId = best.id;
            }
          }

          if (bestResult == null && useItunes) {
            final itResults = await itunesService.searchTrack(
              song.title,
              artist: normalizedArtist,
              album: normalizedAlbum,
            );
            if (itResults.isNotEmpty) {
              bestResult = _pickItunesResult(itResults, song.duration);
              if (bestResult != null) {
                coverUrl = bestResult.coverUrl;
              }
            }
          }
          // Try QQ Music if still not found
          if (bestResult == null && useQq) {
            final qqService = _ref.read(qqMusicServiceProvider);
            final qqResults = await qqService.searchTrack(
              song.title,
              artist: normalizedArtist,
              album: normalizedAlbum,
            );
            if (qqResults.isNotEmpty) {
              final pick = _pickItunesResult(qqResults, song.duration);
              if (pick != null) {
                bestResult = pick;
                coverUrl = pick.coverUrl;
              }
            }
          }

          if (bestResult != null) {
            if (bestResult.date != null) {
              year = int.tryParse(bestResult.date!.split('-').first);
            }
            final lyricsRes = lyricsEnabled
                ? await lyricsService.fetchLyrics(
                    title: bestResult.title,
                    artist: bestResult.artist,
                    album: bestResult.album,
                  )
                : null;

            await scraperController.updateSongMetadata(
              songId,
              title: bestResult.title,
              artist: bestResult.artist,
              album: bestResult.album,
              mbId: mbId,
              coverUrl: coverUrl,
              year: year,
              lyrics: lyricsRes?.text,
              lyricsDurationMs: lyricsRes?.durationMs,
            );
            scraped = true;
          }
        } catch (e) {
          print('Error scraping song $songId: $e');
        }
      }

      if (scraped) {
        success++;
      } else {
        fail++;
      }
    }
    
    state = state.copyWith(
      isRunning: false,
      scrapingSongIds: {},
      done: state.total, // 完成
      successCount: success,
      failCount: fail,
      showResult: true, // 显示结果
    );

    _ref.invalidate(unscrapedSongsProvider);
    // 刷新播放相关的 Provider，以同步更新队列和当前歌曲信息
    _ref.refresh(queueProvider);
    _ref.refresh(currentMediaItemProvider);
    
    // 刷新首页的待刮削部分
    try {
      _ref.read(homeControllerProvider.notifier).refreshToBeScraped();
    } catch (e) {
      print('Failed to refresh home to be scraped: $e');
    }
  }

  String? _normalizeQueryParam(String? input) {
    if (input == null) return null;
    final v = input.trim();
    if (v.isEmpty) return null;
    final lower = v.toLowerCase();
    if (lower.contains('unknown') || lower.contains('unknow')) return null;
    if (v.contains('未知')) return null;
    return v;
  }

  MusicBrainzResult? _pickMusicBrainzResult(List<MusicBrainzResult> results, double? localDurationSeconds) {
    if (results.isEmpty) return null;
    if (!_hasValidDuration(localDurationSeconds)) return results.first;

    final close = results.where((r) => _isDurationClose(localDurationSeconds!, r.durationMs)).toList();
    if (close.isNotEmpty) return close.first;
    return null;
  }

  ScrapeResult? _pickItunesResult(List<ScrapeResult> results, double? localDurationSeconds) {
    if (results.isEmpty) return null;
    if (!_hasValidDuration(localDurationSeconds)) return results.first;

    final close = results.where((r) => _isDurationClose(localDurationSeconds!, r.durationMs)).toList();
    if (close.isNotEmpty) return close.first;
    return null;
  }

  bool _hasValidDuration(double? seconds) => seconds != null && seconds > 0;

  bool _isDurationClose(double localSeconds, int? externalMs) {
    if (externalMs == null || externalMs <= 0) return true;
    if (localSeconds <= 0) return true;

    final externalSeconds = externalMs / 1000.0;
    final diff = (localSeconds - externalSeconds).abs();
    final tolerance = math.max(8.0, localSeconds * 0.15);
    return diff <= tolerance;
  }
}

final batchScraperProvider = StateNotifierProvider<BatchScraperNotifier, BatchScraperState>((ref) {
  return BatchScraperNotifier(ref);
});

