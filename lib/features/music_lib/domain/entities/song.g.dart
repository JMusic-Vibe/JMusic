// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSongCollection on Isar {
  IsarCollection<Song> get songs => this.collection();
}

const SongSchema = CollectionSchema(
  name: r'Song',
  id: -5548886644249537934,
  properties: {
    r'acousticFingerprintConfidence': PropertySchema(
      id: 0,
      name: r'acousticFingerprintConfidence',
      type: IsarType.double,
    ),
    r'album': PropertySchema(
      id: 1,
      name: r'album',
      type: IsarType.string,
    ),
    r'artist': PropertySchema(
      id: 2,
      name: r'artist',
      type: IsarType.string,
    ),
    r'artists': PropertySchema(
      id: 3,
      name: r'artists',
      type: IsarType.stringList,
    ),
    r'coverPath': PropertySchema(
      id: 4,
      name: r'coverPath',
      type: IsarType.string,
    ),
    r'dateAdded': PropertySchema(
      id: 5,
      name: r'dateAdded',
      type: IsarType.dateTime,
    ),
    r'dateModified': PropertySchema(
      id: 6,
      name: r'dateModified',
      type: IsarType.dateTime,
    ),
    r'discNumber': PropertySchema(
      id: 7,
      name: r'discNumber',
      type: IsarType.long,
    ),
    r'duration': PropertySchema(
      id: 8,
      name: r'duration',
      type: IsarType.double,
    ),
    r'genre': PropertySchema(
      id: 9,
      name: r'genre',
      type: IsarType.string,
    ),
    r'lastPlayed': PropertySchema(
      id: 10,
      name: r'lastPlayed',
      type: IsarType.dateTime,
    ),
    r'lyrics': PropertySchema(
      id: 11,
      name: r'lyrics',
      type: IsarType.string,
    ),
    r'lyricsDurationMs': PropertySchema(
      id: 12,
      name: r'lyricsDurationMs',
      type: IsarType.long,
    ),
    r'mediaType': PropertySchema(
      id: 13,
      name: r'mediaType',
      type: IsarType.byte,
      enumMap: _SongmediaTypeEnumValueMap,
    ),
    r'musicBrainzId': PropertySchema(
      id: 14,
      name: r'musicBrainzId',
      type: IsarType.string,
    ),
    r'path': PropertySchema(
      id: 15,
      name: r'path',
      type: IsarType.string,
    ),
    r'remoteId': PropertySchema(
      id: 16,
      name: r'remoteId',
      type: IsarType.string,
    ),
    r'remoteUrl': PropertySchema(
      id: 17,
      name: r'remoteUrl',
      type: IsarType.string,
    ),
    r'size': PropertySchema(
      id: 18,
      name: r'size',
      type: IsarType.long,
    ),
    r'sourceType': PropertySchema(
      id: 19,
      name: r'sourceType',
      type: IsarType.byte,
      enumMap: _SongsourceTypeEnumValueMap,
    ),
    r'syncConfigId': PropertySchema(
      id: 20,
      name: r'syncConfigId',
      type: IsarType.long,
    ),
    r'title': PropertySchema(
      id: 21,
      name: r'title',
      type: IsarType.string,
    ),
    r'trackNumber': PropertySchema(
      id: 22,
      name: r'trackNumber',
      type: IsarType.long,
    ),
    r'year': PropertySchema(
      id: 23,
      name: r'year',
      type: IsarType.long,
    )
  },
  estimateSize: _songEstimateSize,
  serialize: _songSerialize,
  deserialize: _songDeserialize,
  deserializeProp: _songDeserializeProp,
  idName: r'id',
  indexes: {
    r'path': IndexSchema(
      id: 8756705481922369689,
      name: r'path',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'path',
          type: IndexType.value,
          caseSensitive: true,
        )
      ],
    ),
    r'artist': IndexSchema(
      id: 5842945185359817302,
      name: r'artist',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'artist',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'album': IndexSchema(
      id: 6222745341035631462,
      name: r'album',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'album',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _songGetId,
  getLinks: _songGetLinks,
  attach: _songAttach,
  version: '3.1.0+1',
);

int _songEstimateSize(
  Song object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.album.length * 3;
  bytesCount += 3 + object.artist.length * 3;
  bytesCount += 3 + object.artists.length * 3;
  {
    for (var i = 0; i < object.artists.length; i++) {
      final value = object.artists[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.coverPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.genre;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lyrics;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.musicBrainzId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.path.length * 3;
  {
    final value = object.remoteId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.remoteUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _songSerialize(
  Song object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.acousticFingerprintConfidence);
  writer.writeString(offsets[1], object.album);
  writer.writeString(offsets[2], object.artist);
  writer.writeStringList(offsets[3], object.artists);
  writer.writeString(offsets[4], object.coverPath);
  writer.writeDateTime(offsets[5], object.dateAdded);
  writer.writeDateTime(offsets[6], object.dateModified);
  writer.writeLong(offsets[7], object.discNumber);
  writer.writeDouble(offsets[8], object.duration);
  writer.writeString(offsets[9], object.genre);
  writer.writeDateTime(offsets[10], object.lastPlayed);
  writer.writeString(offsets[11], object.lyrics);
  writer.writeLong(offsets[12], object.lyricsDurationMs);
  writer.writeByte(offsets[13], object.mediaType.index);
  writer.writeString(offsets[14], object.musicBrainzId);
  writer.writeString(offsets[15], object.path);
  writer.writeString(offsets[16], object.remoteId);
  writer.writeString(offsets[17], object.remoteUrl);
  writer.writeLong(offsets[18], object.size);
  writer.writeByte(offsets[19], object.sourceType.index);
  writer.writeLong(offsets[20], object.syncConfigId);
  writer.writeString(offsets[21], object.title);
  writer.writeLong(offsets[22], object.trackNumber);
  writer.writeLong(offsets[23], object.year);
}

Song _songDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Song();
  object.acousticFingerprintConfidence = reader.readDoubleOrNull(offsets[0]);
  object.album = reader.readString(offsets[1]);
  object.artist = reader.readString(offsets[2]);
  object.artists = reader.readStringList(offsets[3]) ?? [];
  object.coverPath = reader.readStringOrNull(offsets[4]);
  object.dateAdded = reader.readDateTimeOrNull(offsets[5]);
  object.dateModified = reader.readDateTimeOrNull(offsets[6]);
  object.discNumber = reader.readLongOrNull(offsets[7]);
  object.duration = reader.readDoubleOrNull(offsets[8]);
  object.genre = reader.readStringOrNull(offsets[9]);
  object.id = id;
  object.lastPlayed = reader.readDateTimeOrNull(offsets[10]);
  object.lyrics = reader.readStringOrNull(offsets[11]);
  object.lyricsDurationMs = reader.readLongOrNull(offsets[12]);
  object.mediaType =
      _SongmediaTypeValueEnumMap[reader.readByteOrNull(offsets[13])] ??
          MediaType.audio;
  object.musicBrainzId = reader.readStringOrNull(offsets[14]);
  object.path = reader.readString(offsets[15]);
  object.remoteId = reader.readStringOrNull(offsets[16]);
  object.remoteUrl = reader.readStringOrNull(offsets[17]);
  object.size = reader.readLongOrNull(offsets[18]);
  object.sourceType =
      _SongsourceTypeValueEnumMap[reader.readByteOrNull(offsets[19])] ??
          SourceType.local;
  object.syncConfigId = reader.readLongOrNull(offsets[20]);
  object.title = reader.readString(offsets[21]);
  object.trackNumber = reader.readLongOrNull(offsets[22]);
  object.year = reader.readLongOrNull(offsets[23]);
  return object;
}

P _songDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readDoubleOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readLongOrNull(offset)) as P;
    case 13:
      return (_SongmediaTypeValueEnumMap[reader.readByteOrNull(offset)] ??
          MediaType.audio) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readLongOrNull(offset)) as P;
    case 19:
      return (_SongsourceTypeValueEnumMap[reader.readByteOrNull(offset)] ??
          SourceType.local) as P;
    case 20:
      return (reader.readLongOrNull(offset)) as P;
    case 21:
      return (reader.readString(offset)) as P;
    case 22:
      return (reader.readLongOrNull(offset)) as P;
    case 23:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SongmediaTypeEnumValueMap = {
  'audio': 0,
  'video': 1,
};
const _SongmediaTypeValueEnumMap = {
  0: MediaType.audio,
  1: MediaType.video,
};
const _SongsourceTypeEnumValueMap = {
  'local': 0,
  'webdav': 1,
  'openlist': 2,
};
const _SongsourceTypeValueEnumMap = {
  0: SourceType.local,
  1: SourceType.webdav,
  2: SourceType.openlist,
};

Id _songGetId(Song object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _songGetLinks(Song object) {
  return [];
}

void _songAttach(IsarCollection<dynamic> col, Id id, Song object) {
  object.id = id;
}

extension SongQueryWhereSort on QueryBuilder<Song, Song, QWhere> {
  QueryBuilder<Song, Song, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Song, Song, QAfterWhere> anyPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'path'),
      );
    });
  }
}

