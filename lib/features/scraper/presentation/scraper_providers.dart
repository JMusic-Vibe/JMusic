import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:jmusic/core/services/database_service.dart';
import 'package:jmusic/core/services/audio_player_service.dart';
import 'package:jmusic/core/services/preferences_service.dart';
import 'package:jmusic/core/services/cover_cache_service.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';
import 'package:jmusic/core/utils/artist_parser.dart';
import 'package:jmusic/features/music_lib/domain/entities/artist.dart';
import 'package:jmusic/features/scraper/data/artist_sources/artist_scraper_service.dart';

final unscrapedSongsProvider = FutureProvider<List<Song>>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  final isar = await dbService.db;

  // 查找 musicBrainzId 为 null 或空的歌曲
  // 也可以加一个 isScraped 字段，目前先用 musicBrainzId 判断
  return isar.songs
      .filter()
      .musicBrainzIdIsNull()
      .or()
      .musicBrainzIdIsEmpty()
      .findAll();
});

// All songs stream for scraper-center filtering (missing metadata, cover, etc.)
final scraperCandidatesProvider = StreamProvider<List<Song>>((ref) async* {
  final dbService = ref.watch(databaseServiceProvider);
  final isar = await dbService.db;
  yield* isar.songs.where().watch(fireImmediately: true);
});

final scraperControllerProvider = Provider((ref) => ScraperController(ref));
final artistScraperControllerProvider =
    Provider((ref) => ArtistScraperController(ref));

class ScraperController {
  final Ref _ref;

  ScraperController(this._ref);

  Future<void> _ensureScrapeBackup(
      Isar isar, PreferencesService prefs, int songId) async {
    final existingBackup = prefs.getScrapeBackup(songId);
    if (existingBackup != null) return;
    final song = await isar.songs.get(songId);
    if (song == null) return;
    await prefs.saveScrapeBackup(songId, {
      'title': song.title,
      'artist': song.artist,
      'artists': song.artists,
      'album': song.album,
      'year': song.year,
      'coverPath': song.coverPath,
      'lyrics': song.lyrics,
      'musicBrainzId': song.musicBrainzId,
    });
  }

  Future<void> updateSongMetadata(
    int songId, {
    required String title,
    required String artist,
    required String album,
    String? mbId,
    String? coverUrl,
    int? year,
    String? lyrics,
    int? lyricsDurationMs,
  }) async {
    final dbService = _ref.read(databaseServiceProvider);
    final prefs = _ref.read(preferencesServiceProvider);
    final isar = await dbService.db;
    if (coverUrl != null && coverUrl.trim().isNotEmpty) {
      try {
        await CoverCacheService().getOrDownload(coverUrl);
      } catch (_) {}
    }

    await isar.writeTxn(() async {
      final song = await isar.songs.get(songId);
      if (song != null) {
        await _ensureScrapeBackup(isar, prefs, songId);
        song.title = title;
        // parse artists and set primary for backward compatibility
        final parsed = parseArtists(artist);
        song.artist = parsed.isNotEmpty ? parsed.first : artist;
        song.artists = parsed;
        song.album = album;
        song.musicBrainzId = mbId;
        song.year = year;
        if (lyrics != null && lyrics.trim().isNotEmpty) {
          song.lyrics = lyrics;
        }
        if (lyricsDurationMs != null) {
          song.lyricsDurationMs = lyricsDurationMs;
        }

        // 优先保留封面URL，便于缓存清理后可重新拉取
        if (coverUrl != null && coverUrl.trim().isNotEmpty) {
          print('[ScraperController] Updating DB with coverUrl: $coverUrl');
          song.coverPath = coverUrl;
        } else {
          print(
              '[ScraperController] No coverUrl provided. Existing path: ${song.coverPath}');
        }

        await isar.songs.put(song);

        // Notify AudioPlayerService
        final playerService = _ref.read(audioPlayerServiceProvider);
        await playerService.updateMetadata(song);
      }
    });

    _ref.invalidate(unscrapedSongsProvider);
  }

  Future<void> clearLyrics(int songId) async {
    final dbService = _ref.read(databaseServiceProvider);
    final prefs = _ref.read(preferencesServiceProvider);
    final isar = await dbService.db;

    await isar.writeTxn(() async {
      await _ensureScrapeBackup(isar, prefs, songId);
      final song = await isar.songs.get(songId);
      if (song == null) return;
      song.lyrics = null;
      song.lyricsDurationMs = null;
      await isar.songs.put(song);
      final playerService = _ref.read(audioPlayerServiceProvider);
      await playerService.updateMetadata(song);
    });
  }

