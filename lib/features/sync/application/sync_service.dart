import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:jmusic/core/services/database_service.dart';
import 'package:jmusic/core/services/webdav_service.dart';
import 'package:jmusic/core/services/song_metadata_cache_service.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';
import 'package:jmusic/core/utils/artist_parser.dart';
import 'package:jmusic/features/music_lib/domain/entities/playlist.dart';
import 'package:jmusic/features/playlists/data/playlist_repository.dart';
import 'package:jmusic/features/sync/data/sync_config_repository.dart';
import 'package:jmusic/features/sync/domain/entities/sync_config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;
import 'package:path/path.dart' as p;

final syncServiceProvider = Provider<SyncService>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  final syncRepo = ref.watch(syncConfigRepositoryProvider);
  final webDavService = ref.watch(webDavServiceProvider);
  final metaCache = ref.watch(songMetadataCacheServiceProvider);
  return SyncService(dbService, syncRepo, webDavService, metaCache);
});

typedef SyncProgressCallback = void Function(int current, int total, String currentFile);

class SyncResult {
  final int totalScanned;
  final int added;
  final int updated;
  final int removed;
  final int failed;

  const SyncResult({
    required this.totalScanned,
    required this.added,
    required this.updated,
    required this.removed,
    required this.failed,
  });
}

class _AsyncPool {
  final int _max;
  int _running = 0;
  final Queue<Completer<void>> _waiters = Queue<Completer<void>>();

  _AsyncPool(this._max);

  Future<T> run<T>(Future<T> Function() task) async {
    if (_running >= _max) {
      final gate = Completer<void>();
      _waiters.addLast(gate);
      await gate.future;
    }
    _running++;
    try {
      return await task();
    } finally {
      _running--;
      if (_waiters.isNotEmpty) {
        _waiters.removeFirst().complete();
      }
    }
  }
}

class SyncService {
  final DatabaseService _dbService;
  final SyncConfigRepository _syncRepo;
  final WebDavService _webDavService;
  final SongMetadataCacheService _metaCache;

  SyncService(this._dbService, this._syncRepo, this._webDavService, this._metaCache);

  /// Synchronize a specific account
  Future<SyncResult> syncAccount(SyncConfig config, {SyncProgressCallback? onProgress}) async {
    if (config.type == SyncType.webdav || config.type == SyncType.openlist) {
      final headers = _buildAuthHeaders(config);
      return await _syncWebDav(config, headers: headers, onProgress: onProgress);
    }
    return const SyncResult(totalScanned: 0, added: 0, updated: 0, removed: 0, failed: 0);
  }

  Map<String, String>? _buildAuthHeaders(SyncConfig config) {
    if (config.type == SyncType.openlist && config.token != null && config.token!.isNotEmpty) {
      return {'Authorization': 'Bearer ${config.token}'};
    }
    return null;
  }

