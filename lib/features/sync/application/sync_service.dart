import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:jmusic/core/services/database_service.dart';
import 'package:jmusic/core/services/webdav_service.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';
import 'package:jmusic/core/utils/artist_parser.dart';
import 'package:jmusic/features/sync/data/sync_config_repository.dart';
import 'package:jmusic/features/sync/domain/entities/sync_config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;
import 'package:path/path.dart' as p;

final syncServiceProvider = Provider<SyncService>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  final syncRepo = ref.watch(syncConfigRepositoryProvider);
  final webDavService = ref.watch(webDavServiceProvider);
  return SyncService(dbService, syncRepo, webDavService);
});

class SyncService {
  final DatabaseService _dbService;
  final SyncConfigRepository _syncRepo;
  final WebDavService _webDavService;

  SyncService(this._dbService, this._syncRepo, this._webDavService);

  /// Synchronize a specific account
  Future<void> syncAccount(SyncConfig config) async {
    if (config.type == SyncType.webdav) {
      await _syncWebDav(config);
    } else {
      // OpenAList not implemented yet
    }
  }

  Future<void> _syncWebDav(SyncConfig config) async {
    final client = webdav.newClient(
      config.url,
      user: config.username ?? '',
      password: config.password ?? '',
      debug: true,
    );

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
    
    final supportedExtensions = {'.mp3', '.flac', '.m4a', '.wav', '.ogg'};
    final foundPaths = <String>{};
    
    Future<void> traverse(String path, int depth) async {
       if (depth > 10) return; // Safety break
       try {
         final files = await client.readDir(path);
         for (final file in files) {
           final isDir = file.isDir ?? false;
           if (isDir) {
             var subPath = file.path;
             if (subPath == null) continue;
             if (!subPath.endsWith('/')) subPath += '/';
             // Prevent infinite recursion if server returns self
             if (subPath == path) continue; 
             await traverse(subPath, depth + 1);
           } else {
             final filename = file.name ?? '';
             final ext = p.extension(filename).toLowerCase();
             if (supportedExtensions.contains(ext)) {
               final fullPath = file.path;
               if (fullPath != null) {
                  foundPaths.add(fullPath);
                  await _processAndSaveSong(fullPath, file, config);
               }
             }
           }
         }
       } catch (e) {
         print('Error reading dir $path: $e');
       }
    }

    await traverse(rootPath, 0);

    // Cleanup songs that are no longer in the source
    final isar = await _dbService.db;
    await isar.writeTxn(() async {
      final oldSongs = await isar.songs.filter()
          .syncConfigIdEqualTo(config.id)
          .findAll();
      
      final idsToDelete = oldSongs
          .where((s) => !foundPaths.contains(s.path))
          .map((s) => s.id)
          .toList();
      
      if (idsToDelete.isNotEmpty) {
        await isar.songs.deleteAll(idsToDelete);
      }
      
      // Update config lastSyncTime
      config.lastSyncTime = DateTime.now();
      await isar.syncConfigs.put(config);
    });
  }

  Future<void> _processAndSaveSong(String remotePath, webdav.File info, SyncConfig config) async {
     String title = p.basenameWithoutExtension(remotePath);
     String artist = 'Unknown Artist';
     String album = 'Unknown Album';
     
     // Basic parsing logic (Same as legacy)
     final parts = remotePath.split('/');
     final segments = parts.where((s) => s.isNotEmpty).toList();
     if (segments.length >= 3) {
       artist = segments[segments.length - 3];
       album = segments[segments.length - 2];
       title = p.basenameWithoutExtension(segments.last);
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

     final song = Song()
       ..path = remotePath
       ..sourceType = SourceType.webdav
       ..syncConfigId = config.id
       ..title = title
       ..artist = primary
       ..artists = parsed
       ..album = album
       ..size = info.size
       ..dateModified = info.mTime
       ..duration = 0;

     final isar = await _dbService.db;
     await isar.writeTxn(() async {
       // Check for existing song with same path AND syncConfigId
       final existing = await isar.songs.filter()
         .syncConfigIdEqualTo(config.id)
         .pathEqualTo(remotePath)
         .findFirst();
       
       if (existing != null) {
         existing.size = song.size;
         existing.dateModified = song.dateModified;
         await isar.songs.put(existing);
       } else {
         await isar.songs.put(song);
       }
     });
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
}

