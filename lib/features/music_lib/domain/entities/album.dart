import 'package:isar/isar.dart';

part 'album.g.dart';

@collection
class Album {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String name;

  @Index()
  late String artist;

  String? coverPath; // 专辑封面缓存路径
  
  // 元数据刮削状态
  bool isScraped = false;
  String? musicBrainzId; 
  String? description;
}