extension SongQueryWhere on QueryBuilder<Song, Song, QWhereClause> {
  QueryBuilder<Song, Song, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> pathEqualTo(String path) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'path',
        value: [path],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> pathNotEqualTo(String path) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path',
              lower: [],
              upper: [path],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path',
              lower: [path],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path',
              lower: [path],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path',
              lower: [],
              upper: [path],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> pathGreaterThan(
    String path, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'path',
        lower: [path],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> pathLessThan(
    String path, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'path',
        lower: [],
        upper: [path],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> pathBetween(
    String lowerPath,
    String upperPath, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'path',
        lower: [lowerPath],
        includeLower: includeLower,
        upper: [upperPath],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> pathStartsWith(
      String PathPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'path',
        lower: [PathPrefix],
        upper: ['$PathPrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> pathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'path',
        value: [''],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> pathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'path',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'path',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'path',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'path',
              upper: [''],
            ));
      }
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> artistEqualTo(String artist) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'artist',
        value: [artist],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> artistNotEqualTo(String artist) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'artist',
              lower: [],
              upper: [artist],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'artist',
              lower: [artist],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'artist',
              lower: [artist],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'artist',
              lower: [],
              upper: [artist],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> albumEqualTo(String album) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'album',
        value: [album],
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterWhereClause> albumNotEqualTo(String album) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'album',
              lower: [],
              upper: [album],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'album',
              lower: [album],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'album',
              lower: [album],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'album',
              lower: [],
              upper: [album],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SongQueryFilter on QueryBuilder<Song, Song, QFilterCondition> {
  QueryBuilder<Song, Song, QAfterFilterCondition>
      acousticFingerprintConfidenceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'acousticFingerprintConfidence',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition>
      acousticFingerprintConfidenceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'acousticFingerprintConfidence',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition>
      acousticFingerprintConfidenceEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'acousticFingerprintConfidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition>
      acousticFingerprintConfidenceGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'acousticFingerprintConfidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition>
      acousticFingerprintConfidenceLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'acousticFingerprintConfidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition>
      acousticFingerprintConfidenceBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'acousticFingerprintConfidence',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'album',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'album',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'album',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> albumIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'album',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artist',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artist',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artist',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artist',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artists',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artists',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artists',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artists',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artists',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artists',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistsElementContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artists',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistsElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artists',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artists',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artists',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'artists',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'artists',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'artists',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'artists',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'artists',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> artistsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'artists',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> coverPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'coverPath',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> coverPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'coverPath',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> coverPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coverPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> coverPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'coverPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> coverPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'coverPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> coverPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'coverPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> coverPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'coverPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> coverPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'coverPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> coverPathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'coverPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> coverPathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'coverPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> coverPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coverPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> coverPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'coverPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> dateAddedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dateAdded',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> dateAddedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dateAdded',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> dateAddedEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateAdded',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> dateAddedGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateAdded',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> dateAddedLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateAdded',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> dateAddedBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateAdded',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> dateModifiedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dateModified',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> dateModifiedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dateModified',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> dateModifiedEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateModified',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> dateModifiedGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateModified',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> dateModifiedLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateModified',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> dateModifiedBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateModified',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> discNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'discNumber',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> discNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'discNumber',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> discNumberEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'discNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> discNumberGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'discNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> discNumberLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'discNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> discNumberBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'discNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> durationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'duration',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> durationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'duration',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> durationEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'duration',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> durationGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'duration',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> durationLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'duration',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> durationBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'duration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'genre',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'genre',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'genre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'genre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'genre',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> genreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'genre',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lastPlayedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastPlayed',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lastPlayedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastPlayed',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lastPlayedEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lastPlayedGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lastPlayedLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lastPlayedBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPlayed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lyrics',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lyrics',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lyrics',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lyrics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lyrics',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lyrics',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lyrics',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsDurationMsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lyricsDurationMs',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsDurationMsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lyricsDurationMs',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsDurationMsEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lyricsDurationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsDurationMsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lyricsDurationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsDurationMsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lyricsDurationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> lyricsDurationMsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lyricsDurationMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> mediaTypeEqualTo(
      MediaType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaType',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> mediaTypeGreaterThan(
    MediaType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mediaType',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> mediaTypeLessThan(
    MediaType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mediaType',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> mediaTypeBetween(
    MediaType lower,
    MediaType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mediaType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> musicBrainzIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'musicBrainzId',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> musicBrainzIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'musicBrainzId',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> musicBrainzIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'musicBrainzId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> musicBrainzIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'musicBrainzId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> musicBrainzIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'musicBrainzId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> musicBrainzIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'musicBrainzId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> musicBrainzIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'musicBrainzId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> musicBrainzIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'musicBrainzId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> musicBrainzIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'musicBrainzId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> musicBrainzIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'musicBrainzId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> musicBrainzIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'musicBrainzId',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> musicBrainzIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'musicBrainzId',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'path',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'path',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'path',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> pathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'path',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> remoteIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'remoteId',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> remoteIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'remoteId',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> remoteIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> remoteIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> remoteIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> remoteIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'remoteId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> remoteIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> remoteIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> remoteIdContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> remoteIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'remoteId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> remoteIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remoteId',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> remoteIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'remoteId',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> remoteUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'remoteUrl',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> remoteUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'remoteUrl',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> remoteUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remoteUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> remoteUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'remoteUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> remoteUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'remoteUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> remoteUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'remoteUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> remoteUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'remoteUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> remoteUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'remoteUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> remoteUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'remoteUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> remoteUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'remoteUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> remoteUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remoteUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> remoteUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'remoteUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> sizeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'size',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> sizeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'size',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> sizeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'size',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> sizeGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'size',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> sizeLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'size',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> sizeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'size',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> sourceTypeEqualTo(
      SourceType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceType',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> sourceTypeGreaterThan(
    SourceType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceType',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> sourceTypeLessThan(
    SourceType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceType',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> sourceTypeBetween(
    SourceType lower,
    SourceType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> syncConfigIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'syncConfigId',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> syncConfigIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'syncConfigId',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> syncConfigIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncConfigId',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> syncConfigIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncConfigId',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> syncConfigIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncConfigId',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> syncConfigIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncConfigId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> trackNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'trackNumber',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> trackNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'trackNumber',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> trackNumberEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trackNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> trackNumberGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'trackNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> trackNumberLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'trackNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> trackNumberBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'trackNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> yearIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'year',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> yearIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'year',
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> yearEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'year',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> yearGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'year',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> yearLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'year',
        value: value,
      ));
    });
  }

  QueryBuilder<Song, Song, QAfterFilterCondition> yearBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'year',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SongQueryObject on QueryBuilder<Song, Song, QFilterCondition> {}

