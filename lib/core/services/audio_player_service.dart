import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';
import 'package:jmusic/core/services/preferences_service.dart';
import 'package:jmusic/core/services/database_service.dart';
import 'package:jmusic/core/services/webdav_service.dart';
import 'package:jmusic/features/sync/data/sync_config_repository.dart';
import 'package:jmusic/features/sync/domain/entities/sync_config.dart';
import 'package:jmusic/core/services/my_audio_handler.dart';
import 'package:jmusic/features/scraper/presentation/batch_scraper_service.dart';
import 'package:jmusic/core/services/toast_service.dart';
import 'package:path_provider/path_provider.dart';

// 全局AudioService初始化标 
bool _audioServiceInitialized = false;

// 定义Handler Provider，将在main中被覆盖
final myAudioHandlerProvider = Provider<MyAudioHandler>((ref) {
  throw UnimplementedError('myAudioHandlerProvider must be overridden in main.dart');
});

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  final dbService = ref.watch(databaseServiceProvider);
  final webDavService = ref.watch(webDavServiceProvider);
  final syncRepo = ref.watch(syncConfigRepositoryProvider);
  final audioHandler = ref.watch(myAudioHandlerProvider);
  return AudioPlayerService(prefs, dbService, webDavService, syncRepo, audioHandler, ref);
});

class AudioPlayerService {
  late final AudioPlayer _player;
  final MyAudioHandler _audioHandler;
  final Ref _ref;
  
  // Getter proxy
  AudioPlayer get player => _player;
  MyAudioHandler get audioHandler => _audioHandler;
  Future<MyAudioHandler> get audioHandlerAsync async => _audioHandler; // Compat

  bool _isInitialized = false;
  
  final PreferencesService _prefs;
  final DatabaseService _dbService;
  final WebDavService _webDavService;
  final SyncConfigRepository _syncRepo;
  Directory? _appDocDir;

  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _currentIndexSubscription;
  StreamSubscription? _webDavCacheSubscription;
  Timer? _saveTimer;
  
  // 缓存SyncConfigs
  final Map<int, SyncConfig> _syncConfigCache = {};

  AudioPlayerService(
    this._prefs,
    this._dbService,
    this._webDavService,
    this._syncRepo,
    this._audioHandler,
    this._ref,
  ) {
    _player = _audioHandler.player; 
    // Init immediately because handler is ready
    _init(); 
  }

  Future<void> _init() async {
    if (_isInitialized) return;
    
    // _audioHandler is already passed in
    print('[AudioPlayerService] Using provided MyAudioHandler');
    _audioServiceInitialized = true;
    
    _appDocDir = await getApplicationDocumentsDirectory();
    _initListeners();
    
    // 从偏好设置中恢复淡入淡出设置
    final crossfadeEnabled = _prefs.getCrossfadeEnabled();
    final crossfadeDuration = _prefs.getCrossfadeDuration();
    _audioHandler.setCrossfadeEnabled(crossfadeEnabled);
    _audioHandler.setCrossfadeDuration(Duration(seconds: crossfadeDuration));

    // 恢复播放模式（随机/循环）
    try {
      await _player.setShuffleModeEnabled(_prefs.shuffleEnabled);
      final loopMode = switch (_prefs.loopMode) {
        'one' => LoopMode.one,
        'all' => LoopMode.all,
        _ => LoopMode.off,
      };
      await _player.setLoopMode(loopMode);
    } catch (e) {
      print('[AudioPlayerService] Failed to restore playback mode: $e');
    }

    // 恢复桌面端音量设置
    try {
      await _player.setVolume(_prefs.desktopVolume.clamp(0.0, 1.0));
    } catch (e) {
      print('[AudioPlayerService] Failed to restore volume: $e');
    }
    
    _isInitialized = true;
  }