  Future<void> clearBasicInfo(int songId) async {
    final dbService = _ref.read(databaseServiceProvider);
    final prefs = _ref.read(preferencesServiceProvider);
    final isar = await dbService.db;

    await isar.writeTxn(() async {
      await _ensureScrapeBackup(isar, prefs, songId);
      final song = await isar.songs.get(songId);
      if (song == null) return;
      song.artist = '';
      song.artists = [];
      song.album = '';
      song.year = null;
      song.coverPath = null;
      song.musicBrainzId = null;
      await isar.songs.put(song);
      final playerService = _ref.read(audioPlayerServiceProvider);
      await playerService.updateMetadata(song);
    });
    _ref.invalidate(unscrapedSongsProvider);
  }

  Future<bool> restoreSongMetadata(int songId) async {
    final dbService = _ref.read(databaseServiceProvider);
    final prefs = _ref.read(preferencesServiceProvider);
    final backup = prefs.getScrapeBackup(songId);
    if (backup == null) return false;

    final isar = await dbService.db;
    await isar.writeTxn(() async {
      final song = await isar.songs.get(songId);
      if (song == null) return;

      song.title = (backup['title'] as String?) ?? song.title;
      final artist = (backup['artist'] as String?) ?? song.artist;
      final artistsRaw = backup['artists'];
      if (artistsRaw is List) {
        song.artists = artistsRaw.whereType<String>().toList();
      } else {
        song.artists = parseArtists(artist);
      }
      song.artist = song.artists.isNotEmpty ? song.artists.first : artist;
      song.album = (backup['album'] as String?) ?? song.album;
      song.year = backup['year'] as int?;
      song.coverPath = backup['coverPath'] as String?;
      song.lyrics = backup['lyrics'] as String?;
      song.musicBrainzId = backup['musicBrainzId'] as String?;

      await isar.songs.put(song);

      final playerService = _ref.read(audioPlayerServiceProvider);
      await playerService.updateMetadata(song);
    });

    await prefs.removeScrapeBackup(songId);
    _ref.invalidate(unscrapedSongsProvider);
    return true;
  }

  Future<int> restoreSongsMetadata(List<int> songIds) async {
    int restored = 0;
    for (final id in songIds) {
      final ok = await restoreSongMetadata(id);
      if (ok) restored++;
    }
    return restored;
  }
}

class ArtistScraperController {
  final Ref _ref;

  ArtistScraperController(this._ref);

  bool _isUnknownOrEmpty(String? value) {
    if (value == null) return true;
    final v = value.trim();
    if (v.isEmpty) return true;
    final lower = v.toLowerCase();
    if (lower.contains('unknown') || lower.contains('unknow')) return true;
    if (v.contains('未知')) return true;
    return false;
  }

  Future<bool> scrapeArtist(String name, {bool force = false}) async {
    if (_isUnknownOrEmpty(name)) return false;
    final db = await _ref.read(databaseServiceProvider).db;
    final service = _ref.read(artistScraperServiceProvider);
    final prefs = _ref.read(preferencesServiceProvider);
    final useMb = prefs.scraperArtistSourceMusicBrainz;
    final useItunes = prefs.scraperArtistSourceItunes;
    final useQQ = prefs.scraperArtistSourceQQMusic;
    if (!useMb && !useItunes && !useQQ) return false;

    final existing = await db.artists.filter().nameEqualTo(name).findFirst();
    if (!force && existing != null) {
      if ((existing.localImagePath != null &&
              existing.localImagePath!.isNotEmpty) ||
          (existing.imageUrl != null && existing.imageUrl!.isNotEmpty)) {
        return true;
      }
    }

    String? imageUrl;
    if (useMb) {
      imageUrl = await service.fetchArtistImageUrl(name);
    }
    if ((imageUrl == null || imageUrl.isEmpty) && useItunes) {
      imageUrl = await service.fetchArtistImageUrlFromItunes(name);
    }
    if ((imageUrl == null || imageUrl.isEmpty) && useQQ) {
      imageUrl = await service.fetchArtistImageUrlFromQQ(name);
    }
    if (imageUrl == null || imageUrl.isEmpty) return false;

    final cachedPath = await CoverCacheService()
        .getOrDownload(imageUrl, subDir: CoverCacheService.artistAvatarSubDir);

    await db.writeTxn(() async {
      final artist = existing ?? Artist()
        ..name = name;
      artist.imageUrl = imageUrl;
      artist.localImagePath = cachedPath;
      artist.isScraped = true;
      await db.artists.put(artist);
    });
    return true;
  }

