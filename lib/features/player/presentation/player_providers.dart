import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:jmusic/core/services/audio_player_service.dart';
import 'package:jmusic/core/services/preferences_service.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';

enum LyricsDisplayMode { off, compact, full }

// ==================== 播放状态====================

final isPlayingProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  // Listen to AudioHandler playbackState instead of direct player stream
  // This ensures we capture system events even if native player stream is buggy
  return service.audioHandler.playbackState.map((state) => state.playing);
});

final positionProvider = StreamProvider<Duration>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  // Continue using player position stream (usually works or interpolates)
  return service.player.positionStream;
});

final durationProvider = StreamProvider<Duration?>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  // Duration is static metadata mostly
  return service.player.durationStream;
});

final bufferingProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  // Use handler state processingState
  return service.audioHandler.playbackState.map((state) => 
    state.processingState == AudioProcessingState.buffering ||
    state.processingState == AudioProcessingState.loading
  );
});

// ==================== 播放模式 ====================

final shuffleModeProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.player.shuffleModeEnabledStream;
});

final loopModeProvider = StreamProvider<LoopMode>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.player.loopModeStream;
});

// ==================== 当前歌曲和队 ====================

final currentMediaItemProvider = StreamProvider<MediaItem?>((ref) async* {
  final service = ref.watch(audioPlayerServiceProvider);
  // 等待AudioService初始化
  final handler = await service.audioHandlerAsync;
  
  // 从player的sequenceState获取，这样更可靠
  await for (final sequenceState in service.player.sequenceStateStream) {
    if (sequenceState != null && sequenceState.currentSource != null) {
      final mediaItem = sequenceState.currentSource!.tag as MediaItem?;
      yield mediaItem;
    } else {
      yield null;
    }
  }
});

final currentSongProvider = StreamProvider<Song?>((ref) async* {
  final service = ref.watch(audioPlayerServiceProvider);
  // 等待AudioService初始化
  final handler = await service.audioHandlerAsync;
  
  await for (final mediaItem in handler.mediaItem) {
    if (mediaItem != null) {
      final song = handler.getSongById(mediaItem.id);
      yield song;
    } else {
      yield null;
    }
  }
});

final queueProvider = StreamProvider<List<MediaItem>>((ref) async* {
  final service = ref.watch(audioPlayerServiceProvider);
  // 等待AudioService初始化
  final handler = await service.audioHandlerAsync;
  await for (final queue in handler.queue) {
    yield queue;
  }
});

final queueSongsProvider = Provider<List<Song>>((ref) {
  final queueAsync = ref.watch(queueProvider);
  final service = ref.read(audioPlayerServiceProvider);
  
  return queueAsync.when(
    data: (queue) {
      return queue
          .map((item) => service.audioHandler.getSongById(item.id))
          .whereType<Song>()
          .toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// ==================== 歌词显示模式 ====================

final lyricsDisplayModeProvider = StateNotifierProvider<LyricsDisplayModeNotifier, LyricsDisplayMode>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  return LyricsDisplayModeNotifier(prefs);
});

class LyricsDisplayModeNotifier extends StateNotifier<LyricsDisplayMode> {
  final PreferencesService _prefs;

  LyricsDisplayModeNotifier(this._prefs) : super(_fromPrefs(_prefs.lyricsDisplayMode));

  static LyricsDisplayMode _fromPrefs(String value) {
    switch (value) {
      case 'compact':
        return LyricsDisplayMode.compact;
      case 'full':
        return LyricsDisplayMode.full;
      case 'off':
      default:
        return LyricsDisplayMode.off;
    }
  }

  static String _toPrefs(LyricsDisplayMode mode) {
    switch (mode) {
      case LyricsDisplayMode.compact:
        return 'compact';
      case LyricsDisplayMode.full:
        return 'full';
      case LyricsDisplayMode.off:
      default:
        return 'off';
    }
  }

  Future<void> setMode(LyricsDisplayMode mode) async {
    state = mode;
    await _prefs.setLyricsDisplayMode(_toPrefs(mode));
  }

  Future<void> cycle() async {
    final next = switch (state) {
      LyricsDisplayMode.off => LyricsDisplayMode.compact,
      LyricsDisplayMode.compact => LyricsDisplayMode.full,
      LyricsDisplayMode.full => LyricsDisplayMode.off,
    };
    await setMode(next);
  }
}

// ==================== 播放器控制器 ====================

final playerControllerProvider = Provider<PlayerController>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return PlayerController(service, ref);
});

class PlayerController {
  final AudioPlayerService _service;
  final Ref _ref;

  PlayerController(this._service, this._ref);

  // 基本控制
  Future<void> play() => _service.play();
  Future<void> pause() => _service.pause();
  Future<void> playPause() => _service.playPause();
  Future<void> togglePlay() => _service.playPause();  // 添加别名方法
  Future<void> stop() => _service.stop();
  Future<void> seek(Duration position) => _service.seek(position);
  