extension SongQueryLinks on QueryBuilder<Song, Song, QFilterCondition> {}

extension SongQuerySortBy on QueryBuilder<Song, Song, QSortBy> {
  QueryBuilder<Song, Song, QAfterSortBy> sortByAcousticFingerprintConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acousticFingerprintConfidence', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy>
      sortByAcousticFingerprintConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acousticFingerprintConfidence', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByAlbum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByAlbumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByArtist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByArtistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByCoverPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverPath', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByCoverPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverPath', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByDateAdded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateAdded', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByDateAddedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateAdded', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByDateModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateModified', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByDateModifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateModified', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByDiscNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discNumber', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByDiscNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discNumber', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByGenre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genre', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByGenreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genre', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByLastPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByLastPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyrics', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyrics', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByLyricsDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsDurationMs', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByLyricsDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsDurationMs', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByMediaType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByMediaTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByMusicBrainzId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'musicBrainzId', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByMusicBrainzIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'musicBrainzId', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByRemoteUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteUrl', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByRemoteUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteUrl', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortBySize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'size', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortBySizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'size', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortBySourceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortBySourceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortBySyncConfigId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncConfigId', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortBySyncConfigIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncConfigId', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByTrackNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackNumber', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByTrackNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackNumber', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> sortByYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.desc);
    });
  }
}

