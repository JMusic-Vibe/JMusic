import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/services/preferences_service.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';

final songMetadataCacheServiceProvider = Provider<SongMetadataCacheService>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  return SongMetadataCacheService(prefs);
});

class SongMetadataCacheService {
  static const String _indexKey = 'song_meta_cache_index';
  static const int _maxEntries = 200;
  static const Duration _ttl = Duration(days: 30);

  final PreferencesService _prefs;

  SongMetadataCacheService(this._prefs);

  String _rawKey(SourceType sourceType, int? syncConfigId, String path) =>
      '${sourceType.name}|${syncConfigId ?? ''}|$path';

  String _hash(String input) => md5.convert(utf8.encode(input)).toString();

  String _entryKey(String hash) => 'song_meta_$hash';

  Future<void> saveFromSong(Song song) async {
    final lyrics = song.lyrics?.trim();
    final hasLyrics = lyrics != null && lyrics.isNotEmpty;
    final coverUrl = (song.coverPath != null && song.coverPath!.startsWith('http')) ? song.coverPath : null;

    if (!hasLyrics && coverUrl == null) return;

    final rawKey = _rawKey(song.sourceType, song.syncConfigId, song.path);
    final hash = _hash(rawKey);

    final payload = <String, dynamic>{
      'key': rawKey,
      'ts': DateTime.now().millisecondsSinceEpoch,
      'lyrics': hasLyrics ? lyrics : null,
      'coverUrl': coverUrl,
      'title': song.title,
      'artist': song.artist,
      'album': song.album,
    };

    await _prefs.setString(_entryKey(hash), jsonEncode(payload));
    await _touchIndex(hash);
  }

  Future<void> saveMany(Iterable<Song> songs) async {
    for (final s in songs) {
      await saveFromSong(s);
    }
  }

  Future<_SongMeta?> getMeta(SourceType sourceType, int? syncConfigId, String path) async {
    final rawKey = _rawKey(sourceType, syncConfigId, path);
    final hash = _hash(rawKey);
    final raw = _prefs.getString(_entryKey(hash));
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        final meta = _SongMeta.fromMap(decoded);
        if (meta.isExpired(_ttl)) {
          await _prefs.removeKey(_entryKey(hash));
          await _removeFromIndex(hash);
          return null;
        }
        return meta;
      }
      if (decoded is Map) {
        final meta = _SongMeta.fromMap(Map<String, dynamic>.from(decoded));
        if (meta.isExpired(_ttl)) {
          await _prefs.removeKey(_entryKey(hash));
          await _removeFromIndex(hash);
          return null;
        }
        return meta;
      }
    } catch (_) {}
    return null;
  }

  Future<void> applyIfMissing(Song song) async {
    final meta = await getMeta(song.sourceType, song.syncConfigId, song.path);
    if (meta == null) return;

    final hasLyrics = song.lyrics != null && song.lyrics!.trim().isNotEmpty;
    if (!hasLyrics && meta.lyrics != null && meta.lyrics!.trim().isNotEmpty) {
      song.lyrics = meta.lyrics;
    }

    final cover = song.coverPath ?? '';
    final hasCover = cover.trim().isNotEmpty;
    if (!hasCover && meta.coverUrl != null && meta.coverUrl!.trim().isNotEmpty) {
      song.coverPath = meta.coverUrl;
    }
  }

  Future<void> _touchIndex(String hash) async {
    final keys = _prefs.getStringList(_indexKey);
    final nowKeys = [...keys.where((k) => k != hash), hash];
    await _prefs.setStringList(_indexKey, nowKeys);
    await _prune(nowKeys);
  }

  Future<void> _removeFromIndex(String hash) async {
    final keys = _prefs.getStringList(_indexKey);
    if (keys.isEmpty) return;
    final nowKeys = keys.where((k) => k != hash).toList();
    await _prefs.setStringList(_indexKey, nowKeys);
  }

  Future<void> _prune(List<String> keys) async {
    if (keys.isEmpty) return;
    final entries = <_IndexedEntry>[];
    for (final hash in keys) {
      final raw = _prefs.getString(_entryKey(hash));
      if (raw == null || raw.isEmpty) continue;
      try {
        final decoded = jsonDecode(raw);
        final map = decoded is Map<String, dynamic>
            ? decoded
            : (decoded is Map ? Map<String, dynamic>.from(decoded) : null);
        if (map == null) continue;
        final ts = map['ts'] is int ? map['ts'] as int : 0;
        if (ts == 0) continue;
        entries.add(_IndexedEntry(hash, ts));
      } catch (_) {}
    }

    // remove expired first
    final now = DateTime.now().millisecondsSinceEpoch;
    final expired = entries.where((e) => now - e.ts > _ttl.inMilliseconds).toList();
    for (final e in expired) {
      await _prefs.removeKey(_entryKey(e.hash));
    }

    final remaining = entries.where((e) => now - e.ts <= _ttl.inMilliseconds).toList();
    if (remaining.length <= _maxEntries) return;

    remaining.sort((a, b) => a.ts.compareTo(b.ts));
    final toRemove = remaining.length - _maxEntries;
    for (int i = 0; i < toRemove; i++) {
      await _prefs.removeKey(_entryKey(remaining[i].hash));
    }

    final updated = remaining.sublist(toRemove).map((e) => e.hash).toList();
    await _prefs.setStringList(_indexKey, updated);
  }
}

class _SongMeta {
  final int ts;
  final String? lyrics;
  final String? coverUrl;

  _SongMeta({required this.ts, this.lyrics, this.coverUrl});

  factory _SongMeta.fromMap(Map<String, dynamic> map) {
    return _SongMeta(
      ts: map['ts'] is int ? map['ts'] as int : 0,
      lyrics: map['lyrics']?.toString(),
      coverUrl: map['coverUrl']?.toString(),
    );
  }

  bool isExpired(Duration ttl) {
    if (ts <= 0) return true;
    final now = DateTime.now().millisecondsSinceEpoch;
    return now - ts > ttl.inMilliseconds;
  }
}

class _IndexedEntry {
  final String hash;
  final int ts;
  _IndexedEntry(this.hash, this.ts);
}