  Future<void> saveArtistSelection({
    required String name,
    required String mbId,
    required String imageUrl,
  }) async {
    if (name.trim().isEmpty || imageUrl.trim().isEmpty) return;
    final db = await _ref.read(databaseServiceProvider).db;
    final cachedPath = await CoverCacheService()
        .getOrDownload(imageUrl, subDir: CoverCacheService.artistAvatarSubDir);
    await db.writeTxn(() async {
      final existing = await db.artists.filter().nameEqualTo(name).findFirst();
      final artist = existing ?? Artist()
        ..name = name;
      artist.musicBrainzId = mbId;
      artist.imageUrl = imageUrl;
      artist.localImagePath = cachedPath;
      artist.isScraped = true;
      await db.artists.put(artist);
    });
  }

  Future<int> scrapeArtistsForSongs(List<Song> songs,
      {bool force = false}) async {
    final names = <String>{};
    for (final song in songs) {
      if (song.artists.isNotEmpty) {
        names.addAll(song.artists);
      } else {
        names.add(song.artist);
      }
    }
    return scrapeArtistsByNames(names.toList(), force: force);
  }

  Future<int> scrapeArtistsByNames(List<String> names,
      {bool force = false}) async {
    int ok = 0;
    for (final name in names) {
      final success = await scrapeArtist(name, force: force);
      if (success) ok++;
    }
    return ok;
  }

  Future<int> restoreArtists(List<String> names) async {
    final db = await _ref.read(databaseServiceProvider).db;
    int restored = 0;
    for (final name in names) {
      final existing = await db.artists.filter().nameEqualTo(name).findFirst();
      if (existing != null) {
        await db.writeTxn(() async {
          existing.imageUrl = null;
          existing.localImagePath = null;
          existing.isScraped = false;
          await db.artists.put(existing);
        });
        restored++;
      }
    }
    return restored;
  }

  Future<bool> restoreArtistAvatar(String name) async {
    final db = await _ref.read(databaseServiceProvider).db;
    final existing = await db.artists.filter().nameEqualTo(name).findFirst();
    if (existing != null) {
      await db.writeTxn(() async {
        existing.imageUrl = null;
        existing.localImagePath = null;
        existing.isScraped = false;
        await db.artists.put(existing);
      });
      return true;
    }
    return false;
  }
}

// Progress tracking for batch scraping
class ScrapeProgress {
  final int total;
  final int done;
  final String? currentTitle;
  final bool isRunning;
  final bool cancelled;

  ScrapeProgress(
      {this.total = 0,
      this.done = 0,
      this.currentTitle,
      this.isRunning = false,
      this.cancelled = false});

  ScrapeProgress copyWith(
      {int? total,
      int? done,
      String? currentTitle,
      bool? isRunning,
      bool? cancelled}) {
    return ScrapeProgress(
      total: total ?? this.total,
      done: done ?? this.done,
      currentTitle: currentTitle ?? this.currentTitle,
      isRunning: isRunning ?? this.isRunning,
      cancelled: cancelled ?? this.cancelled,
    );
  }
}

class ScrapeProgressNotifier extends StateNotifier<ScrapeProgress> {
  ScrapeProgressNotifier() : super(ScrapeProgress());

  void start(int total) {
    state = ScrapeProgress(
        total: total, done: 0, isRunning: true, cancelled: false);
  }

  void updateCurrent(String? title) {
    state = state.copyWith(currentTitle: title);
  }

  void increment() {
    state = state.copyWith(done: state.done + 1);
  }

  void cancel() {
    state = state.copyWith(cancelled: true, isRunning: false);
  }

  void finish() {
    state = state.copyWith(isRunning: false);
  }
}

final scrapeProgressProvider =
    StateNotifierProvider<ScrapeProgressNotifier, ScrapeProgress>((ref) {
  return ScrapeProgressNotifier();
});