extension SongQuerySortThenBy on QueryBuilder<Song, Song, QSortThenBy> {
  QueryBuilder<Song, Song, QAfterSortBy> thenByAcousticFingerprintConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acousticFingerprintConfidence', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy>
      thenByAcousticFingerprintConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acousticFingerprintConfidence', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByAlbum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByAlbumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByArtist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByArtistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByCoverPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverPath', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByCoverPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverPath', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByDateAdded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateAdded', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByDateAddedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateAdded', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByDateModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateModified', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByDateModifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateModified', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByDiscNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discNumber', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByDiscNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discNumber', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByGenre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genre', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByGenreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genre', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByLastPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByLastPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyrics', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyrics', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByLyricsDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsDurationMs', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByLyricsDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyricsDurationMs', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByMediaType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByMediaTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByMusicBrainzId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'musicBrainzId', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByMusicBrainzIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'musicBrainzId', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByRemoteUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteUrl', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByRemoteUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteUrl', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenBySize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'size', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenBySizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'size', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenBySourceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenBySourceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenBySyncConfigId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncConfigId', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenBySyncConfigIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncConfigId', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByTrackNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackNumber', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByTrackNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackNumber', Sort.desc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.asc);
    });
  }

  QueryBuilder<Song, Song, QAfterSortBy> thenByYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.desc);
    });
  }
}

