import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'dart:async';
import 'dart:math';
import 'package:jmusic/core/services/database_service.dart';
import 'package:jmusic/core/services/audio_player_service.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';

// Home Data State
class HomeState {
  final List<Song> recentlyPlayed;
  final List<Song> recentlyImported;
  final List<Song> toBeScraped;
  final List<Song> forYou;

  const HomeState({
    this.recentlyPlayed = const [],
    this.recentlyImported = const [],
    this.toBeScraped = const [],
    this.forYou = const [],
  });

  HomeState copyWith({
    List<Song>? recentlyPlayed,
    List<Song>? recentlyImported,
    List<Song>? toBeScraped,
    List<Song>? forYou,
  }) {
    return HomeState(
      recentlyPlayed: recentlyPlayed ?? this.recentlyPlayed,
      recentlyImported: recentlyImported ?? this.recentlyImported,
      toBeScraped: toBeScraped ?? this.toBeScraped,
      forYou: forYou ?? this.forYou,
    );
  }
}

final homeControllerProvider = StateNotifierProvider<HomeController, AsyncValue<HomeState>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  final audioPlayerService = ref.watch(audioPlayerServiceProvider);
  return HomeController(dbService, audioPlayerService);
});

class HomeController extends StateNotifier<AsyncValue<HomeState>> {
  final DatabaseService _dbService;
  final AudioPlayerService _audioPlayerService;
  StreamSubscription? _indexSubscription;
  StreamSubscription? _dbSubscription;

  HomeController(this._dbService, this._audioPlayerService) : super(const AsyncValue.loading()) {
    loadHomeData();
    _setupListeners();
  }

  Future<void> _setupListeners() async {
    // 监听播放器索引变化以刷新“最近播放”
    _indexSubscription = _audioPlayerService.player.currentIndexStream.listen((index) {
      if (index != null && index >= 0) {
        _refreshRecentlyPlayed();
      }
    });

    // 移除全局数据库监听，避免每次数据库变化都重新加载整个首页
    // 改为在需要时手动刷新特定部分
  }

  Future<void> _refreshRecentlyPlayed() async {
    try {
      final db = await _dbService.db;
      final recentlyPlayed = await db.songs
          .filter()
          .lastPlayedIsNotNull()
          .sortByLastPlayedDesc()
          .limit(20)
          .findAll();

      // 更新状态中的最近播放列表
      state.whenData((currentState) {
        state = AsyncValue.data(currentState.copyWith(recentlyPlayed: recentlyPlayed));
      });
    } catch (e) {
      // 静默处理错误，不影响用户体验
      print('[HomeController] Failed to refresh recently played: $e');
    }
  }

  Future<void> _refreshRecentlyImported() async {
    try {
      final db = await _dbService.db;
      final recentlyImported = await db.songs
          .where()
          .sortByDateAddedDesc()
          .limit(20)
          .findAll();

      // 更新状态中的最近导入列表
      state.whenData((currentState) {
        state = AsyncValue.data(currentState.copyWith(recentlyImported: recentlyImported));
      });
    } catch (e) {
      print('[HomeController] Failed to refresh recently imported: $e');
    }
  }

  Future<void> _refreshToBeScraped() async {
    try {
      final db = await _dbService.db;
      final toBeScraped = await db.songs
          .filter()
          .artistIsEmpty()
          .or()
          .albumIsEmpty()
          .or() 
          .coverPathIsNull()
          .limit(50)
          .findAll();

      // 更新状态中的待刮削列表
      state.whenData((currentState) {
        state = AsyncValue.data(currentState.copyWith(toBeScraped: toBeScraped));
      });
    } catch (e) {
      print('[HomeController] Failed to refresh to be scraped: $e');
    }
  }

  Future<void> loadHomeData() async {
    try {
      state = const AsyncValue.loading();
      final db = await _dbService.db;

      final recentlyPlayed = await db.songs
          .filter()
          .lastPlayedIsNotNull()
          .sortByLastPlayedDesc()
          .limit(20)
          .findAll();

      final recentlyImported = await db.songs
          .where()
          .sortByDateAddedDesc()
          .limit(20)
          .findAll();

      // Simple heuristic for "To Be Scraped": missing artist, or missing album, or missing cover
      // This query might be slow if database is huge, but fine for local
      final toBeScraped = await db.songs
          .filter()
          .artistIsEmpty()
          .or()
          .albumIsEmpty()
          .or() 
          .coverPathIsNull()
          .limit(50) // Limit to avoid fetching too many
          .findAll();

        // Select up to 50 random songs from the entire library for "For You"
        final allSongs = await db.songs.where().findAll();
        allSongs.shuffle(Random());
        final forYou = allSongs.take(min(50, allSongs.length)).toList();

      state = AsyncValue.data(HomeState(
        recentlyPlayed: recentlyPlayed,
        recentlyImported: recentlyImported,
        toBeScraped: toBeScraped,
        forYou: forYou,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> refreshRecentlyImported() async {
    await _refreshRecentlyImported();
  }

  Future<void> refreshToBeScraped() async {
    await _refreshToBeScraped();
  }

  Future<void> refreshAll() async {
    await loadHomeData();
  }

  Future<void> _refreshForYou() async {
    try {
      final db = await _dbService.db;
      final allSongs = await db.songs.where().findAll();
      allSongs.shuffle(Random());
      final forYou = allSongs.take(min(50, allSongs.length)).toList();

      // 更新状态中的为你推荐列表
      state.whenData((currentState) {
        state = AsyncValue.data(currentState.copyWith(forYou: forYou));
      });
    } catch (e) {
      print('[HomeController] Failed to refresh for you: $e');
    }
  }

  @override
  void dispose() {
    _indexSubscription?.cancel();
    super.dispose();
  }
}