  Future<SyncResult> _syncWebDav(SyncConfig config, {Map<String, String>? headers, SyncProgressCallback? onProgress}) async {
    final baseUrl = _normalizeUrl(config.url ?? '');
    final client = webdav.newClient(
      baseUrl,
      user: config.username ?? '',
      password: config.password ?? '',
      debug: false,
    );

    if (headers != null && headers.isNotEmpty) {
      client.setHeaders(headers);
    }

    // Test connection
    try {
      await client.readDir('/');
    } catch (e) {
      throw Exception('Failed to connect to WebDAV: $e');
    }

    // Traverse and Sync
    // Determine root path if needed. Assuming config.url might contain path or we start at root.
    // Use config.path as root for music
    String rootPath = config.path ?? '/';
    if (!rootPath.startsWith('/')) rootPath = '/$rootPath';
    // Ensure trailing slash for directory listings in some WebDAV impls or comparison logic
    if (!rootPath.endsWith('/')) rootPath = '$rootPath/';
    
    final supportedExtensions = {'.mp3', '.flac', '.m4a', '.wav', '.ogg', '.mp4', '.mkv', '.avi', '.mov', '.rmvb', '.webm', '.flv', '.m3u8'};
    const listConcurrency = 4;
    const processConcurrency = 4;

    final listPool = _AsyncPool(listConcurrency);
    final processPool = _AsyncPool(processConcurrency);
    final counterPool = _AsyncPool(1);

    final foundPathSet = <String>{};
    final foundPathList = <String>[];
    final foundFiles = <webdav.File>[];
    final lyricPathByBase = <String, String>{};
    final visitedDirs = <String>{};
    
    Future<void> traverse(String path, int depth) async {
       if (depth > 10) return; // Safety break
       final normalizedDir = _normalizeDirPath(path);
       if (visitedDirs.contains(normalizedDir)) return;
       visitedDirs.add(normalizedDir);
       onProgress?.call(0, 0, normalizedDir);
       try {
         final files = await listPool.run(() => client.readDir(normalizedDir));
         final subDirs = <String>[];
         for (final file in files) {
           final isDir = file.isDir ?? false;
           if (isDir) {
             var subPath = file.path;
             if (subPath == null) continue;
             if (!subPath.endsWith('/')) subPath += '/';
             // Prevent infinite recursion if server returns self
             if (_normalizeDirPath(subPath) == normalizedDir) continue; 
             subDirs.add(subPath);
           } else {
             final filename = file.name ?? '';
             final ext = p.extension(filename).toLowerCase();
             if (supportedExtensions.contains(ext)) {
                 final fullPath = file.path;
                 if (fullPath != null) {
                    foundPathSet.add(fullPath);
                    foundPathList.add(fullPath);
                    foundFiles.add(file);
                 }
               } else if (ext == '.lrc') {
                 final lrcPath = file.path;
                 if (lrcPath != null) {
                   lyricPathByBase[p.posix.withoutExtension(lrcPath)] = lrcPath;
                 }
               }
           }
         }
         if (subDirs.isNotEmpty) {
           await Future.wait(subDirs.map((dir) => traverse(dir, depth + 1)));
         }
       } catch (e) {
         print('Error reading dir $path: $e');
       }
    }

    await traverse(rootPath, 0);

    int added = 0;
    int updated = 0;
    int failed = 0;

    // Process found files with progress (limited concurrency)
    int completed = 0;
    final tasks = <Future<void>>[];
    for (int i = 0; i < foundFiles.length; i++) {
      final file = foundFiles[i];
      final fullPath = foundPathList[i];
      tasks.add(processPool.run(() async {
        final basePath = p.posix.withoutExtension(fullPath);
        final lrcPath = lyricPathByBase[basePath];
        final hasLyricFile = lrcPath != null;
        final lyrics = hasLyricFile ? await _readWebDavText(client, lrcPath!) : null;

        bool isNew = false;
        bool didFail = false;
        try {
          isNew = await _processAndSaveSong(fullPath, file, config, lyrics: lyrics, hasLyricFile: hasLyricFile);
        } catch (e) {
          didFail = true;
          print('Error processing $fullPath: $e');
        }

        await counterPool.run(() async {
          completed++;
          if (didFail) {
            failed++;
          } else if (isNew) {
            added++;
          } else {
            updated++;
          }
          onProgress?.call(completed, foundFiles.length, file.name ?? '');
        });
      }));
    }
    if (tasks.isNotEmpty) {
      await Future.wait(tasks);
    }

    // Cleanup songs that are no longer in the source
    final isar = await _dbService.db;
    final oldSongs = await isar.songs.filter()
        .syncConfigIdEqualTo(config.id)
        .findAll();
    
    final toDeleteSongs = oldSongs.where((s) => !foundPathSet.contains(s.path)).toList();
    final idsToDelete = toDeleteSongs.map((s) => s.id).toList();

    if (idsToDelete.isNotEmpty) {
      await _metaCache.saveMany(toDeleteSongs);
    }

    await isar.writeTxn(() async {
      if (idsToDelete.isNotEmpty) {
        await isar.songs.deleteAll(idsToDelete);
      }
      config.lastSyncTime = DateTime.now();
      await isar.syncConfigs.put(config);
    });

    if (idsToDelete.isNotEmpty) {
      final repo = PlaylistRepository(_dbService);
      await repo.removeSongIdsFromPlaylists(idsToDelete);
    }

    return SyncResult(
      totalScanned: foundFiles.length,
      added: added,
      updated: updated,
      removed: idsToDelete.length,
      failed: failed,
    );
  }

  String _normalizeDirPath(String input) {
    var value = input.trim();
    if (value.isEmpty) return '/';
    value = p.posix.normalize(value);
    if (!value.startsWith('/')) value = '/$value';
    if (!value.endsWith('/')) value = '$value/';
    return value;
  }

  String _normalizeUrl(String input) {
    final value = input.trim();
    if (value.isEmpty) return value;
    if (value.startsWith('http://') || value.startsWith('https://')) return value;
    return 'http://$value';
  }

