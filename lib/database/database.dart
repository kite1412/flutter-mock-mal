import 'dart:io';

import 'package:anime_gallery/model/jikan/resource_data.dart';
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
    // the LazyDatabase util lets us find the right location for the file async.
    return LazyDatabase(() async {
      // put the database file, called db.sqlite here, into the documents folder
      // for your app.
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(join(dbFolder.path, 'db.sqlite'));

      // Also work around limitations on old Android versions
      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      }

      // Make sqlite3 pick a more suitable location for temporary files - the
      // one from the system may be inaccessible due to sandboxing.
      final cachebase = (await getTemporaryDirectory()).path;
      // We can't access /tmp on Android, which sqlite3 would try by default.
      // Explicitly tell it about the correct temporary directory.
      sqlite3.tempDirectory = cachebase;

      return NativeDatabase.createInBackground(file);
    });
  });
}