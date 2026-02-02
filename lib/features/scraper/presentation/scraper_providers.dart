import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:jmusic/core/services/database_service.dart';
import 'package:jmusic/core/services/audio_player_service.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';
import 'package:jmusic/core/utils/artist_parser.dart';

final unscrapedSongsProvider = FutureProvider<List<Song>>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  final isar = await dbService.db;
  
  // 查找 musicBrainzId 为 null 或空的歌曲
  // 也可以加一个 isScraped 字段，目前先用 musicBrainzId 判断
  return isar.songs.filter()
      .musicBrainzIdIsNull()
      .or()
      .musicBrainzIdIsEmpty()
      .findAll();
});

final scraperControllerProvider = Provider((ref) => ScraperController(ref));

class ScraperController {
  final Ref _ref;

  ScraperController(this._ref);

  Future<void> updateSongMetadata(int songId, {
    required String title,
    required String artist,
    required String album,
    String? mbId,
    String? coverUrl,
    int? year,
  }) async {
    final dbService = _ref.read(databaseServiceProvider);
    final isar = await dbService.db;

    await isar.writeTxn(() async {
      final song = await isar.songs.get(songId);
      if (song != null) {
        song.title = title;
        // parse artists and set primary for backward compatibility
        final parsed = parseArtists(artist);
        song.artist = parsed.isNotEmpty ? parsed.first : artist;
        song.artists = parsed;
        song.album = album;
        song.musicBrainzId = mbId;
        song.year = year;
        
        // 如果有封面URL，这里需要后续下载逻辑，目前先存字符串
        if (coverUrl != null) {
          print('[ScraperController] Updating DB with coverUrl: $coverUrl');
          // 这里可以触发一个后台任务去下载封面
          // 暂时我们假设 coverPath 可以是 url (配合 CachedNetworkImage)
          song.coverPath = coverUrl; 
        } else {
          print('[ScraperController] No coverUrl provided. Existing path: ${song.coverPath}');
        }
        
        await isar.songs.put(song);
        
        // Notify AudioPlayerService
        final playerService = _ref.read(audioPlayerServiceProvider);
        await playerService.updateMetadata(song);
      }
    });

    _ref.invalidate(unscrapedSongsProvider);
  }
}

// Progress tracking for batch scraping
class ScrapeProgress {
  final int total;
  final int done;
  final String? currentTitle;
  final bool isRunning;
  final bool cancelled;

  ScrapeProgress({this.total = 0, this.done = 0, this.currentTitle, this.isRunning = false, this.cancelled = false});

  ScrapeProgress copyWith({int? total, int? done, String? currentTitle, bool? isRunning, bool? cancelled}) {
    return ScrapeProgress(
      total: total ?? this.total,
      done: done ?? this.done,
      currentTitle: currentTitle ?? this.currentTitle,
      isRunning: isRunning ?? this.isRunning,
      cancelled: cancelled ?? this.cancelled,
    );
  }
}

class ScrapeProgressNotifier extends StateNotifier<ScrapeProgress> {
  ScrapeProgressNotifier(): super(ScrapeProgress());

  void start(int total) {
    state = ScrapeProgress(total: total, done: 0, isRunning: true, cancelled: false);
  }

  void updateCurrent(String? title) {
    state = state.copyWith(currentTitle: title);
  }

  void increment() {
    state = state.copyWith(done: state.done + 1);
  }

  void cancel() {
    state = state.copyWith(cancelled: true, isRunning: false);
  }

  void finish() {
    state = state.copyWith(isRunning: false);
  }
}

final scrapeProgressProvider = StateNotifierProvider<ScrapeProgressNotifier, ScrapeProgress>((ref) {
  return ScrapeProgressNotifier();
});

