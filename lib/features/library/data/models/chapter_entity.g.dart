// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetChapterEntityCollection on Isar {
  IsarCollection<ChapterEntity> get chapterEntitys => this.collection();
}

const ChapterEntitySchema = CollectionSchema(
  name: r'ChapterEntity',
  id: 6656881136352185615,
  properties: {
    r'chapterNumber': PropertySchema(
      id: 0,
      name: r'chapterNumber',
      type: IsarType.string,
    ),
    r'downloadStatus': PropertySchema(
      id: 1,
      name: r'downloadStatus',
      type: IsarType.byte,
      enumMap: _ChapterEntitydownloadStatusEnumValueMap,
    ),
    r'downloadedAt': PropertySchema(
      id: 2,
      name: r'downloadedAt',
      type: IsarType.dateTime,
    ),
    r'language': PropertySchema(
      id: 3,
      name: r'language',
      type: IsarType.string,
    ),
    r'lastReadAt': PropertySchema(
      id: 4,
      name: r'lastReadAt',
      type: IsarType.dateTime,
    ),
    r'lastReadPage': PropertySchema(
      id: 5,
      name: r'lastReadPage',
      type: IsarType.long,
    ),
    r'localPagePaths': PropertySchema(
      id: 6,
      name: r'localPagePaths',
      type: IsarType.stringList,
    ),
    r'mangaDexId': PropertySchema(
      id: 7,
      name: r'mangaDexId',
      type: IsarType.string,
    ),
    r'mangaId': PropertySchema(
      id: 8,
      name: r'mangaId',
      type: IsarType.string,
    ),
    r'pagesCount': PropertySchema(
      id: 9,
      name: r'pagesCount',
      type: IsarType.long,
    ),
    r'readPercentage': PropertySchema(
      id: 10,
      name: r'readPercentage',
      type: IsarType.double,
    ),
    r'title': PropertySchema(
      id: 11,
      name: r'title',
      type: IsarType.string,
    )
  },
  estimateSize: _chapterEntityEstimateSize,
  serialize: _chapterEntitySerialize,
  deserialize: _chapterEntityDeserialize,
  deserializeProp: _chapterEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'mangaDexId': IndexSchema(
      id: -2561072137442709649,
      name: r'mangaDexId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'mangaDexId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'mangaId': IndexSchema(
      id: 7466570075891278896,
      name: r'mangaId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'mangaId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'lastReadAt': IndexSchema(
      id: 1842310439171066335,
      name: r'lastReadAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'lastReadAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _chapterEntityGetId,
  getLinks: _chapterEntityGetLinks,
  attach: _chapterEntityAttach,
  version: '3.1.0+1',
);

int _chapterEntityEstimateSize(
  ChapterEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.chapterNumber.length * 3;
  bytesCount += 3 + object.language.length * 3;
  {
    final list = object.localPagePaths;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  bytesCount += 3 + object.mangaDexId.length * 3;
  bytesCount += 3 + object.mangaId.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _chapterEntitySerialize(
  ChapterEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.chapterNumber);
  writer.writeByte(offsets[1], object.downloadStatus.index);
  writer.writeDateTime(offsets[2], object.downloadedAt);
  writer.writeString(offsets[3], object.language);
  writer.writeDateTime(offsets[4], object.lastReadAt);
  writer.writeLong(offsets[5], object.lastReadPage);
  writer.writeStringList(offsets[6], object.localPagePaths);
  writer.writeString(offsets[7], object.mangaDexId);
  writer.writeString(offsets[8], object.mangaId);
  writer.writeLong(offsets[9], object.pagesCount);
  writer.writeDouble(offsets[10], object.readPercentage);
  writer.writeString(offsets[11], object.title);
}

ChapterEntity _chapterEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ChapterEntity();
  object.chapterNumber = reader.readString(offsets[0]);
  object.downloadStatus = _ChapterEntitydownloadStatusValueEnumMap[
          reader.readByteOrNull(offsets[1])] ??
      DownloadStatus.notDownloaded;
  object.downloadedAt = reader.readDateTimeOrNull(offsets[2]);
  object.id = id;
  object.language = reader.readString(offsets[3]);
  object.lastReadAt = reader.readDateTime(offsets[4]);
  object.lastReadPage = reader.readLong(offsets[5]);
  object.localPagePaths = reader.readStringList(offsets[6]);
  object.mangaDexId = reader.readString(offsets[7]);
  object.mangaId = reader.readString(offsets[8]);
  object.pagesCount = reader.readLong(offsets[9]);
  object.readPercentage = reader.readDouble(offsets[10]);
  object.title = reader.readString(offsets[11]);
  return object;
}

P _chapterEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (_ChapterEntitydownloadStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          DownloadStatus.notDownloaded) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readStringList(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readDouble(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ChapterEntitydownloadStatusEnumValueMap = {
  'notDownloaded': 0,
  'queued': 1,
  'downloading': 2,
  'downloaded': 3,
  'failed': 4,
};
const _ChapterEntitydownloadStatusValueEnumMap = {
  0: DownloadStatus.notDownloaded,
  1: DownloadStatus.queued,
  2: DownloadStatus.downloading,
  3: DownloadStatus.downloaded,
  4: DownloadStatus.failed,
};

Id _chapterEntityGetId(ChapterEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _chapterEntityGetLinks(ChapterEntity object) {
  return [];
}

void _chapterEntityAttach(
    IsarCollection<dynamic> col, Id id, ChapterEntity object) {
  object.id = id;
}

extension ChapterEntityByIndex on IsarCollection<ChapterEntity> {
  Future<ChapterEntity?> getByMangaDexId(String mangaDexId) {
    return getByIndex(r'mangaDexId', [mangaDexId]);
  }

  ChapterEntity? getByMangaDexIdSync(String mangaDexId) {
    return getByIndexSync(r'mangaDexId', [mangaDexId]);
  }

  Future<bool> deleteByMangaDexId(String mangaDexId) {
    return deleteByIndex(r'mangaDexId', [mangaDexId]);
  }

  bool deleteByMangaDexIdSync(String mangaDexId) {
    return deleteByIndexSync(r'mangaDexId', [mangaDexId]);
  }

  Future<List<ChapterEntity?>> getAllByMangaDexId(
      List<String> mangaDexIdValues) {
    final values = mangaDexIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'mangaDexId', values);
  }

  List<ChapterEntity?> getAllByMangaDexIdSync(List<String> mangaDexIdValues) {
    final values = mangaDexIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'mangaDexId', values);
  }

  Future<int> deleteAllByMangaDexId(List<String> mangaDexIdValues) {
    final values = mangaDexIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'mangaDexId', values);
  }

  int deleteAllByMangaDexIdSync(List<String> mangaDexIdValues) {
    final values = mangaDexIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'mangaDexId', values);
  }

  Future<Id> putByMangaDexId(ChapterEntity object) {
    return putByIndex(r'mangaDexId', object);
  }

  Id putByMangaDexIdSync(ChapterEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'mangaDexId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByMangaDexId(List<ChapterEntity> objects) {
    return putAllByIndex(r'mangaDexId', objects);
  }

  List<Id> putAllByMangaDexIdSync(List<ChapterEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'mangaDexId', objects, saveLinks: saveLinks);
  }
}

extension ChapterEntityQueryWhereSort
    on QueryBuilder<ChapterEntity, ChapterEntity, QWhere> {
  QueryBuilder<ChapterEntity, ChapterEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterWhere> anyLastReadAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'lastReadAt'),
      );
    });
  }
}

