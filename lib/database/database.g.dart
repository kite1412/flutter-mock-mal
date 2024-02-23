// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

abstract class GenreData {
  int get id;
  int get malId;
  String get genreName;
}

// ignore_for_file: type=lint
class $AnimeGenreTable extends AnimeGenre
    with TableInfo<$AnimeGenreTable, AnimeGenreData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimeGenreTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _malIdMeta = const VerificationMeta('malId');
  @override
  late final GeneratedColumn<int> malId = GeneratedColumn<int>(
      'mal_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _genreNameMeta =
      const VerificationMeta('genreName');
  @override
  late final GeneratedColumn<String> genreName = GeneratedColumn<String>(
      'genre_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, malId, genreName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'anime_genre';
  @override
  VerificationContext validateIntegrity(Insertable<AnimeGenreData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('mal_id')) {
      context.handle(
          _malIdMeta, malId.isAcceptableOrUnknown(data['mal_id']!, _malIdMeta));
    } else if (isInserting) {
      context.missing(_malIdMeta);
    }
    if (data.containsKey('genre_name')) {
      context.handle(_genreNameMeta,
          genreName.isAcceptableOrUnknown(data['genre_name']!, _genreNameMeta));
    } else if (isInserting) {
      context.missing(_genreNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnimeGenreData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnimeGenreData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      malId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mal_id'])!,
      genreName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}genre_name'])!,
    );
  }

  @override
  $AnimeGenreTable createAlias(String alias) {
    return $AnimeGenreTable(attachedDatabase, alias);
  }
}

