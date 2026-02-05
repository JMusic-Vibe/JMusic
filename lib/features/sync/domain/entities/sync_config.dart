import 'package:isar/isar.dart';

part 'sync_config.g.dart';

enum SyncType {
  webdav,
  openlist
}

@collection
class SyncConfig {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name; // e.g. "My NAS", "Alist"

  @enumerated
  late SyncType type;

  late String url; // Base URL
  // Remote path to music folder
  String? path;
  
  String? username;
  String? password;
  
  // OpenList 特有
  String? token;

  bool isEnabled = true;
  
  DateTime? lastSyncTime;
}

