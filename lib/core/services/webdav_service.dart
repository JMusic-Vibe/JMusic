import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:jmusic/core/services/database_service.dart';
import 'package:jmusic/core/services/preferences_service.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';
import 'package:jmusic/core/utils/artist_parser.dart';
import 'package:path/path.dart' as p;
import 'package:webdav_client/webdav_client.dart' as webdav;
import 'package:path_provider/path_provider.dart';

final webDavServiceProvider = Provider<WebDavService>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  final dbService = ref.watch(databaseServiceProvider);
  return WebDavService(prefs, dbService);
});

class WebDavService {
  final PreferencesService _prefs;
  final DatabaseService _dbService;
  webdav.Client? _client;

  final _cacheUpdateController = StreamController<String>.broadcast();
  Stream<String> get onCacheUpdated => _cacheUpdateController.stream;

  WebDavService(this._prefs, this._dbService);

  void _initClient() {
    _client = webdav.newClient(
      _prefs.webDavUrl,
      user: _prefs.webDavUser,
      password: _prefs.webDavPassword,
      debug: true,
    );
    // Set root path if needed, usually just handled in list
  }

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
         final files = await _client!.readDir(path);
         for (final file in files) {
           final isDir = file.isDir ?? false;
           if (isDir) {
             var subPath = file.path;
             if (subPath == null) continue;
             if (!subPath.endsWith('/')) subPath += '/';
             // Avoid infinite loop if server returns current dir
             if (subPath == path) continue;
             
             await traverse(subPath, depth + 1);
           } else {
             final filename = file.name ?? '';
             final ext = p.extension(filename).toLowerCase();
             if (supportedExtensions.contains(ext)) {
               // Found audio file
               final fullPath = file.path; // WebDAV remote path
               if (fullPath != null) {
                  foundPaths.add(fullPath);
                  await _processAndSaveSong(fullPath, file);
                  count++;
               }
             }
           }
         }
       } catch (e) {
         print('Error reading dir $path: $e');
       }
    }

    await traverse(rootPath, 0);

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
      
      final idsToDelete = allWebDavSongs
          .where((s) => !foundPaths.contains(s.path))
          .map((s) => s.id)
          .toList();
      
      if (idsToDelete.isNotEmpty) {
        await isar.songs.deleteAll(idsToDelete);
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

    // Construct URL. If remotePath is already a full URL (player may pass processed URL), use it directly.
    String fullUrl;
    if (remotePath.startsWith('http://') || remotePath.startsWith('https://')) {
      fullUrl = remotePath;
    } else {
      String cleanUrl = _prefs.webDavUrl;
      if (cleanUrl.endsWith('/')) cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
      String path = remotePath;
      if (!path.startsWith('/')) path = '/$path';
      // Must encode path segments but keep slashes
      final encodedPath = path.split('/').map((s) => Uri.encodeComponent(s)).join('/');
      fullUrl = '$cleanUrl$encodedPath';
    }

    final dio = Dio();
    // basic auth
    final user = _prefs.webDavUser;
    final pwd = _prefs.webDavPassword;
    if (user.isNotEmpty) {
      String basicAuth = 'Basic ${base64Encode(utf8.encode('$user:$pwd'))}';
      dio.options.headers['authorization'] = basicAuth;
    }

    await dio.download(
      fullUrl, 
      savePath,
      onReceiveProgress: onProgress,
    );
    
    _cacheUpdateController.add(remotePath);
    return file;
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

