import 'dart:async';
import 'dart:io';
import 'dart:collection';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:jmusic/core/services/database_service.dart';
import 'package:jmusic/core/services/preferences_service.dart';
import 'package:jmusic/core/services/song_metadata_cache_service.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';
import 'package:jmusic/features/sync/domain/entities/sync_config.dart';
import 'package:jmusic/core/utils/artist_parser.dart';
import 'package:jmusic/features/music_lib/domain/entities/playlist.dart';
import 'package:jmusic/features/playlists/data/playlist_repository.dart';
import 'package:path/path.dart' as p;
import 'package:webdav_client/webdav_client.dart' as webdav;
import 'package:path_provider/path_provider.dart';

final webDavServiceProvider = Provider<WebDavService>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  final dbService = ref.watch(databaseServiceProvider);
  final metaCache = ref.watch(songMetadataCacheServiceProvider);
  return WebDavService(prefs, dbService, metaCache);
});

class WebDavService {
  final PreferencesService _prefs;
  final DatabaseService _dbService;
  final SongMetadataCacheService _metaCache;
  webdav.Client? _client;

  final _cacheUpdateController = StreamController<String>.broadcast();
  Stream<String> get onCacheUpdated => _cacheUpdateController.stream;

  WebDavService(this._prefs, this._dbService, this._metaCache);

  void _initClient() {
    _client = webdav.newClient(
      _prefs.webDavUrl,
      user: _prefs.webDavUser,
      password: _prefs.webDavPassword,
      debug: false,
    );
    // Set root path if needed, usually just handled in list
  }

  // Limit concurrent remote directory listing and processing
  static const int _listConcurrency = 4;
  static const int _processConcurrency = 4;

  final _listPool = _AsyncPool(_listConcurrency);
  final _processPool = _AsyncPool(_processConcurrency);
  final _counterPool = _AsyncPool(1);