extension ChapterEntityQueryWhere
    on QueryBuilder<ChapterEntity, ChapterEntity, QWhereClause> {
  QueryBuilder<ChapterEntity, ChapterEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterWhereClause>
      mangaDexIdEqualTo(String mangaDexId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'mangaDexId',
        value: [mangaDexId],
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterWhereClause>
      mangaDexIdNotEqualTo(String mangaDexId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mangaDexId',
              lower: [],
              upper: [mangaDexId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mangaDexId',
              lower: [mangaDexId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mangaDexId',
              lower: [mangaDexId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mangaDexId',
              lower: [],
              upper: [mangaDexId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterWhereClause> mangaIdEqualTo(
      String mangaId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'mangaId',
        value: [mangaId],
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterWhereClause>
      mangaIdNotEqualTo(String mangaId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mangaId',
              lower: [],
              upper: [mangaId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mangaId',
              lower: [mangaId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mangaId',
              lower: [mangaId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mangaId',
              lower: [],
              upper: [mangaId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterWhereClause>
      lastReadAtEqualTo(DateTime lastReadAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lastReadAt',
        value: [lastReadAt],
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterWhereClause>
      lastReadAtNotEqualTo(DateTime lastReadAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastReadAt',
              lower: [],
              upper: [lastReadAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastReadAt',
              lower: [lastReadAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastReadAt',
              lower: [lastReadAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastReadAt',
              lower: [],
              upper: [lastReadAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterWhereClause>
      lastReadAtGreaterThan(
    DateTime lastReadAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastReadAt',
        lower: [lastReadAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterWhereClause>
      lastReadAtLessThan(
    DateTime lastReadAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastReadAt',
        lower: [],
        upper: [lastReadAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterWhereClause>
      lastReadAtBetween(
    DateTime lowerLastReadAt,
    DateTime upperLastReadAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastReadAt',
        lower: [lowerLastReadAt],
        includeLower: includeLower,
        upper: [upperLastReadAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ChapterEntityQueryFilter
    on QueryBuilder<ChapterEntity, ChapterEntity, QFilterCondition> {
  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      chapterNumberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      chapterNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chapterNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      chapterNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chapterNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      chapterNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chapterNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      chapterNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'chapterNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      chapterNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'chapterNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      chapterNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'chapterNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      chapterNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'chapterNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      chapterNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      chapterNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'chapterNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      downloadStatusEqualTo(DownloadStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'downloadStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      downloadStatusGreaterThan(
    DownloadStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'downloadStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      downloadStatusLessThan(
    DownloadStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'downloadStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      downloadStatusBetween(
    DownloadStatus lower,
    DownloadStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'downloadStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      downloadedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'downloadedAt',
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      downloadedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'downloadedAt',
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      downloadedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'downloadedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      downloadedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'downloadedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      downloadedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'downloadedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      downloadedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'downloadedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      languageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      languageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      languageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      languageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'language',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      languageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      languageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      languageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      languageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'language',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      languageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'language',
        value: '',
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      languageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'language',
        value: '',
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      lastReadAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReadAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      lastReadAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastReadAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      lastReadAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastReadAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      lastReadAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastReadAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      lastReadPageEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReadPage',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      lastReadPageGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastReadPage',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      lastReadPageLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastReadPage',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      lastReadPageBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastReadPage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      localPagePathsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'localPagePaths',
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      localPagePathsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'localPagePaths',
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      localPagePathsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localPagePaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      localPagePathsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localPagePaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      localPagePathsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localPagePaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      localPagePathsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localPagePaths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      localPagePathsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'localPagePaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      localPagePathsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'localPagePaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      localPagePathsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'localPagePaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      localPagePathsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'localPagePaths',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      localPagePathsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localPagePaths',
        value: '',
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      localPagePathsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'localPagePaths',
        value: '',
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      localPagePathsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'localPagePaths',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      localPagePathsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'localPagePaths',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      localPagePathsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'localPagePaths',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      localPagePathsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'localPagePaths',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      localPagePathsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'localPagePaths',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      localPagePathsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'localPagePaths',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      mangaDexIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mangaDexId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      mangaDexIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mangaDexId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      mangaDexIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mangaDexId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      mangaDexIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mangaDexId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      mangaDexIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mangaDexId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      mangaDexIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mangaDexId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      mangaDexIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mangaDexId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      mangaDexIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mangaDexId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      mangaDexIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mangaDexId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      mangaDexIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mangaDexId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      mangaIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mangaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      mangaIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mangaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      mangaIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mangaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      mangaIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mangaId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      mangaIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mangaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      mangaIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mangaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      mangaIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mangaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      mangaIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mangaId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      mangaIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mangaId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      mangaIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mangaId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      pagesCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pagesCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      pagesCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pagesCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      pagesCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pagesCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      pagesCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pagesCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      readPercentageEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'readPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      readPercentageGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'readPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      readPercentageLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'readPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      readPercentageBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'readPercentage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      titleEqualTo(
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

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      titleGreaterThan(
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

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      titleLessThan(
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

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      titleBetween(
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

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      titleStartsWith(
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

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      titleEndsWith(
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

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }
}

extension ChapterEntityQueryObject
    on QueryBuilder<ChapterEntity, ChapterEntity, QFilterCondition> {}

extension ChapterEntityQueryLinks
    on QueryBuilder<ChapterEntity, ChapterEntity, QFilterCondition> {}

extension ChapterEntityQuerySortBy
    on QueryBuilder<ChapterEntity, ChapterEntity, QSortBy> {
  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      sortByChapterNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterNumber', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      sortByChapterNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterNumber', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      sortByDownloadStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadStatus', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      sortByDownloadStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadStatus', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      sortByDownloadedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadedAt', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      sortByDownloadedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadedAt', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      sortByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByLastReadAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadAt', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      sortByLastReadAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadAt', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      sortByLastReadPage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadPage', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      sortByLastReadPageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadPage', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByMangaDexId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaDexId', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      sortByMangaDexIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaDexId', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByMangaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaId', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByMangaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaId', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByPagesCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pagesCount', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      sortByPagesCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pagesCount', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      sortByReadPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readPercentage', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      sortByReadPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readPercentage', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension ChapterEntityQuerySortThenBy
    on QueryBuilder<ChapterEntity, ChapterEntity, QSortThenBy> {
  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      thenByChapterNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterNumber', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      thenByChapterNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterNumber', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      thenByDownloadStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadStatus', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      thenByDownloadStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadStatus', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      thenByDownloadedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadedAt', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      thenByDownloadedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadedAt', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      thenByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByLastReadAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadAt', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      thenByLastReadAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadAt', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      thenByLastReadPage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadPage', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      thenByLastReadPageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadPage', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByMangaDexId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaDexId', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      thenByMangaDexIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaDexId', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByMangaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaId', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByMangaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mangaId', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByPagesCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pagesCount', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      thenByPagesCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pagesCount', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      thenByReadPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readPercentage', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy>
      thenByReadPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readPercentage', Sort.desc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension ChapterEntityQueryWhereDistinct
    on QueryBuilder<ChapterEntity, ChapterEntity, QDistinct> {
  QueryBuilder<ChapterEntity, ChapterEntity, QDistinct> distinctByChapterNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chapterNumber',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QDistinct>
      distinctByDownloadStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'downloadStatus');
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QDistinct>
      distinctByDownloadedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'downloadedAt');
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QDistinct> distinctByLanguage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'language', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QDistinct> distinctByLastReadAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReadAt');
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QDistinct>
      distinctByLastReadPage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReadPage');
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QDistinct>
      distinctByLocalPagePaths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localPagePaths');
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QDistinct> distinctByMangaDexId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mangaDexId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QDistinct> distinctByMangaId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mangaId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QDistinct> distinctByPagesCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pagesCount');
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QDistinct>
      distinctByReadPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'readPercentage');
    });
  }

  QueryBuilder<ChapterEntity, ChapterEntity, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension ChapterEntityQueryProperty
    on QueryBuilder<ChapterEntity, ChapterEntity, QQueryProperty> {
  QueryBuilder<ChapterEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ChapterEntity, String, QQueryOperations>
      chapterNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chapterNumber');
    });
  }

  QueryBuilder<ChapterEntity, DownloadStatus, QQueryOperations>
      downloadStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'downloadStatus');
    });
  }

  QueryBuilder<ChapterEntity, DateTime?, QQueryOperations>
      downloadedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'downloadedAt');
    });
  }

  QueryBuilder<ChapterEntity, String, QQueryOperations> languageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'language');
    });
  }

  QueryBuilder<ChapterEntity, DateTime, QQueryOperations> lastReadAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReadAt');
    });
  }

  QueryBuilder<ChapterEntity, int, QQueryOperations> lastReadPageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReadPage');
    });
  }

  QueryBuilder<ChapterEntity, List<String>?, QQueryOperations>
      localPagePathsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localPagePaths');
    });
  }

  QueryBuilder<ChapterEntity, String, QQueryOperations> mangaDexIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mangaDexId');
    });
  }

  QueryBuilder<ChapterEntity, String, QQueryOperations> mangaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mangaId');
    });
  }

  QueryBuilder<ChapterEntity, int, QQueryOperations> pagesCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pagesCount');
    });
  }

  QueryBuilder<ChapterEntity, double, QQueryOperations>
      readPercentageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'readPercentage');
    });
  }

  QueryBuilder<ChapterEntity, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}