  Future<bool> _processAndSaveSong(String remotePath, webdav.File info, SyncConfig config, {String? lyrics, bool hasLyricFile = false}) async {
     String title = _cleanTitle(remotePath);
     String artist = 'Unknown Artist';
     String album = 'Unknown Album';
      final ext = p.extension(remotePath).toLowerCase();
      final isVideo = const {'.mp4', '.mkv', '.avi', '.mov', '.rmvb', '.webm', '.flv', '.m3u8'}.contains(ext);
     
     // Basic parsing logic (Same as legacy)
     final parts = remotePath.split('/');
     final segments = parts.where((s) => s.isNotEmpty).toList();
     if (segments.length >= 3) {
       artist = segments[segments.length - 3];
       album = segments[segments.length - 2];
       title = _cleanTitle(segments.last);
     } else if (title.contains(' - ')) {
       final split = title.split(' - ');
       if (split.length >= 3) {
         artist = split[0];
         album = split[1];
         title = split.sublist(2).join(' - ');
       } else if (split.length == 2) {
         artist = split[0];
         title = split[1];
       }
     }

     final parsed = parseArtists(artist);
     final primary = parsed.isNotEmpty ? parsed.first : artist;

     final sourceType = config.type == SyncType.openlist ? SourceType.openlist : SourceType.webdav;
     final song = Song()
       ..path = remotePath
       ..sourceType = sourceType
       ..syncConfigId = config.id
       ..mediaType = isVideo ? MediaType.video : MediaType.audio
       ..title = title
       ..artist = primary
       ..artists = parsed
       ..album = album
       ..lyrics = hasLyricFile ? lyrics : null
       ..size = info.size
       ..dateModified = info.mTime
       ..duration = 0;

     await _metaCache.applyIfMissing(song);

     final isar = await _dbService.db;
     bool isNew = false;
     await isar.writeTxn(() async {
       // Check for existing song with same path AND syncConfigId
       final existing = await isar.songs.filter()
         .syncConfigIdEqualTo(config.id)
         .pathEqualTo(remotePath)
         .findFirst();
       
       if (existing != null) {
         existing.size = song.size;
         existing.dateModified = song.dateModified;
         existing.lyrics = hasLyricFile ? lyrics : null;
         await isar.songs.put(existing);
       } else {
         isNew = true;
         await isar.songs.put(song);
       }
     });
     return isNew;
  }

  Future<String?> _readWebDavText(webdav.Client client, String remotePath) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(p.join(tempDir.path, 'jmusic_lyric_${remotePath.hashCode}.lrc'));
      await client.read2File(remotePath, tempFile.path);
      final text = await tempFile.readAsString();
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      final trimmed = text.trim();
      return trimmed.isNotEmpty ? trimmed : null;
    } catch (e) {
      print('Error reading lyrics from $remotePath: $e');
      return null;
    }
  }

  /// Delete Account and its data
  Future<void> deleteAccount(SyncConfig config) async {
    // 1. Delete Songs
    final isar = await _dbService.db;
    await isar.writeTxn(() async {
      await isar.songs.filter()
          .syncConfigIdEqualTo(config.id)
          .deleteAll();
    });

    // 2. Delete Cache
    await clearCacheForAccount(config);

    // 3. Delete Config
    await _syncRepo.deleteConfig(config.id);
  }

  Future<void> clearCacheForAccount(SyncConfig config) async {
    final cacheDir = await getApplicationDocumentsDirectory();
    final accountCacheDir = Directory('${cacheDir.path}/j_music/webdav_cache/${config.id}');
    if (await accountCacheDir.exists()) {
      await accountCacheDir.delete(recursive: true);
    }
    _webDavService.notifyCacheUpdate('all_cleared');
  }

  /// Returns total cache size in bytes for given account (directory j_music/webdav_cache/<id>)
  Future<int> getCacheSizeForAccount(SyncConfig config) async {
    final cacheDir = await getApplicationDocumentsDirectory();
    final accountCacheDir = Directory('${cacheDir.path}/j_music/webdav_cache/${config.id}');
    if (!await accountCacheDir.exists()) return 0;

    int total = 0;
    await for (final entity in accountCacheDir.list(recursive: true, followLinks: false)) {
      try {
        if (entity is File) {
          final len = await entity.length();
          total += len;
        }
      } catch (_) {
        // ignore file access errors
      }
    }
    return total;
  }

  Future<File?> getCachedFile(Song song) async {
    if (song.syncConfigId == null) return null;
    final cacheDir = await getApplicationDocumentsDirectory();
    final safePath = song.path.replaceAll('/', '_').replaceAll('\\', '_').replaceAll(':', '');
    final file = File('${cacheDir.path}/j_music/webdav_cache/${song.syncConfigId}/$safePath');
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  String _cleanTitle(String filename) {
    // 移除扩展名
    String title = p.basenameWithoutExtension(filename);
    
    // 移除前导的排序号 (如"01 - ", "1. " 等)
    title = title.replaceFirst(RegExp(r'^\d+[\s\-\.]*'), '');
    
    // 移除括号内的内容 (包括圆括号、方括号、花括号)
    title = title.replaceAll(RegExp(r'\s*[\(\[\{].*?[\)\]\}]'), '');
    
    // 移除尾部的特殊标记（如"Radio Edit", "Remix" 等）- 可选
    title = title.replaceAll(RegExp(r'\s*(Radio Edit|Remix|Remaster|Extended|Version|Mix)$', caseSensitive: false), '');
    
    // 移除多余的空格
    title = title.trim().replaceAll(RegExp(r'\s+'), ' ');
    
    // 移除非必要的歌手名称（如果出现在标题中） - 可选
    
    return title.isNotEmpty ? title : p.basenameWithoutExtension(filename);
  }
}

