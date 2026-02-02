import 'package:isar/isar.dart';

enum FilterType {
  artist,
  album,
  folder,
}

class SongFilter {
  final FilterType type;
  final String value;

  const SongFilter(this.type, this.value);
}

