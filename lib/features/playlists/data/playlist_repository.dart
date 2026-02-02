import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:jmusic/core/services/database_service.dart';
import 'package:jmusic/features/music_lib/domain/entities/playlist.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return PlaylistRepository(dbService);
});

class PlaylistRepository {
  final DatabaseService _dbService;

  PlaylistRepository(this._dbService);

  Future<List<Playlist>> getPlaylists() async {
    final isar = await _dbService.db;
    return isar.playlists.where().findAll();
  }

  Stream<List<Playlist>> watchPlaylists() async* {
    final isar = await _dbService.db;
    yield* isar.playlists.where().watch(fireImmediately: true);
  }

  Stream<Playlist?> watchPlaylist(int id) async* {
    final isar = await _dbService.db;
    yield* isar.playlists.watchObject(id, fireImmediately: true);
  }

  Future<void> createPlaylist(String name, {String? description}) async {
    final isar = await _dbService.db;
    final playlist = Playlist()
      ..name = name
      ..description = description
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();
    
    await isar.writeTxn(() async {
      await isar.playlists.put(playlist);
    });
  }

  Future<void> deletePlaylist(int playlistId) async {
    final isar = await _dbService.db;
    await isar.writeTxn(() async {
      await isar.playlists.delete(playlistId);
    });
  }

  Future<void> renamePlaylist(int playlistId, String newName) async {
    final isar = await _dbService.db;
    await isar.writeTxn(() async {
      final playlist = await isar.playlists.get(playlistId);
      if (playlist != null) {
        // Protect the internal 'Favorites' playlist from being renamed.
        if (playlist.name == 'Favorites') return;

        playlist.name = newName;
        playlist.updatedAt = DateTime.now();
        await isar.playlists.put(playlist);
      }
    });
  }

  Future<void> addSongsToPlaylist(int playlistId, List<int> songIds) async {
    final isar = await _dbService.db;
    await isar.writeTxn(() async {
      final playlist = await isar.playlists.get(playlistId);
      if (playlist != null) {
        // Append new songs but avoid duplicates while preserving order
        final newIds = playlist.songIds.toList();
        for (final id in songIds) {
          if (!newIds.contains(id)) newIds.add(id);
        }
        playlist.songIds = newIds;
        playlist.updatedAt = DateTime.now();
        
        // Update cover if empty and we added songs
        if (playlist.coverPath == null && songIds.isNotEmpty) {
           final firstSong = await isar.songs.get(songIds.first);
           if (firstSong?.coverPath != null) {
             playlist.coverPath = firstSong!.coverPath;
           }
        }
        
        await isar.playlists.put(playlist);
      }
    });
  }

  Future<void> removeSongFromPlaylist(int playlistId, int songIndex) async {
    final isar = await _dbService.db;
    await isar.writeTxn(() async {
      final playlist = await isar.playlists.get(playlistId);
      if (playlist != null && songIndex >= 0 && songIndex < playlist.songIds.length) {
        // Make a growable copy to avoid operating on fixed-length internal lists.
        final newIds = playlist.songIds.toList();
        newIds.removeAt(songIndex);
        playlist.songIds = newIds;
        playlist.updatedAt = DateTime.now();
        await isar.playlists.put(playlist);
      }
    });
  }

  /// Clear all songs from a playlist
  Future<void> clearPlaylist(int playlistId) async {
    final isar = await _dbService.db;
    await isar.writeTxn(() async {
      final playlist = await isar.playlists.get(playlistId);
      if (playlist != null) {
        playlist.songIds = <int>[];
        playlist.updatedAt = DateTime.now();
        await isar.playlists.put(playlist);
      }
    });
  }

  /// Set playlist cover by copying the selected file into app storage and
  /// storing a local path reference on the playlist.
  Future<void> setPlaylistCoverFromFile(int playlistId, String sourcePath, String destPath) async {
    final isar = await _dbService.db;
    await isar.writeTxn(() async {
      final playlist = await isar.playlists.get(playlistId);
      if (playlist != null) {
        playlist.coverPath = destPath;
        playlist.updatedAt = DateTime.now();
        await isar.playlists.put(playlist);
      }
    });
  }

  Future<void> clearPlaylistCover(int playlistId) async {
    final isar = await _dbService.db;
    await isar.writeTxn(() async {
      final playlist = await isar.playlists.get(playlistId);
      if (playlist != null) {
        playlist.coverPath = null;
        playlist.updatedAt = DateTime.now();
        await isar.playlists.put(playlist);
      }
    });
  }

  /// Get structured songs for a playlist
  Future<List<Song>> getSongsForPlaylist(int playlistId) async {
    final isar = await _dbService.db;
    final playlist = await isar.playlists.get(playlistId);
    if (playlist == null || playlist.songIds.isEmpty) return [];

    // Isar getAll retrieves by ID list. 
    // However, the playlist might contain the same song ID multiple times (if user added duplicate), 
    // or we want to respect the order in playlist.songIds.
    // isar.songs.getAll(ids) returns List<Song?> in the same order as ids.
    final songsOrNull = await isar.songs.getAll(playlist.songIds);
    return songsOrNull.whereType<Song>().toList();
  }

  /// Reorder songs in a playlist safely (handles fixed-length internal lists)
  Future<void> reorderSongsInPlaylist(int playlistId, int oldIndex, int newIndex) async {
    final isar = await _dbService.db;
    await isar.writeTxn(() async {
      final playlist = await isar.playlists.get(playlistId);
      if (playlist != null && oldIndex >= 0 && oldIndex < playlist.songIds.length && newIndex >= 0 && newIndex <= playlist.songIds.length) {
        // Work on a growable copy; `newIndex` is expected to be adjusted by the caller
        // (e.g., the UI) to match the desired insertion point. Apply the insertion directly.
        final newIds = playlist.songIds.toList();
        final songId = newIds.removeAt(oldIndex);
        newIds.insert(newIndex, songId);
        playlist.songIds = newIds;
        playlist.updatedAt = DateTime.now();
        await isar.playlists.put(playlist);
      }
    });
  }
}

