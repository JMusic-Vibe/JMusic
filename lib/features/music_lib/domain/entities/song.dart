import 'package:isar/isar.dart';

part 'song.g.dart';

enum SourceType {
  local,
  webdav,
  openlist
}

enum MediaType {
  audio,
  video,
}

@collection
class Song {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String path; // 本地绝对路径, 或 WebDAV 的相对路径

  @enumerated
  SourceType sourceType = SourceType.local;
  
  // Link to SyncConfig if sourceType is webdav/openlist
  int? syncConfigId;

  @enumerated
  MediaType mediaType = MediaType.audio;

  late String title;
  
  @Index()
  late String artist;
  
  /// Parsed list of individual artists (e.g. ["Artist A", "Artist B"]).
  /// Keep `artist` as the primary/display artist for backward compatibility.
  List<String> artists = [];
  
  @Index()
  late String album;

  double? duration; // 秒
  
  // 扩展元数据
  String? genre;
  int? year;
  int? trackNumber;
  int? discNumber;
  String? lyrics; // 内嵌歌词
  int? lyricsDurationMs; // 歌词（LRC）时长，毫秒
  
  // 文件信息
  int? size;
  DateTime? dateAdded;
  DateTime? dateModified;
  DateTime? lastPlayed;
  
  // 封面缓存路径 (本地或URL)
  String? coverPath;

  // 云端/远程相关
  String? remoteId; // OpenList file ID or WebDAV unique identifier
  String? remoteUrl; // 用于播放的直链?(有失效时间需刷新)

  // 刮削信息
  String? musicBrainzId; // Recording MBID
  double? acousticFingerprintConfidence; // 识别置信度
  // 刮削来源与来源ID（例如: qqmusic + songmid, musicbrainz + mbid）
  String? scrapedSource;
  String? scrapedSourceId;
  
  /// 创建副本并更新指定字段
  Song copyWith({
    String? path,
    SourceType? sourceType,
    int? syncConfigId,
    MediaType? mediaType,
    String? title,
    String? artist,
    List<String>? artists,
    String? album,
    double? duration,
    String? genre,
    int? year,
    int? trackNumber,
    int? discNumber,
    String? lyrics,
    int? lyricsDurationMs,
    int? size,
    DateTime? dateAdded,
    DateTime? dateModified,
    DateTime? lastPlayed,
    String? coverPath,
    String? remoteId,
    String? remoteUrl,
    String? musicBrainzId,
    String? scrapedSource,
    String? scrapedSourceId,
    double? acousticFingerprintConfidence,
  }) {
    final copy = Song()
      ..id = id
      ..path = path ?? this.path
      ..sourceType = sourceType ?? this.sourceType
      ..syncConfigId = syncConfigId ?? this.syncConfigId
      ..mediaType = mediaType ?? this.mediaType
      ..title = title ?? this.title
      ..artist = artist ?? this.artist
      ..artists = artists ?? this.artists
      ..album = album ?? this.album
      ..duration = duration ?? this.duration
      ..genre = genre ?? this.genre
      ..year = year ?? this.year
      ..trackNumber = trackNumber ?? this.trackNumber
      ..discNumber = discNumber ?? this.discNumber
      ..lyrics = lyrics ?? this.lyrics
      ..lyricsDurationMs = lyricsDurationMs ?? this.lyricsDurationMs
      ..size = size ?? this.size
      ..dateAdded = dateAdded ?? this.dateAdded
      ..dateModified = dateModified ?? this.dateModified
      ..lastPlayed = lastPlayed ?? this.lastPlayed
      ..coverPath = coverPath ?? this.coverPath
      ..remoteId = remoteId ?? this.remoteId
      ..remoteUrl = remoteUrl ?? this.remoteUrl
      ..musicBrainzId = musicBrainzId ?? this.musicBrainzId
      ..scrapedSource = scrapedSource ?? this.scrapedSource
      ..scrapedSourceId = scrapedSourceId ?? this.scrapedSourceId
      ..acousticFingerprintConfidence = acousticFingerprintConfidence ?? this.acousticFingerprintConfidence;
    return copy;
  }
}

