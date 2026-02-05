import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/services/database_service.dart';
import 'package:jmusic/core/services/webdav_service.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';
import 'package:jmusic/features/sync/data/sync_config_repository.dart';

// Provider related to download progress (0.0 to 1.0). Null if not downloading.
final downloadProgressProvider = StateProvider.family<double?, int>((ref, songId) => null);

// Provider to check if a song is cached. Keyed by Song ID.
final songCacheStatusProvider = FutureProvider.family<bool, int>((ref, songId) async {
  final dbService = ref.watch(databaseServiceProvider);
  final webDavService = ref.watch(webDavServiceProvider);

  // We depend on cache updates to refresh this provider
  final subscription = webDavService.onCacheUpdated.listen((updatedPath) {
    if (updatedPath == 'all_cleared') {
      ref.invalidateSelf();
    } else {
      // Since updatedPath is a path string, and we are keyed by ID, 
      // strictly speaking we don't know if matches THIS song without fetching.
      // Optimistic approach: We could fetch the song to check, or just refresh universally if low frequency.
      // Ideally WebDavService could emit IDs, but it doesn't know them.
      // So we will fetch the song here anyway, might as well check path.
    }
  });
  
  // Clean up subscription when provider is disposed
  ref.onDispose(() {
    subscription.cancel();
  });

  // Get song from DB to ensure we have the correct path and syncConfigId
  final db = await dbService.db;
  final song = await db.songs.get(songId);

  if (song == null || (song.sourceType != SourceType.webdav && song.sourceType != SourceType.openlist)) {
    return false;
  }

  // Also check if the updatedPath matches this song's path
  // We attach a listener above, but we also need to react logic inside the body? 
  // No, FutureProvider body runs once. To update, we needs to invalidate.
  // So inside the listen callback above:
  subscription.onData((updatedPath) {
    if (updatedPath == 'all_cleared') {
      ref.invalidateSelf();
    } else if (song.path == updatedPath) {
      ref.invalidateSelf();
    }
  });

  final subDir = song.syncConfigId?.toString();
  final file = await webDavService.getCachedFile(song.path, subDir: subDir);
  return file != null;
});


final downloadManagerProvider = Provider<DownloadManager>((ref) {
  return DownloadManager(ref);
});

class DownloadManager {
  final Ref _ref;

  DownloadManager(this._ref);

  Future<void> startDownload(int songId) async {
    // 1. Get Song fresh from DB
    final dbService = _ref.read(databaseServiceProvider);
    final isar = await dbService.db;
    final song = await isar.songs.get(songId);

    if (song == null) {
      throw Exception('Song not found in database');
    }

    if (song.sourceType != SourceType.webdav && song.sourceType != SourceType.openlist) {
      return; // Not a WebDAV song
    }

    // 2. Set Progress to 0
     _ref.read(downloadProgressProvider(songId).notifier).state = 0.0;

    final webDavService = _ref.read(webDavServiceProvider);
    final syncRepo = _ref.read(syncConfigRepositoryProvider);
    
    try {
      final subDir = song.syncConfigId?.toString();
      if (song.syncConfigId != null) {
        final config = await syncRepo.getConfigById(song.syncConfigId!);
        if (config != null) {
          await webDavService.downloadSongWithConfig(
            config,
            song.path,
            subDir: subDir,
            onProgress: (received, total) {
              if (total > 0) {
                _ref.read(downloadProgressProvider(songId).notifier).state = received / total;
              }
            },
          );
        } else {
          await webDavService.downloadSong(
            song.path,
            subDir: subDir,
            onProgress: (received, total) {
              if (total > 0) {
                _ref.read(downloadProgressProvider(songId).notifier).state = received / total;
              }
            },
          );
        }
      } else {
        await webDavService.downloadSong(
          song.path,
          subDir: subDir,
          onProgress: (received, total) {
            if (total > 0) {
              _ref.read(downloadProgressProvider(songId).notifier).state = received / total;
            }
          },
        );
      }
      
      // Success: Clear progress
      _ref.read(downloadProgressProvider(songId).notifier).state = null;
      // Refresh cache status
      _ref.invalidate(songCacheStatusProvider(songId));
      
    } catch (e) {
      _ref.read(downloadProgressProvider(songId).notifier).state = null;
      rethrow;
    }
  }
}