  // 导航
  Future<void> next() => _service.next();  // 添加简短别名
  Future<void> previous() => _service.previous();  // 添加简短别名
  Future<void> skipToNext() => _service.next();
  Future<void> skipToPrevious() => _service.previous();
  Future<void> skipToIndex(int index) => _service.skipToIndex(index);
  
  // 播放模式
  Future<void> toggleShuffle() async {
    final currentShuffle = await _ref.read(shuffleModeProvider.future);
    await _service.setShuffleMode(!currentShuffle);
  }
  
  Future<void> toggleLoopMode() async {
    final currentLoop = await _ref.read(loopModeProvider.future);
    LoopMode nextMode;
    switch (currentLoop) {
      case LoopMode.off:
        nextMode = LoopMode.all;
        break;
      case LoopMode.all:
        nextMode = LoopMode.one;
        break;
      case LoopMode.one:
        nextMode = LoopMode.off;
        break;
    }
    await _service.setLoopMode(nextMode);
  }

  Future<void> setShuffleMode(bool enabled) => _service.setShuffleMode(enabled);
  Future<void> setLoopMode(LoopMode mode) => _service.setLoopMode(mode);
  
  // 循环播放模式切换
  Future<void> cyclePlaybackMode() async {
    final currentShuffle = await _ref.read(shuffleModeProvider.future);
    final currentLoop = await _ref.read(loopModeProvider.future);
    
    if (!currentShuffle && currentLoop == LoopMode.off) {
      // Off -> All
      await _service.setLoopMode(LoopMode.all);
    } else if (!currentShuffle && currentLoop == LoopMode.all) {
      // All -> One
      await _service.setLoopMode(LoopMode.one);
    } else if (!currentShuffle && currentLoop == LoopMode.one) {
      // One -> Shuffle
      await _service.setLoopMode(LoopMode.off);
      await _service.setShuffleMode(true);
    } else if (currentShuffle) {
      // Shuffle -> Off
      await _service.setShuffleMode(false);
      await _service.setLoopMode(LoopMode.off);
    }
  }

  // 队列管理
  Future<void> setQueue(List<Song> songs, {int initialIndex = 0, bool autoPlay = true}) async {
    await _service.setQueue(songs, initialIndex: initialIndex, autoPlay: autoPlay);
  }
  
  Future<void> clearQueue() async {
    // Use service-level clear that stops playback, clears playlist and persisted state.
    await _service.clearQueue();
  }

  Future<void> playSong(Song song) async {
    await _service.playSong(song);
  }
  
  Future<void> playSingle(Song song) async {
    // Default single-click behavior: 插队播放（不清空当前队列）
    await playNext(song);
  }

  Future<void> addToQueue(Song song) async {
    await _service.addToEnd(song);
  }

  Future<void> addToNext(Song song) async {
    await _service.addToNext(song);
  }

  Future<void> removeFromQueue(int index) async {
    await _service.removeAt(index);
  }

  Future<void> moveQueueItem(int from, int to) async {
    await _service.move(from, to);
  }

  Future<void> removeSongs(List<int> songIds) async {
    await _service.removeSongs(songIds);
  }

  // 播放列表中的歌曲
  Future<void> playAlbumSongs(List<Song> songs, {int startIndex = 0}) async {
    await setQueue(songs, initialIndex: startIndex);
  }

  // 插入到下一首并立即播放
  Future<void> playNext(Song song) async {
    final prefs = _ref.read(preferencesServiceProvider);
    var queue = _service.audioHandler.queue.value;
    var currentIndex = _service.player.currentIndex ?? -1;

    // 若重启后队列尚未恢复但偏好中有历史队列，先尝试恢复
    if ((queue.isEmpty || currentIndex < 0) && prefs.lastQueueSongIds.isNotEmpty) {
      await _service.restoreLastQueue();
      queue = _service.audioHandler.queue.value;
      currentIndex = _service.player.currentIndex ?? -1;
    }

    // 如果当前队列仍为空，则直接替换队列并播放
    if (queue.isEmpty || currentIndex < 0) {
      await playSong(song);
      if (!_service.player.playing) {
        await play();
      }
      return;
    }

    // 队列非空 currentIndex 有效，按原逻辑插入到下一首或跳转到已存在的项
    // 检查歌曲是否已在队列中
    final existingIndex = queue.indexWhere((item) => item.id == song.id.toString());

    if (existingIndex != -1) {
      // 如果歌曲已在当前队列中，直接跳转到该歌曲（不移除或移动它）
      await skipToIndex(existingIndex);
    } else {
      // 歌曲不在队列中，插入到下一首并切换到它
      await addToNext(song);
      await skipToIndex(currentIndex + 1);
    }
    
    // 确保正在播放
    if (!_service.player.playing) {
      await play();
    }
  }
}

// ==================== 工具方法 ====================

/// 格式化时间
String formatDuration(Duration? duration) {
  if (duration == null) return '0:00';
  
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

/// 获取循环模式图标
String getLoopModeText(LoopMode mode) {
  switch (mode) {
    case LoopMode.off:
      return '关闭';
    case LoopMode.one:
      return '单曲循环';
    case LoopMode.all:
      return '列表循环';
  }
}

