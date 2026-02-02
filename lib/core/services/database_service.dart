import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';
import 'package:jmusic/features/music_lib/domain/entities/album.dart';
import 'package:jmusic/features/music_lib/domain/entities/artist.dart';
import 'package:jmusic/features/music_lib/domain/entities/playlist.dart';
import 'package:jmusic/features/sync/domain/entities/sync_config.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

class DatabaseService {
  late Future<Isar> db;

  DatabaseService() {
    db = _initDb();
  }

  Future<Isar> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [
          SongSchema, 
          AlbumSchema,
          ArtistSchema,
          PlaylistSchema,
          SyncConfigSchema,
        ],
        directory: dir.path,
        inspector: true, // 调试模式开关?inspector
      );
    }
    return Isar.getInstance()!;
  }

  // 清空数据�?(调试�?
  Future<void> cleanDb() async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.clear();
    });
  }
}

