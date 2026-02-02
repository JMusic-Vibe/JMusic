import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/services/database_service.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';
import 'package:jmusic/features/scraper/data/musicbrainz_service.dart';
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
    final scraperController = _ref.read(scraperControllerProvider);
    final dbService = _ref.read(databaseServiceProvider);
    final db = await dbService.db;
    
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
          final results = await mbService.searchRecording(song.title, artistForQuery, song.album);
          if (results.isNotEmpty) {
             final best = results.first;
             String? coverUrl;
             if (best.releaseId != null) {
               coverUrl = await mbService.getCoverArtUrl(best.releaseId!);
             }
             
             int? year;
             if (best.date != null) {
                year = int.tryParse(best.date!.split('-').first);
             }

             await scraperController.updateSongMetadata(
               songId,
               title: best.title,
               artist: best.artist,
               album: best.album,
               mbId: best.id,
               coverUrl: coverUrl,
               year: year
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
}

final batchScraperProvider = StateNotifierProvider<BatchScraperNotifier, BatchScraperState>((ref) {
  return BatchScraperNotifier(ref);
});