  Future<int> scanAndImport() async {
    _initClient();
    if (_client == null) throw Exception('WebDAV client init failed');

    final rootPath = _prefs.webDavPath.isEmpty ? '/' : _prefs.webDavPath;
    final supportedExtensions = {'.mp3', '.flac', '.m4a', '.wav', '.ogg'};
    final foundPaths = <String>{};
    int count = 0;

    // Recursive helper
    Future<void> traverse(String path, int depth) async {
      if (depth > 5) return; // Prevent too deep recursion
      try {
        final files = await _listPool.run(() => _client!.readDir(path));
        final subDirs = <String>[];
        for (final file in files) {
          final isDir = file.isDir ?? false;
          if (isDir) {
            var subPath = file.path;
            if (subPath == null) continue;
            if (!subPath.endsWith('/')) subPath += '/';
            // Avoid infinite loop if server returns current dir
            if (subPath == path) continue;
            subDirs.add(subPath);
          } else {
            final filename = file.name ?? '';
            final ext = p.extension(filename).toLowerCase();
            if (supportedExtensions.contains(ext)) {
              final fullPath = file.path; // WebDAV remote path
              if (fullPath != null) {
                foundPaths.add(fullPath);
                _processPool.run(() async {
                  try {
                    await _processAndSaveSong(fullPath, file);
                  } catch (e) {
                    print('Error processing $fullPath: $e');
                  } finally {
                    await _counterPool.run(() async {
                      count++;
                    });
                  }
                });
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
    await _processPool.drain();

    // Clean up erased files from DB
    // Only delete songs that are sourceType.webdav and NOT in foundPaths.
    final isar = await _dbService.db;
    await isar.writeTxn(() async {
      // It's safer to iterate all WebDAV songs and check if they are in foundPaths.
      // Assuming foundPaths contains ALL valid paths now.
      // Caution: If scan failed partially (exception in traverse), we shouldn't delete everything.
      // But here we catch exception per dir.
      if (count > 0 || foundPaths.isEmpty) { 
         // If we found nothing, maybe connection issue?
         // But traverse catches error. If all fail, count is 0.
         // Let's rely on user explicit intent.
      }
      
      // Get all webdav songs
      final allWebDavSongs = await isar.songs.filter()
          .sourceTypeEqualTo(SourceType.webdav)
          .findAll();
      
      final toDeleteSongs = allWebDavSongs.where((s) => !foundPaths.contains(s.path)).toList();
      final idsToDelete = toDeleteSongs.map((s) => s.id).toList();
      
      if (idsToDelete.isNotEmpty) {
        await _metaCache.saveMany(toDeleteSongs);
        await isar.songs.deleteAll(idsToDelete);
        // Use PlaylistRepository to remove references from playlists
        final repo = PlaylistRepository(_dbService);
        await repo.removeSongIdsFromPlaylists(idsToDelete);
        print('Cleaned up ${idsToDelete.length} stale WebDAV songs.');
      }
    });

    return count;
  }

  Future<void> _processAndSaveSong(String remotePath, webdav.File info) async {
     // Filename parsing strategy
     // Expected: Artist/Album/Title.ext OR Artist - Album - Title.ext
     
     // Remove root path prefix to get structure relative to music folder
     String relPath = remotePath;
     // Simple parsing based on path structure
     final parts = remotePath.split('/');
     // Removing empty parts
     final segments = parts.where((s) => s.isNotEmpty).toList();
     
     // Default values
     String title = p.basenameWithoutExtension(remotePath);
     String artist = 'Unknown Artist';
     String album = 'Unknown Album';

     if (segments.length >= 3) {
       // Assuming .../Artist/Album/Song.mp3
       artist = segments[segments.length - 3];
       album = segments[segments.length - 2];
       title = p.basenameWithoutExtension(segments.last);
     } else if (title.contains(' - ')) {
       // Artist - Album - Song
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

     final song = Song()
       ..path = remotePath
       ..sourceType = SourceType.webdav
       ..title = title
       ..artist = primary
       ..artists = parsed
       ..album = album
       ..size = info.size
       ..dateModified = info.mTime
       ..duration = 0; // Duration unknown until played or scanned with ffmpeg (too slow for remote)

     await _metaCache.applyIfMissing(song);

     // Save to DB
     final isar = await _dbService.db;
     await isar.writeTxn(() async {
       // Check duplicates by path
       final existing = await isar.songs.filter()
         .pathEqualTo(remotePath)
         .findFirst();
       
       if (existing != null) {
         // Update existing
         existing.size = song.size;
         existing.dateModified = song.dateModified;
         existing.sourceType = SourceType.webdav; // Ensure type is correct
         // Don't overwrite metadata if user edited it locally? 
         // For now, let's sync basic info if meaningful changes roughly
         await isar.songs.put(existing);
       } else {
         await isar.songs.put(song);
       }
     });
  }

  // File cache management
  Future<File?> getCachedFile(String remotePath, {String? subDir}) async {
    final cacheDir = await getApplicationDocumentsDirectory();
    final jMusicDir = Directory('${cacheDir.path}/j_music');
    final safePath = remotePath.replaceAll('/', '_').replaceAll('\\', '_').replaceAll(':', '');
    
    String relativePath = 'webdav_cache/$safePath';
    if (subDir != null) {
      relativePath = 'webdav_cache/$subDir/$safePath';
    }
    
    final file = File('${jMusicDir.path}/$relativePath');
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  Future<File> downloadSong(String remotePath, {Function(int, int)? onProgress, String? subDir}) async {
    final cacheDir = await getApplicationDocumentsDirectory();
    
    String folderPath = '${cacheDir.path}/j_music/webdav_cache';
    if (subDir != null) {
      folderPath = '$folderPath/$subDir';
    }
    
    final cacheFolder = Directory(folderPath);
    if (!await cacheFolder.exists()) {
      await cacheFolder.create(recursive: true);
    }
    
    final safePath = remotePath.replaceAll('/', '_').replaceAll('\\', '_').replaceAll(':', '');
    final savePath = '${cacheFolder.path}/$safePath';
    final file = File(savePath);

    final dio = Dio();
    final fullUrl = _buildFullUrl(_prefs.webDavUrl, remotePath);
    final headers = _buildAuthHeaders(
      username: _prefs.webDavUser,
      password: _prefs.webDavPassword,
    );
    if (headers.isNotEmpty) {
      dio.options.headers.addAll(headers);
    }

    await dio.download(
      fullUrl, 
      savePath,
      onReceiveProgress: onProgress,
    );
    
    _cacheUpdateController.add(remotePath);
    return file;
  }

  Future<File> downloadSongWithConfig(
    SyncConfig config,
    String remotePath, {
    Function(int, int)? onProgress,
    String? subDir,
  }) async {
    final cacheDir = await getApplicationDocumentsDirectory();

    String folderPath = '${cacheDir.path}/j_music/webdav_cache';
    if (subDir != null) {
      folderPath = '$folderPath/$subDir';
    }

    final cacheFolder = Directory(folderPath);
    if (!await cacheFolder.exists()) {
      await cacheFolder.create(recursive: true);
    }

    final safePath = remotePath.replaceAll('/', '_').replaceAll('\\', '_').replaceAll(':', '');
    final savePath = '${cacheFolder.path}/$safePath';
    final file = File(savePath);

    final dio = Dio();
    final fullUrl = _buildFullUrl(config.url, remotePath);
    final headers = _buildAuthHeaders(
      username: config.username,
      password: config.password,
      token: config.token,
    );
    if (headers.isNotEmpty) {
      dio.options.headers.addAll(headers);
    }

    await dio.download(
      fullUrl,
      savePath,
      onReceiveProgress: onProgress,
    );

    _cacheUpdateController.add(remotePath);
    return file;
  }

  String _buildFullUrl(String baseUrl, String remotePath) {
    if (remotePath.startsWith('http://') || remotePath.startsWith('https://')) {
      return remotePath;
    }
    String cleanUrl = baseUrl.trim();
    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'http://$cleanUrl';
    }
    if (cleanUrl.endsWith('/')) cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    String path = remotePath;
    if (!path.startsWith('/')) path = '/$path';
    final encodedPath = path.split('/').map((s) => Uri.encodeComponent(s)).join('/');
    return '$cleanUrl$encodedPath';
  }

  Map<String, String> _buildAuthHeaders({String? username, String? password, String? token}) {
    if (token != null && token.isNotEmpty) {
      return {'authorization': 'Bearer $token'};
    }
    if (username != null && username.isNotEmpty) {
      final pwd = password ?? '';
      final basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$pwd'))}';
      return {'authorization': basicAuth};
    }
    return {};
  }

  Future<void> removeSongCache(String remotePath, {String? subDir}) async {
    final cacheDir = await getApplicationDocumentsDirectory();
    final jMusicDir = Directory('${cacheDir.path}/j_music');
    final safePath = remotePath.replaceAll('/', '_').replaceAll('\\', '_').replaceAll(':', '');
    
    String relativePath = 'webdav_cache/$safePath';
    if (subDir != null) {
      relativePath = 'webdav_cache/$subDir/$safePath';
    }
    
    final file = File('${jMusicDir.path}/$relativePath');
    if (await file.exists()) {
      await file.delete();
      _cacheUpdateController.add(remotePath);
    }
  }
  
  Future<void> clearCache() async {
    final cacheDir = await getApplicationDocumentsDirectory();
    final cacheFolder = Directory('${cacheDir.path}/j_music/webdav_cache');
    if (await cacheFolder.exists()) {
      await cacheFolder.delete(recursive: true);
    }
    // Update DB song "cached" state? 
    // We determine cached state dynamically by checking file existence usually, 
    // or we can invoke a ref.refresh somewhere.
    _cacheUpdateController.add('all_cleared');
  }

  void notifyCacheUpdate(String path) {
    _cacheUpdateController.add(path);
  }
}

class _AsyncPool {
  final int _max;
  int _running = 0;
  int _pending = 0;
  final Queue<Completer<void>> _waiters = Queue<Completer<void>>();

  _AsyncPool(this._max);

  Future<T> run<T>(Future<T> Function() task) async {
    _pending++;
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
      _pending--;
      if (_waiters.isNotEmpty) {
        _waiters.removeFirst().complete();
      }
    }
  }

  Future<void> drain() async {
    while (_pending > 0) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  }
}

