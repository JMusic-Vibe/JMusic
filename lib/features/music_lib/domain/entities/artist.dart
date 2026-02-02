import 'package:isar/isar.dart';

part 'artist.g.dart';

@collection
class Artist {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String name;

  String? musicBrainzId; // Artist MBID
  
  String? description;
  
  String? imageUrl; // 远程图片地址
  String? localImagePath; // 本地缓存路径

  bool isScraped = false;
}

