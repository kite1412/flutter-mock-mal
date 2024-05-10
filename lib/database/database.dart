import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import '../model/jikan/resource.dart';

part 'database.g.dart';

abstract class GenreTable {
  IntColumn get id;
  IntColumn get malId;
  TextColumn get genreName;
}

class AnimeGenre extends Table implements GenreTable {
  @override
  IntColumn get id => integer().autoIncrement()();
  @override
  IntColumn get malId => integer()();
  @override
  TextColumn get genreName => text()();
}

class MangaGenre extends Table implements GenreTable {
  @override
  IntColumn get id => integer().autoIncrement()();
  @override
  IntColumn get malId => integer()();
  @override
  TextColumn get genreName => text()();
}

@DriftDatabase(tables: [AnimeGenre, MangaGenre])
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_executor());
  static final Logger _log = Logger();

  static AppDatabase? _database;

  static AppDatabase instance() {
    if (_database == null) {
      _database = AppDatabase._();
      _log.i("------INITIALIZING APPDATABASE------");
      _checkTables();
    }
    return _database!;
  }

  static void _checkTables() {
    _log.i("tables: ${_database!.allTables.toList()}");
  }

  @override
  int get schemaVersion => 1;
}

QueryExecutor _executor() {
  return LazyDatabase(() async {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(join(dbFolder.path, 'db.sqlite'));

      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      }

      final cachebase = (await getTemporaryDirectory()).path;
      sqlite3.tempDirectory = cachebase;

      return NativeDatabase.createInBackground(file);
    });
  });
}