  void _initListeners() {
    // 监听播放位置变化，定时保存状 
    _positionSubscription = _player.positionStream.listen((position) {
      if (_saveTimer == null || !_saveTimer!.isActive) {
        _saveTimer = Timer(const Duration(seconds: 5), () {
          _savePlaybackState();
        });
      }
    });

    // 监听播放状态变 
    _playerStateSubscription = _player.playerStateStream.listen((state) {
      final playing = state.playing;
      print('[AudioPlayerService] playerStateStream changed: playing=$playing, processingState=${state.processingState}');
      if (!playing) {
        _savePlaybackState();
      }
      
      // Handle playback completion
      if (state.processingState == ProcessingState.completed) {
        final currentIndex = _player.currentIndex ?? 0;
        final queueLength = _player.sequence?.length ?? 0;
        final loopMode = _player.loopMode;
        final shuffleEnabled = _player.shuffleModeEnabled;
        
        bool willAutoAdvance = false;
        
        if (loopMode == LoopMode.one) {
          // Single song loop, will replay current song
          willAutoAdvance = true;
        } else if (loopMode == LoopMode.all) {
          // Playlist loop, will go to next or first
          willAutoAdvance = true;
        } else if (shuffleEnabled) {
          // Shuffle enabled, will play random next
          willAutoAdvance = true;
        } else {
          // No loop, no shuffle, check if has next
          willAutoAdvance = currentIndex < queueLength - 1;
        }
        
        if (!willAutoAdvance) {
          // No auto advance, pause playback
          print('[AudioPlayerService] Playback completed, no auto advance, pausing');
          _audioHandler.pause();
        }
      }
    });
    
    // 监听当前索引变化
    _currentIndexSubscription = _player.currentIndexStream.listen((index) {
      if (index != null && index >= 0) {
        _savePlaybackState();
        _updateLastPlayed();
        // 自动刮削：根据偏好和当前歌曲信息决定是否触发刮削
        try {
          final prefs = _prefs;
          final auto = prefs.scraperAutoScrapeOnPlay;
          if (auto) {
            final queue = _audioHandler.queue.value;
            if (index >= 0 && index < queue.length) {
              final song = _audioHandler.getSongById(queue[index].id);
              if (song != null) {
                final hasCover = song.coverPath != null && song.coverPath!.trim().isNotEmpty;
                final hasArtist = (song.artists.isNotEmpty && song.artists.any((a) => a.trim().isNotEmpty)) || (song.artist.trim().isNotEmpty && !song.artist.toLowerCase().contains('unknown'));
                final hasAlbum = song.album.trim().isNotEmpty && !song.album.toLowerCase().contains('unknown');

                final batchNotifier = _ref.read(batchScraperProvider.notifier);
                // 如果已有歌词则不再触发
                final hasLyrics = song.lyrics != null && song.lyrics!.trim().isNotEmpty;
                if (!hasLyrics) {
                  // Always run full metadata + lyrics scrape in background.
                  batchNotifier.quietFullScrape(song.id).then((ok) {
                    final key = ok ? 'autoScrapeFullSuccess' : 'autoScrapeFullFail';
                    toastService.show(key, args: {'title': song.title});
                  });
                }
              }
            }
          }
        } catch (e) {
          print('[AudioPlayerService] auto scrape error: $e');
        }
      }
    });
    
    // 监听WebDAV缓存更新
    _webDavCacheSubscription = _webDavService.onCacheUpdated.listen((updatedPath) async {
      await _handleCacheUpdate(updatedPath);
    });
  }

  // ==================== 播放控制 ====================

  double getVolume() => _player.volume;

  Future<void> setVolume(double volume) async {
    final v = volume.clamp(0.0, 1.0);
    await _player.setVolume(v);
    await _prefs.setDesktopVolume(v);
  }

  /// 播放单首歌曲（替换当前队列）
  Future<void> playSong(Song song) async {
    await setQueue([song], initialIndex: 0);
    await _audioHandler.play();
  }

  /// 设置播放队列
  Future<void> setQueue(
    List<Song> songs, {
    int initialIndex = 0,
    Duration initialPosition = Duration.zero,
    bool autoPlay = false,
  }) async {
    if (!_isInitialized) await _init();
    
    // 预处理WebDAV歌曲
    final processedSongs = await _preprocessSongs(songs);
    
    await _audioHandler.setPlaylist(processedSongs, initialIndex: initialIndex);
    
    if (initialPosition > Duration.zero) {
      await _player.seek(initialPosition);
    }
    
    if (autoPlay) {
      await _audioHandler.play();
    }
    
    await saveCurrentQueue();
  }

  /// 预处理歌曲（处理WebDAV URL和缓存）
  Future<List<Song>> _preprocessSongs(List<Song> songs) async {
    final processed = <Song>[];
    
    for (final song in songs) {
      if (song.sourceType == SourceType.webdav || song.sourceType == SourceType.openlist) {
        final processedSong = await _processWebDavSong(song);
        processed.add(processedSong);
      } else {
        processed.add(song);
      }
    }
    
    return processed;
  }

