import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:jmusic/core/services/database_service.dart';
import 'package:jmusic/features/sync/domain/entities/sync_config.dart';

final syncConfigRepositoryProvider = Provider<SyncConfigRepository>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return SyncConfigRepository(dbService);
});

class SyncConfigRepository {
  final DatabaseService _dbService;

  SyncConfigRepository(this._dbService);

  Future<List<SyncConfig>> getAllConfigs() async {
    final isar = await _dbService.db;
    return isar.syncConfigs.where().findAll();
  }

  Future<List<SyncConfig>> getEnabledConfigs() async {
    final isar = await _dbService.db;
    return isar.syncConfigs.filter().isEnabledEqualTo(true).findAll();
  }

  Future<void> saveConfig(SyncConfig config) async {
    final isar = await _dbService.db;
    await isar.writeTxn(() async {
      await isar.syncConfigs.put(config);
    });
  }

  Future<void> deleteConfig(int id) async {
    final isar = await _dbService.db;
    await isar.writeTxn(() async {
      await isar.syncConfigs.delete(id);
    });
  }
}