extension SongQueryWhereDistinct on QueryBuilder<Song, Song, QDistinct> {
  QueryBuilder<Song, Song, QDistinct>
      distinctByAcousticFingerprintConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'acousticFingerprintConfidence');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByAlbum(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'album', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByArtist(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artist', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByArtists() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artists');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByCoverPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coverPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByDateAdded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateAdded');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByDateModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateModified');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByDiscNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'discNumber');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'duration');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByGenre(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'genre', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByLastPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPlayed');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByLyrics(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lyrics', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByLyricsDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lyricsDurationMs');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByMediaType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaType');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByMusicBrainzId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'musicBrainzId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'path', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByRemoteId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByRemoteUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctBySize() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'size');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctBySourceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceType');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctBySyncConfigId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncConfigId');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByTrackNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trackNumber');
    });
  }

  QueryBuilder<Song, Song, QDistinct> distinctByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'year');
    });
  }
}

extension SongQueryProperty on QueryBuilder<Song, Song, QQueryProperty> {
  QueryBuilder<Song, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Song, double?, QQueryOperations>
      acousticFingerprintConfidenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'acousticFingerprintConfidence');
    });
  }

  QueryBuilder<Song, String, QQueryOperations> albumProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'album');
    });
  }

  QueryBuilder<Song, String, QQueryOperations> artistProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artist');
    });
  }

  QueryBuilder<Song, List<String>, QQueryOperations> artistsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artists');
    });
  }

  QueryBuilder<Song, String?, QQueryOperations> coverPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coverPath');
    });
  }

  QueryBuilder<Song, DateTime?, QQueryOperations> dateAddedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateAdded');
    });
  }

  QueryBuilder<Song, DateTime?, QQueryOperations> dateModifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateModified');
    });
  }

  QueryBuilder<Song, int?, QQueryOperations> discNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'discNumber');
    });
  }

  QueryBuilder<Song, double?, QQueryOperations> durationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duration');
    });
  }

  QueryBuilder<Song, String?, QQueryOperations> genreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'genre');
    });
  }

  QueryBuilder<Song, DateTime?, QQueryOperations> lastPlayedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPlayed');
    });
  }

  QueryBuilder<Song, String?, QQueryOperations> lyricsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lyrics');
    });
  }

  QueryBuilder<Song, int?, QQueryOperations> lyricsDurationMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lyricsDurationMs');
    });
  }

  QueryBuilder<Song, MediaType, QQueryOperations> mediaTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaType');
    });
  }

  QueryBuilder<Song, String?, QQueryOperations> musicBrainzIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'musicBrainzId');
    });
  }

  QueryBuilder<Song, String, QQueryOperations> pathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'path');
    });
  }

  QueryBuilder<Song, String?, QQueryOperations> remoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteId');
    });
  }

  QueryBuilder<Song, String?, QQueryOperations> remoteUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteUrl');
    });
  }

  QueryBuilder<Song, int?, QQueryOperations> sizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'size');
    });
  }

  QueryBuilder<Song, SourceType, QQueryOperations> sourceTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceType');
    });
  }

  QueryBuilder<Song, int?, QQueryOperations> syncConfigIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncConfigId');
    });
  }

  QueryBuilder<Song, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<Song, int?, QQueryOperations> trackNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trackNumber');
    });
  }

  QueryBuilder<Song, int?, QQueryOperations> yearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'year');
    });
  }
}
