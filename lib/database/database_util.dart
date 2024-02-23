import 'package:anime_gallery/database/database.dart';
import 'package:drift/drift.dart';
import 'package:logger/logger.dart';

class AppDatabaseUtil {
  static final Logger _log = Logger();
  static final AppDatabase _database = AppDatabase.instance();

  AppDatabaseUtil._();

  static Future<List<AnimeGenreData>> getAnimeGenres() async {
    try {
      final result = await _database.animeGenre.select().get();
      _log.i("get anime genres success with length: ${result.length}");
      return result;
    } catch(e) {
      _log.e(e);
      return Future.error(Exception("Fail to get anime genres from local db"));
    }
  }

  static Future<List<MangaGenreData>> getMangaGenres() async {
    try {
      final result = await _database.mangaGenre.select().get();
      _log.i("get manga genres success with length: ${result.length}");
      return result;
    } catch(e) {
      _log.e(e);
      return Future.error(Exception("Fail to get manga genres from local db"));
    }
  }

  static void insertIntoAnimeGenre(List<AnimeGenreData> genres) async {
    final toCompanions = genres.map((e) =>
      AnimeGenreCompanion.insert(malId: e.malId, genreName: e.genreName)
    ).toList();
    await _database.animeGenre.insertAll(toCompanions);
    _log.i("anime genres insertion process completed");
  }

  static void insertIntoMangaGenre(List<MangaGenreData> genres) async {
    final toCompanions = genres.map((e) =>
      MangaGenreCompanion.insert(malId: e.malId, genreName: e.genreName)
    ).toList();
    await _database.mangaGenre.insertAll(toCompanions);
    _log.i("manga genres insertion process completed");
  }

  static void deleteAllGenres() async {
    _database.animeGenre.deleteAll();
    _database.mangaGenre.deleteAll();
  }
}