class AnimeGenreData extends DataClass implements Insertable<AnimeGenreData>, GenreData {
  final int id;
  final int malId;
  final String genreName;
  const AnimeGenreData(
      {required this.id, required this.malId, required this.genreName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['mal_id'] = Variable<int>(malId);
    map['genre_name'] = Variable<String>(genreName);
    return map;
  }

  AnimeGenreCompanion toCompanion(bool nullToAbsent) {
    return AnimeGenreCompanion(
      id: Value(id),
      malId: Value(malId),
      genreName: Value(genreName),
    );
  }

  factory AnimeGenreData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnimeGenreData(
      id: serializer.fromJson<int>(json['id']),
      malId: serializer.fromJson<int>(json['malId']),
      genreName: serializer.fromJson<String>(json['genreName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'malId': serializer.toJson<int>(malId),
      'genreName': serializer.toJson<String>(genreName),
    };
  }

  AnimeGenreData copyWith({int? id, int? malId, String? genreName}) =>
      AnimeGenreData(
        id: id ?? this.id,
        malId: malId ?? this.malId,
        genreName: genreName ?? this.genreName,
      );

  static List<AnimeGenreData> fromResources(List<Resource> resources) {
    return resources.map((e) =>
      AnimeGenreData(id: -1, malId: e.malId!, genreName: e.name!)
    ).toList();
  }

  @override
  String toString() {
    return (StringBuffer('AnimeGenreData(')
          ..write('id: $id, ')
          ..write('malId: $malId, ')
          ..write('genreName: $genreName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, malId, genreName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnimeGenreData &&
          other.id == this.id &&
          other.malId == this.malId &&
          other.genreName == this.genreName);
}

class AnimeGenreCompanion extends UpdateCompanion<AnimeGenreData> {
  final Value<int> id;
  final Value<int> malId;
  final Value<String> genreName;
  const AnimeGenreCompanion({
    this.id = const Value.absent(),
    this.malId = const Value.absent(),
    this.genreName = const Value.absent(),
  });
  AnimeGenreCompanion.insert({
    this.id = const Value.absent(),
    required int malId,
    required String genreName,
  })  : malId = Value(malId),
        genreName = Value(genreName);
  static Insertable<AnimeGenreData> custom({
    Expression<int>? id,
    Expression<int>? malId,
    Expression<String>? genreName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (malId != null) 'mal_id': malId,
      if (genreName != null) 'genre_name': genreName,
    });
  }

  AnimeGenreCompanion copyWith(
      {Value<int>? id, Value<int>? malId, Value<String>? genreName}) {
    return AnimeGenreCompanion(
      id: id ?? this.id,
      malId: malId ?? this.malId,
      genreName: genreName ?? this.genreName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (malId.present) {
      map['mal_id'] = Variable<int>(malId.value);
    }
    if (genreName.present) {
      map['genre_name'] = Variable<String>(genreName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimeGenreCompanion(')
          ..write('id: $id, ')
          ..write('malId: $malId, ')
          ..write('genreName: $genreName')
          ..write(')'))
        .toString();
  }
}

class $MangaGenreTable extends MangaGenre
    with TableInfo<$MangaGenreTable, MangaGenreData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MangaGenreTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _malIdMeta = const VerificationMeta('malId');
  @override
  late final GeneratedColumn<int> malId = GeneratedColumn<int>(
      'mal_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _genreNameMeta =
      const VerificationMeta('genreName');
  @override
  late final GeneratedColumn<String> genreName = GeneratedColumn<String>(
      'genre_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, malId, genreName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'manga_genre';
  @override
  VerificationContext validateIntegrity(Insertable<MangaGenreData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('mal_id')) {
      context.handle(
          _malIdMeta, malId.isAcceptableOrUnknown(data['mal_id']!, _malIdMeta));
    } else if (isInserting) {
      context.missing(_malIdMeta);
    }
    if (data.containsKey('genre_name')) {
      context.handle(_genreNameMeta,
          genreName.isAcceptableOrUnknown(data['genre_name']!, _genreNameMeta));
    } else if (isInserting) {
      context.missing(_genreNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MangaGenreData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MangaGenreData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      malId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mal_id'])!,
      genreName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}genre_name'])!,
    );
  }

  @override
  $MangaGenreTable createAlias(String alias) {
    return $MangaGenreTable(attachedDatabase, alias);
  }
}

class MangaGenreData extends DataClass implements Insertable<MangaGenreData>, GenreData {
  final int id;
  final int malId;
  final String genreName;
  const MangaGenreData(
      {required this.id, required this.malId, required this.genreName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['mal_id'] = Variable<int>(malId);
    map['genre_name'] = Variable<String>(genreName);
    return map;
  }

  MangaGenreCompanion toCompanion(bool nullToAbsent) {
    return MangaGenreCompanion(
      id: Value(id),
      malId: Value(malId),
      genreName: Value(genreName),
    );
  }

  factory MangaGenreData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MangaGenreData(
      id: serializer.fromJson<int>(json['id']),
      malId: serializer.fromJson<int>(json['malId']),
      genreName: serializer.fromJson<String>(json['genreName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'malId': serializer.toJson<int>(malId),
      'genreName': serializer.toJson<String>(genreName),
    };
  }

  MangaGenreData copyWith({int? id, int? malId, String? genreName}) =>
      MangaGenreData(
        id: id ?? this.id,
        malId: malId ?? this.malId,
        genreName: genreName ?? this.genreName,
      );

  static List<MangaGenreData> fromResources(List<Resource> resources) {
    return resources.map((e) =>
        MangaGenreData(id: -1, malId: e.malId!, genreName: e.name!)
    ).toList();
  }

  @override
  String toString() {
    return (StringBuffer('MangaGenreData(')
          ..write('id: $id, ')
          ..write('malId: $malId, ')
          ..write('genreName: $genreName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, malId, genreName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MangaGenreData &&
          other.id == this.id &&
          other.malId == this.malId &&
          other.genreName == this.genreName);
}

class MangaGenreCompanion extends UpdateCompanion<MangaGenreData> {
  final Value<int> id;
  final Value<int> malId;
  final Value<String> genreName;
  const MangaGenreCompanion({
    this.id = const Value.absent(),
    this.malId = const Value.absent(),
    this.genreName = const Value.absent(),
  });
  MangaGenreCompanion.insert({
    this.id = const Value.absent(),
    required int malId,
    required String genreName,
  })  : malId = Value(malId),
        genreName = Value(genreName);
  static Insertable<MangaGenreData> custom({
    Expression<int>? id,
    Expression<int>? malId,
    Expression<String>? genreName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (malId != null) 'mal_id': malId,
      if (genreName != null) 'genre_name': genreName,
    });
  }

  MangaGenreCompanion copyWith(
      {Value<int>? id, Value<int>? malId, Value<String>? genreName}) {
    return MangaGenreCompanion(
      id: id ?? this.id,
      malId: malId ?? this.malId,
      genreName: genreName ?? this.genreName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (malId.present) {
      map['mal_id'] = Variable<int>(malId.value);
    }
    if (genreName.present) {
      map['genre_name'] = Variable<String>(genreName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MangaGenreCompanion(')
          ..write('id: $id, ')
          ..write('malId: $malId, ')
          ..write('genreName: $genreName')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $AnimeGenreTable animeGenre = $AnimeGenreTable(this);
  late final $MangaGenreTable mangaGenre = $MangaGenreTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [animeGenre, mangaGenre];
}
