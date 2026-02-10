import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';
import 'package:jmusic/core/services/toast_service.dart';

/// 自定义AudioHandler用于后台播放、通知栏控制、锁屏控制等
class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player;
  final _playlist = <MediaItem>[];
  final _songCache = <String, Song>{};
  ProcessingState _lastProcessingState = ProcessingState.idle;
  
  // 淡入淡出相关
  bool _crossfadeEnabled = false;
  Duration _crossfadeDuration = const Duration(seconds: 3);
  Timer? _fadeTimer;
  Timer? _loadingTimeoutTimer;
  
  // 中断相关
  bool _wasPlayingBeforeInterruption = false;
  
  // 用于存储每首歌的原始Song对象
  Song? getSongById(String id) => _songCache[id];

  AudioPlayer get player => _player;
  
  static Future<MyAudioHandler> init() async {
    return await AudioService.init(
      builder: () => MyAudioHandler(AudioPlayer()),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.jmusic.audio',
        androidNotificationChannelName: 'JMusic播放',
        androidNotificationOngoing: false,
        androidStopForegroundOnPause: false,
      ),
    );
  }
  
  MyAudioHandler(this._player) {
    _init();
  }

  void _init() {
    Future.microtask(_configureAudioSession);
    // 监听播放器状态变化并同步到AudioService
    _player.playbackEventStream.listen(_broadcastState);
    
    // 额外监听 playerStateStream 以确保播放状态同步（防止 playbackEventStream 与 Windows 上丢包）
    _player.playerStateStream.listen((state) {
      _broadcastState(PlaybackEvent(
        processingState: state.processingState,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        updateTime: DateTime.now(),
      ));
    });
    
    // 监听当前播放索引变化
    int? _lastValidIndex;
    _player.currentIndexStream.listen((index) {
      print('[MyAudioHandler] Current index changed: $index');
      if (index != null && index >= 0 && index < _playlist.length) {
        // 只有当索引真正改变时才更新mediaItem，避免播放模式切换时的临时索引变 
        if (_lastValidIndex != index) {
          print('[MyAudioHandler] Setting mediaItem: ${_playlist[index].title}');
          mediaItem.add(_playlist[index]);
          _lastValidIndex = index;
        }
      } else if (index == null && _lastValidIndex != null) {
        // 如果索引变为null，但我们有上一个有效索引，保持当前的mediaItem
        print('[MyAudioHandler] Index became null, keeping current mediaItem');
      } else {
        print('[MyAudioHandler] Index out of range or null');
      }
    });
    
    // 监听序列变化（播放列表变化）
    _player.sequenceStateStream.listen((sequenceState) {
      if (sequenceState != null) {
        queue.add(_playlist);
        // For cloud songs, currentIndex may lag; use sequenceState to update UI promptly.
        final idx = sequenceState.currentIndex;
        if (idx != null && idx >= 0 && idx < _playlist.length) {
          final currentItem = _playlist[idx];
          final currentId = mediaItem.value?.id;
          if (currentId != currentItem.id) {
            mediaItem.add(currentItem);
          }
        }
      }
    });

    // 监听播放事件，尝试在加载/缓冲失败时自动跳到下一首并通知UI
    _player.playbackEventStream.listen((event) {
      final prevState = _lastProcessingState;
      _lastProcessingState = event.processingState;
      _handleLoadingState(event.processingState);
      try {
        if (event.processingState == ProcessingState.idle &&
            prevState != ProcessingState.idle &&
            !_player.playing) {
          // Likely failed to load or unreachable. Skip to next if possible.
          final idx = _player.currentIndex ?? -1;
          final seqLen = _player.sequence?.length ?? 0;
          if (idx >= 0 && idx < seqLen) {
            // Avoid false positives when local file exists and playback is fine
            try {
              final song = _songCache[_playlist[idx].id];
              if (song != null && song.sourceType == SourceType.local) {
                final file = File(song.path);
                if (file.existsSync()) {
                  return;
                }
              }
            } catch (_) {}
            try {
              toastService.show('cannotAccessSong', args: {'title': _playlist[idx].title});
            } catch (_) {}
            try {
              skipToNext();
            } catch (_) {}
          }
        }
      } catch (_) {}
    });
    
    // 监听播放完成,实现自动淡出效果
    _player.positionStream.listen((position) {
      if (_crossfadeEnabled && _player.duration != null) {
        final remaining = _player.duration! - position;
        if (remaining <= _crossfadeDuration && remaining > Duration.zero) {
          _startCrossfade();
        }
      }
    });

    // 监听duration变化，更新MediaItem和数据库
    _player.durationStream.listen((duration) {
      if (duration != null) {
        final currentIndex = _player.currentIndex;
        if (currentIndex != null && currentIndex >= 0 && currentIndex < _playlist.length) {
          final song = _songCache[_playlist[currentIndex].id];
          if (song != null) {
            // 使用overrideDuration更新MediaItem
            final updatedMediaItem = _createMediaItem(song, overrideDuration: duration);
            _playlist[currentIndex] = updatedMediaItem;
            mediaItem.add(updatedMediaItem);

            // 异步更新数据库中的Song duration
            _updateSongDuration(song.id, duration.inSeconds.toDouble());
          }
        }
      }
    });
  }

  Future<void> _configureAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      session.becomingNoisyEventStream.listen((_) {
        pause();
      });

      session.interruptionEventStream.listen((event) {
        print('[MyAudioHandler] Interruption event: begin=${event.begin}, type=${event.type}, wasPlaying=${_player.playing}');
        if (event.begin) {
          // 中断开始时，根据类型处理
          if (event.type == AudioInterruptionType.pause || event.type == AudioInterruptionType.duck) {
            _wasPlayingBeforeInterruption = _player.playing;
            if (_wasPlayingBeforeInterruption) {
              print('[MyAudioHandler] Pausing due to interruption');
              pause();
            } else {
              // 即使播放器已经在停止状态，也要确保状态同步
              print('[MyAudioHandler] Player already stopped, forcing state sync');
              _broadcastState(PlaybackEvent(
                processingState: _player.processingState,
                updatePosition: _player.position,
                bufferedPosition: _player.bufferedPosition,
                updateTime: DateTime.now(),
              ));
            }
          } else if (event.type == AudioInterruptionType.unknown) {
            // Unknown类型通常是永久失去音频焦点，应该停止播放
            print('[MyAudioHandler] Stopping due to unknown interruption (permanent focus loss)');
            stop();
            _wasPlayingBeforeInterruption = false; // 不应该恢复
          }
        } else {
          // 中断结束时，只有pause和duck类型可以恢复播放
          if ((event.type == AudioInterruptionType.pause || event.type == AudioInterruptionType.duck) && 
              _wasPlayingBeforeInterruption) {
            print('[MyAudioHandler] Resuming playback after interruption');
            play();
            _wasPlayingBeforeInterruption = false;
          }
          // Unknown类型中断结束时不恢复播放
        }
      });
    } catch (e) {
      print('[MyAudioHandler] AudioSession config error: $e');
    }
  }

  void _handleLoadingState(ProcessingState state) {
    if (state == ProcessingState.loading || state == ProcessingState.buffering) {
      _loadingTimeoutTimer?.cancel();
      _loadingTimeoutTimer = Timer(const Duration(seconds: 20), () {
        if (_player.processingState == ProcessingState.loading || _player.processingState == ProcessingState.buffering) {
          final idx = _player.currentIndex ?? -1;
          if (idx >= 0 && idx < _playlist.length) {
            try {
              toastService.show('cannotAccessSong', args: {'title': _playlist[idx].title});
            } catch (_) {}
          }
          if (_player.hasNext) {
            try {
              skipToNext();
            } catch (_) {}
          } else {
            pause();
          }
        }
      });
    } else {
      _loadingTimeoutTimer?.cancel();
    }
  }

  /// 启用/禁用歌曲间淡入淡 
  void setCrossfadeEnabled(bool enabled) {
    _crossfadeEnabled = enabled;
  }

  /// 设置淡入淡出持续时间
  void setCrossfadeDuration(Duration duration) {
    _crossfadeDuration = duration;
  }

  /// 开始交叉淡入淡 
  void _startCrossfade() {
    _fadeTimer?.cancel();
    
    if (!_crossfadeEnabled) return;
    
    const steps = 20;
    final stepDuration = _crossfadeDuration ~/ steps;
    var currentStep = 0;
    
    _fadeTimer = Timer.periodic(stepDuration, (timer) {
      currentStep++;
      final volume = 1.0 - (currentStep / steps);
      _player.setVolume(volume.clamp(0.0, 1.0));
      
      if (currentStep >= steps) {
        timer.cancel();
        _player.setVolume(1.0); // 恢复音量供下一 
      }
    });
  }

  /// 广播播放状态到系统
  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    final processingState = _getProcessingState();
    
    print('[MyAudioHandler] _broadcastState: playing=$playing, processingState=$processingState');
    
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: processingState,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _player.currentIndex,
    ));
  }

  AudioProcessingState _getProcessingState() {
    if (_player.processingState == ProcessingState.loading ||
        _player.processingState == ProcessingState.buffering) {
      return AudioProcessingState.loading;
    } else if (_player.processingState == ProcessingState.ready) {
      return AudioProcessingState.ready;
    } else if (_player.processingState == ProcessingState.completed) {
      return AudioProcessingState.completed;
    } else {
      return AudioProcessingState.idle;
    }
  }

  // ==================== AudioHandler 必需实现 ====================

  @override
  Future<void> play() async {
    await _player.play();
    // 强制更新状态，确保UI响应 (Fix for Windows stream issues)
    if (!playbackState.value.playing) {
      playbackState.add(playbackState.value.copyWith(
        playing: true,
        processingState: AudioProcessingState.ready,
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.pause,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
      ));
    }
    // 淡入效果
    if (_crossfadeEnabled) {
      const steps = 10;
      const stepDuration = Duration(milliseconds: 100);
      await _player.setVolume(0.0);
      
      for (var i = 0; i <= steps; i++) {
        await Future.delayed(stepDuration);
        await _player.setVolume(i / steps);
      }
    }
  }

  @override
  Future<void> pause() async {
    await _player.pause();
    // 强制更新状态，确保UI响应 (Fix for Windows stream issues)
    if (playbackState.value.playing) {
      playbackState.add(playbackState.value.copyWith(
        playing: false,
        processingState: AudioProcessingState.ready, // Keep ready
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
      ));
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index >= 0 && index < _playlist.length) {
      await _player.seek(Duration.zero, index: index);
    }
  }

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode == AudioServiceShuffleMode.all;
    await _player.setShuffleModeEnabled(enabled);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    await _player.setLoopMode(_loopModeFromRepeatMode(repeatMode));
  }

  LoopMode _loopModeFromRepeatMode(AudioServiceRepeatMode repeatMode) {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        return LoopMode.off;
      case AudioServiceRepeatMode.one:
        return LoopMode.one;
      case AudioServiceRepeatMode.all:
        return LoopMode.all;
      default:
        return LoopMode.off;
    }
  }

  // ==================== 自定义播放列表管 ====================

  /// 设置播放列表
  Future<void> setPlaylist(List<Song> songs, {int initialIndex = 0}) async {
    _playlist.clear();
    _songCache.clear();

    if (songs.isEmpty) {
      // 清空播放列表时，设置空的audioSource以重置播放器状态
      await _player.setAudioSource(ConcatenatingAudioSource(children: []));
      queue.add(_playlist);
      mediaItem.add(null);
      return;
    }

    final audioSources = <AudioSource>[];

    // We build media list only for songs that produced a valid AudioSource.
    for (final song in songs) {
      try {
        final audioSource = await _createAudioSource(song);
        final mediaItem = _createMediaItem(song);

        _playlist.add(mediaItem);
        _songCache[mediaItem.id] = song;
        audioSources.add(audioSource);
      } catch (e) {
        // Emit toast request to UI and skip this song
        try {
          toastService.show('cannotAccessSong', args: {'title': song.title ?? ''});
        } catch (_) {}
        print('[MyAudioHandler] Skipping song due to audio source error: ${song.path}, error: $e');
      }
    }

    final playlist = ConcatenatingAudioSource(children: audioSources);
    await _player.setAudioSource(
      playlist,
      initialIndex: initialIndex.clamp(0, audioSources.length > 0 ? audioSources.length - 1 : 0),
      initialPosition: Duration.zero,
    );

    queue.add(_playlist);
    if (initialIndex >= 0 && initialIndex < _playlist.length) {
      mediaItem.add(_playlist[initialIndex]);
    }
  }

  /// 添加歌曲到播放列表末 
  Future<void> addToQueue(Song song) async {
    try {
      final audioSource = await _createAudioSource(song);
      final mediaItem = _createMediaItem(song);
      _playlist.add(mediaItem);
      _songCache[mediaItem.id] = song;

      final concatenating = _player.audioSource as ConcatenatingAudioSource?;
      if (concatenating != null) {
        await concatenating.add(audioSource);
      }

      queue.add(_playlist);

      // 确保当前播放的mediaItem仍然正确
      final currentIndex = _player.currentIndex;
      if (currentIndex != null && currentIndex >= 0 && currentIndex < _playlist.length) {
        this.mediaItem.add(_playlist[currentIndex]);
      }
    } catch (e) {
      try {
        toastService.show('cannotAccessSong', args: {'title': song.title ?? ''});
      } catch (_) {}
      print('[MyAudioHandler] Failed to addToQueue, skipping song: ${song.path}, error: $e');
    }
  }

  /// 插入歌曲到当前播放位置之 
  Future<void> addToNext(Song song) async {
    final currentIndex = _player.currentIndex ?? 0;
    final insertIndex = (currentIndex + 1).clamp(0, _playlist.length);
    
    try {
      final mediaItem = _createMediaItem(song);
      final audioSource = await _createAudioSource(song);
      
      _playlist.insert(insertIndex, mediaItem);
      _songCache[mediaItem.id] = song;
      
      final concatenating = _player.audioSource as ConcatenatingAudioSource?;
      if (concatenating != null) {
        await concatenating.insert(insertIndex, audioSource);
      }
      
      queue.add(_playlist);
      
      // 确保当前播放的mediaItem仍然正确（索引可能因插入而改变）
      final newCurrentIndex = _player.currentIndex;
      if (newCurrentIndex != null && newCurrentIndex >= 0 && newCurrentIndex < _playlist.length) {
        this.mediaItem.add(_playlist[newCurrentIndex]);
      }
    } catch (e) {
      try {
        toastService.show('cannotAccessSong', args: {'title': song.title ?? ''});
      } catch (_) {}
      print('[MyAudioHandler] Failed to add song to next: ${song.title}, error: $e');
      // 不添加无效的歌曲到队 
    }
  }

  /// 移除指定索引的歌 
  Future<void> removeQueueItemAt(int index) async {
    if (index >= 0 && index < _playlist.length) {
      final removedItem = _playlist.removeAt(index);
      _songCache.remove(removedItem.id);
      
      final concatenating = _player.audioSource as ConcatenatingAudioSource?;
      if (concatenating != null) {
        await concatenating.removeAt(index);
      }
      
      queue.add(_playlist);
      
      // 强制更新当前播放的mediaItem，避免移除时的UI闪烁
      final currentIndex = _player.currentIndex;
      if (currentIndex != null && currentIndex >= 0 && currentIndex < _playlist.length) {
        mediaItem.add(_playlist[currentIndex]);
      } else if (_playlist.isNotEmpty && currentIndex != null && currentIndex >= _playlist.length) {
        // 如果当前索引超出范围，播放第一首歌
        await _player.seek(Duration.zero, index: 0);
      }
    }
  }

  /// 移动播放列表 
  Future<void> moveQueueItem(int from, int to) async {
    // Flutter's ReorderableListView provides `newIndex` as the index
    // in the list AFTER the dragged item has been removed. When moving
    // an item downward, that index is one greater than the desired
    // insertion position in the original list. Adjust accordingly.
    if (_playlist.isEmpty) return;

    var target = to;
    if (target > from) target = target - 1;

    // Clamp target to valid range
    if (from < 0 || from >= _playlist.length) return;
    if (target < 0) target = 0;
    if (target >= _playlist.length) target = _playlist.length - 1;

    final currentIndexBefore = _player.currentIndex;
    final currentId = (currentIndexBefore != null && currentIndexBefore >= 0 && currentIndexBefore < _playlist.length)
      ? _playlist[currentIndexBefore].id
      : null;

    final item = _playlist.removeAt(from);
    _playlist.insert(target, item);

    final concatenating = _player.audioSource as ConcatenatingAudioSource?;
    if (concatenating != null) {
      try {
        await concatenating.move(from, target);
      } catch (e) {
        // just_audio may throw if indices are out of sync; ignore but log
        print('[MyAudioHandler] concatenating.move failed: $e');
      }
    }

    queue.add(_playlist);

    // 保持当前播放的 MediaItem 指向同一首歌，避免拖动时图标闪烁
    if (currentId != null) {
      final newIndex = _playlist.indexWhere((item) => item.id == currentId);
      if (newIndex != -1) {
        mediaItem.add(_playlist[newIndex]);
      }
    }
  }

  /// 创建MediaItem
  MediaItem _createMediaItem(Song song, {Duration? overrideDuration}) {
    final duration = overrideDuration ?? (song.duration != null ? Duration(milliseconds: song.duration!.toInt()) : null);
    return MediaItem(
      id: song.id.toString(),
      title: song.title,
      artist: song.artist ?? '未知艺术家',
      album: song.album ?? '未知专辑',
      duration: duration,
      artUri: song.coverPath != null
          ? (song.coverPath!.startsWith('http')
              ? Uri.parse(song.coverPath!)
              : Uri.file(song.coverPath!))
          : null,
      extras: {
        'songId': song.id,
        'path': song.path,
        'sourceType': song.sourceType.toString(),
        'syncConfigId': song.syncConfigId,
      },
    );
  }

  /// 创建AudioSource（支持本地和WebDAV 
  Future<AudioSource> _createAudioSource(Song song) async {
    Uri uri;
    Map<String, String>? headers;
    // 优先根据 sourceType 判断
    if (song.sourceType == SourceType.webdav || song.sourceType == SourceType.openlist) {
      // WebDAV 资源：上层已构建 URL 或者会提供可访问路 
      uri = Uri.parse(song.path);
      // 如果上层通过 Song.remoteUrl 传入 auth header（如 Basic ...），在这里设 headers
      if (song.remoteUrl != null && song.remoteUrl!.isNotEmpty) {
        headers = {'Authorization': song.remoteUrl!};
      }
      print('[MyAudioHandler] _createAudioSource: treating as WebDAV uri=${song.path} id=${song.id}');
    } else if (song.sourceType == SourceType.local) {
      final file = File(song.path);
      if (!file.existsSync()) {
        print('[MyAudioHandler] _createAudioSource: local file missing: ${song.path} id=${song.id}');
        throw Exception('Audio file does not exist: ${song.path}');
      }
      uri = Uri.file(song.path);
    } else {
      // 未明 sourceType 时，根据 path 判断（保留原有行为）
      if (song.path.startsWith('http')) {
        uri = Uri.parse(song.path);
      } else {
        final file = File(song.path);
        if (!file.existsSync()) {
          print('[MyAudioHandler] _createAudioSource: guessed local file missing: ${song.path} id=${song.id}');
          throw Exception('Audio file does not exist: ${song.path}');
        }
        uri = Uri.file(song.path);
      }
    }
    
    return AudioSource.uri(
      uri,
      headers: headers,
      tag: _createMediaItem(song),
    );
  }

  /// 更新指定歌曲的元数据
  Future<void> updateSongMetadata(Song updatedSong) async {
    final index = _playlist.indexWhere((item) => item.id == updatedSong.id.toString());
    if (index != -1) {
        final oldSong = _songCache[updatedSong.id.toString()];
        final needsAudioSourceUpdate = oldSong == null
          ? false
          : oldSong.path != updatedSong.path ||
            oldSong.sourceType != updatedSong.sourceType ||
            oldSong.remoteUrl != updatedSong.remoteUrl;
        final shouldUpdateMediaItem = oldSong == null
          ? true
          : oldSong.title != updatedSong.title ||
            oldSong.artist != updatedSong.artist ||
            oldSong.album != updatedSong.album ||
            oldSong.coverPath != updatedSong.coverPath ||
            oldSong.duration != updatedSong.duration;
      // 如果这是当前播放的歌曲，使用当前的播放器duration
      final overrideDuration = (index == _player.currentIndex) ? _player.duration : null;
      final newMediaItem = _createMediaItem(updatedSong, overrideDuration: overrideDuration);
      _playlist[index] = newMediaItem;
      _songCache[newMediaItem.id] = updatedSong;
      
      queue.add(_playlist);
      
      // 同步更新播放器内部的 AudioSource  tag，确 sequenceState 中的 tag 也被更新
      try {
        final concatenating = _player.audioSource as ConcatenatingAudioSource?;
        if (needsAudioSourceUpdate && concatenating != null && index >= 0 && index < concatenating.length) {
          // 保留当前播放位置以便恢复（如果需要）
          final currentIndex = _player.currentIndex;
          final currentPosition = _player.position;

          final newAudioSource = await _createAudioSource(updatedSong);

          // Replace: remove then insert at same index
          await concatenating.removeAt(index);
          await concatenating.insert(index, newAudioSource);

          // 如果当前正在播放的就是这个索引，尝试恢复到原来的位置
          if (currentIndex == index) {
            try {
              await _player.seek(currentPosition, index: index);
            } catch (_) {}
          }
        }
      } catch (e) {
        print('[MyAudioHandler] Failed to update audioSource tag: $e');
      }

      // 如果是当前播放的歌曲，且元数据有变化，更新mediaItem（通知客户端 UI）
      if (_player.currentIndex == index && shouldUpdateMediaItem) {
        mediaItem.add(newMediaItem);
      }
    }
  }

  @override
  Future<void> onTaskRemoved() async {
    // 当应用被系统杀死时的处 
    // 可以选择停止播放或继续播 
    // await stop();
  }

  /// 更新数据库中歌曲的duration
  Future<void> _updateSongDuration(int songId, double durationInSeconds) async {
    try {
      // 这里需要访问数据库服务，但MyAudioHandler没有直接访问
      // 我们可以通过回调或者其他方式来处理
      // 暂时先不实现数据库更新，因为主要问题是MediaItem的duration
      print('[MyAudioHandler] Duration updated for song $songId: $durationInSeconds seconds');
    } catch (e) {
      print('[MyAudioHandler] Failed to update song duration: $e');
    }
  }

  void dispose() {
    _fadeTimer?.cancel();
  }
}

