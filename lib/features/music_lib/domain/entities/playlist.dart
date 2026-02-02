import 'package:isar/isar.dart';

part 'playlist.g.dart';

@collection
class Playlist {
  Id id = Isar.autoIncrement;

  @Index()
  late String name;

  String? description;

  // New: Smart playlist criteria
  bool isSmart = false;
  String? filterType; // 'artist', 'album', 'genre', 'date_added'
  String? filterValue; 

  DateTime createdAt = DateTime.now();
  
  DateTime updatedAt = DateTime.now();

  // 存储歌曲 ID 的列表，保持顺序
  List<int> songIds = [];
  
  // 封面图（通常是第一首歌的封面）
  String? coverPath;
}