  /// 处理WebDAV歌曲（检查缓存，生成正确的URL）
  Future<Song> _processWebDavSong(Song song) async {
    // 优先检查：如果 song.path 本身就是一个存在的本地文件，则不要当作 WebDAV 处理
    try {
      final maybeFile = File(song.path);
      if (maybeFile.existsSync()) {
        print('[AudioPlayerService] _processWebDavSong: local file exists, treating as local: ${song.path} (id=${song.id})');
        return song.copyWith(path: maybeFile.path, sourceType: SourceType.local);
      }
    } catch (e) {
      // ignore and continue
    }

    // 检查是否有本地缓存（按 syncConfigId 分目录或默认目录）
    if (_appDocDir != null) {
      final safePath = song.path.replaceAll('/', '_').replaceAll('\\', '_').replaceAll(':', '');
      File cacheFile;

      if (song.syncConfigId != null) {
        final dir = Directory('${_appDocDir!.path}/j_music/webdav_cache/${song.syncConfigId}');
        cacheFile = File('${dir.path}/$safePath');
      } else {
        cacheFile = File('${_appDocDir!.path}/j_music/webdav_cache/$safePath');
      }

      if (cacheFile.existsSync()) {
        print('[AudioPlayerService] _processWebDavSong: found cache file, using local cache: ${cacheFile.path} (id=${song.id})');
        return song.copyWith(path: cacheFile.path, sourceType: SourceType.local);
      }
    }

    // 没有缓存，构建WebDAV URL（从 sync config  prefs 获取 
    String webDavUrl = '';
    String webDavUser = '';
    String webDavPassword = '';
    String? openListToken;
    SourceType effectiveSource = song.sourceType;

    if (song.syncConfigId != null) {
      if (!_syncConfigCache.containsKey(song.syncConfigId)) {
        final configs = await _syncRepo.getAllConfigs();
        for (var c in configs) {
          _syncConfigCache[c.id] = c;
        }
      }
      final config = _syncConfigCache[song.syncConfigId];
      if (config != null) {
        webDavUrl = config.url ?? '';
        webDavUser = config.username ?? '';
        webDavPassword = config.password ?? '';
        openListToken = config.token;
        effectiveSource = config.type == SyncType.openlist ? SourceType.openlist : SourceType.webdav;
        print('[AudioPlayerService] _processWebDavSong: using SyncConfig id=${song.syncConfigId} url=${webDavUrl} for song id=${song.id}');
      }
    } else {
      webDavUrl = _prefs.webDavUrl ?? '';
      webDavUser = _prefs.webDavUser ?? '';
      webDavPassword = _prefs.webDavPassword ?? '';
      print('[AudioPlayerService] _processWebDavSong: using prefs WebDAV url=${webDavUrl} for song id=${song.id}');
    }

    // 如果没有可用 WebDAV URL，则直接返回 song（避免误处理 
    if (webDavUrl.isEmpty) {
      print('[AudioPlayerService] _processWebDavSong: no WebDAV url available, returning original song id=${song.id}');
      return song;
    }

    // 构建WebDAV URL
    String cleanUrl = webDavUrl.trim();
    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'http://$cleanUrl';
    }
    if (cleanUrl.endsWith('/')) cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    String path = song.path;
    if (!path.startsWith('/')) path = '/$path';

    final encodedPath = path.split('/').map((s) => Uri.encodeComponent(s)).join('/');
    final fullUrl = '$cleanUrl$encodedPath';

    print('[AudioPlayerService] _processWebDavSong: constructed WebDAV URL: $fullUrl (id=${song.id})');

    // 如果有用户名/密码或 token，将其编码为 Authorization 并放 Song.remoteUrl 字段
    String? authHeader;
    try {
      if (openListToken != null && openListToken!.isNotEmpty) {
        authHeader = 'Bearer $openListToken';
      } else if (webDavUser.isNotEmpty) {
        final cred = base64.encode(utf8.encode('$webDavUser:$webDavPassword'));
        authHeader = 'Basic $cred';
      }
    } catch (e) {
      // ignore encoding errors
    }

    // 返回时明确标记为 webdav 源，并把 authHeader 放到 remoteUrl 字段（用于传 header 
    return song.copyWith(path: fullUrl, sourceType: effectiveSource, remoteUrl: authHeader);
  }

  /// Resolve a song to a playable path (local or remote) without touching the audio queue.
  Future<Song> resolvePlayableSong(Song song) async {
    if (song.sourceType == SourceType.webdav || song.sourceType == SourceType.openlist) {
      return _processWebDavSong(song);
    }
    return song;
  }

  /// 添加歌曲到队列末 
  Future<void> addToEnd(Song song) async {
    if (!_isInitialized) await _init();
    final processed = await _processWebDavSong(song);
    await _audioHandler.addToQueue(processed);
    await saveCurrentQueue();
  }

  /// 添加歌曲到下一 
  Future<void> addToNext(Song song) async {
    if (!_isInitialized) await _init();
    final processed = await _processWebDavSong(song);
    await _audioHandler.addToNext(processed);
    await saveCurrentQueue();
  }

  /// 移除指定索引的歌 
  Future<void> removeAt(int index) async {
    await _audioHandler.removeQueueItemAt(index);
    await saveCurrentQueue();
  }

  /// 移动歌曲位置
  Future<void> move(int from, int to) async {
    await _audioHandler.moveQueueItem(from, to);
    await saveCurrentQueue();
  }

  /// 播放/暂停切换
  Future<void> playPause() async {
    if (_player.playing) {
      await _audioHandler.pause();
    } else {
      await _audioHandler.play();
    }
  }

  /// 播放
  Future<void> play() => _audioHandler.play();

  /// 暂停
  Future<void> pause() => _audioHandler.pause();

  /// 停止
  Future<void> stop() => _player.stop();

  /// 跳转到指定位 
  Future<void> seek(Duration position) => _player.seek(position);

  /// 跳转到指定歌 
  Future<void> skipToIndex(int index) => _player.seek(Duration.zero, index: index);

  /// 下一 
  Future<void> next() => _player.seekToNext();

  /// 上一 
  Future<void> previous() => _player.seekToPrevious();

  /// 设置随机播放
  Future<void> setShuffleMode(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);
    await _prefs.setShuffleEnabled(enabled);
  }

  /// 设置循环模式
  Future<void> setLoopMode(LoopMode mode) async {
    await _player.setLoopMode(mode);
    final prefsValue = switch (mode) {
      LoopMode.one => 'one',
      LoopMode.all => 'all',
      LoopMode.off => 'off',
    };
    await _prefs.setLoopMode(prefsValue);
  }

  AudioServiceRepeatMode _repeatModeFromLoopMode(LoopMode mode) {
    switch (mode) {
      case LoopMode.off:
        return AudioServiceRepeatMode.none;
      case LoopMode.one:
        return AudioServiceRepeatMode.one;
      case LoopMode.all:
        return AudioServiceRepeatMode.all;
    }
  }

  // ==================== 淡入淡出设置 ====================

  /// 设置是否启用淡入淡出
  Future<void> setCrossfadeEnabled(bool enabled) async {
    // 移除audioHandler相关，just_audio_background会自动处 
    await _prefs.setCrossfadeEnabled(enabled);
  }

  /// 设置淡入淡出持续时间（秒 
  Future<void> setCrossfadeDuration(int seconds) async {
    // 移除audioHandler相关
    await _prefs.setCrossfadeDuration(seconds);
  }

  /// 获取淡入淡出启用状 
  bool getCrossfadeEnabled() => _prefs.getCrossfadeEnabled();

  /// 获取淡入淡出持续时间
  int getCrossfadeDuration() => _prefs.getCrossfadeDuration();

  // ==================== 元数据更 ====================

  /// 更新歌曲元数 
  Future<void> updateMetadata(Song updatedSong) async {
    final processed = (updatedSong.sourceType == SourceType.webdav || updatedSong.sourceType == SourceType.openlist)
        ? await _processWebDavSong(updatedSong)
        : updatedSong;
    await _audioHandler.updateSongMetadata(processed);
  }

  // ==================== 持久 ====================

  /// 保存播放状 
  Future<void> _savePlaybackState() async {
    final index = _player.currentIndex ?? -1;
    if (index < 0) return;

    final position = _player.position.inMilliseconds;
    await _prefs.setLastQueuePosition(index, position);
  }

  /// 更新最近播放时 
  Future<void> _updateLastPlayed() async {
    try {
      final index = _player.currentIndex;
      if (index == null || index < 0) return;
      
      final song = _audioHandler.getSongById(
        _audioHandler.queue.value[index].id,
      );
      
      if (song != null) {
        final db = await _dbService.db;
        await db.writeTxn(() async {
          final dbSong = await db.songs.get(song.id);
          if (dbSong != null) {
            dbSong.lastPlayed = DateTime.now();
            await db.songs.put(dbSong);
          }
        });
      }
    } catch (e) {
      print('[AudioPlayerService] Failed to update lastPlayed: $e');
    }
  }

  /// 保存当前播放队列
  Future<void> saveCurrentQueue() async {
    final queue = _audioHandler.queue.value;
    if (queue.isEmpty) return;

    final songIds = queue.map((item) => item.id).toList();
    final currentIndex = _player.currentIndex ?? 0;
    final position = _player.position.inMilliseconds;

    await _prefs.setLastQueue(songIds, currentIndex, position);
  }

  /// 清空播放队列并停止播放，同时清理持久化的队列信息
  Future<void> clearQueue() async {
    if (!_isInitialized) await _init();

    try {
      // 将播放列表清 
      await _audioHandler.setPlaylist(<Song>[], initialIndex: 0);

      // 不再完全停止 audio handler（stop 会结束后 service），改为暂停以保 handler 状 
      await _audioHandler.pause();

      // 清理持久化的队列信息（保存为空队列）
      await _prefs.setLastQueue(<String>[], 0, 0);
    } catch (e) {
      print('[AudioPlayerService] Failed to clear queue: $e');
    }
  }

  /// 恢复上次播放队列
  Future<void> restoreLastQueue() async {
    if (!_isInitialized) await _init();
    
    final songIds = _prefs.lastQueueSongIds;
    if (songIds.isEmpty) return;

    final db = await _dbService.db;
    final intIds = songIds.map((id) => int.tryParse(id)).whereType<int>().toList();
    
    final availableSongs = <String, Song>{};
    for (final id in intIds) {
      final song = await db.songs.get(id);
      if (song != null) {
        availableSongs[song.id.toString()] = song;
      }
    }

    if (availableSongs.isEmpty) return;

    final orderedSongs = <Song>[];
    for (final id in songIds) {
      if (availableSongs.containsKey(id)) {
        orderedSongs.add(availableSongs[id]!);
      }
    }

    if (orderedSongs.isEmpty) return;

    final index = _prefs.lastQueueIndex;
    final positionMs = _prefs.lastQueuePosition;
    final validIndex = index.clamp(0, orderedSongs.length - 1);

    print('[AudioPlayerService] Restoring queue: ${orderedSongs.length} songs. Index: $validIndex, Position: ${positionMs}ms');

    await setQueue(
      orderedSongs,
      initialIndex: validIndex,
      initialPosition: Duration(milliseconds: positionMs),
      autoPlay: false,
    );
  }

  /// 处理WebDAV缓存更新
  Future<void> _handleCacheUpdate(String updatedPath) async {
    // 当WebDAV文件被缓存后，更新播放列表中的对应项
    // 这里可以实现更复杂的逻辑，比如替换当前播放的 
    print('[AudioPlayerService] WebDAV cache updated: $updatedPath');
    // TODO: 实现热更新逻辑（如果需要）
  }

  /// 移除指定歌曲
  Future<void> removeSongs(List<int> songIds) async {
    if (songIds.isEmpty) return;

    final queue = _audioHandler.queue.value;
    final indicesToRemove = <int>[];
    
    for (int i = 0; i < queue.length; i++) {
      final songId = int.tryParse(queue[i].id);
      if (songId != null && songIds.contains(songId)) {
        indicesToRemove.add(i);
      }
    }

    if (indicesToRemove.isEmpty) return;

    // 从后往前删除以保持索引有效
    indicesToRemove.sort((a, b) => b.compareTo(a));
    for (final index in indicesToRemove) {
      await removeAt(index);
    }
  }

  /// 根据Song对象获取在队列中的索 
  Song? getSongByIndex(int index) {
    final queue = _audioHandler.queue.value;
    if (index >= 0 && index < queue.length) {
      return _audioHandler.getSongById(queue[index].id);
    }
    return null;
  }

  void dispose() {
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _currentIndexSubscription?.cancel();
    _webDavCacheSubscription?.cancel();
    _saveTimer?.cancel();
    _audioHandler.dispose();
    _player.dispose();
  }
}

