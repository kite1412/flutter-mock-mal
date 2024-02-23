import 'dart:ui';

import 'package:anime_gallery/api/jikan/jikan_api.dart';
import 'package:anime_gallery/api/jikan/jikan_api_impl.dart';
import 'package:anime_gallery/model/jikan/character_data.dart';
import 'package:anime_gallery/model/jikan/data.dart';
import 'package:anime_gallery/model/jikan/pagination.dart';
import 'package:anime_gallery/model/jikan/resource_data.dart';
import 'package:logger/logger.dart';

class JikanApiHelper {
  static final Logger _log = Logger();

  static void getMediaCharacters(
    int malMediaId,
    bool isAnime,
    void Function(CharacterData?) callback
  ) async {
    final JikanApi api = JikanApiImpl();
    callback(await api.getCharacters(malMediaId, isAnime));
  }

  static void getMedia(
    String path,
    Map<String, dynamic>? queries,
    void Function(Data) callback
  ) async {
    final JikanApi api = JikanApiImpl();
    callback(await api.getMedia(path, queries));
  }

  static void getAnimeSchedules(
    Map<String, dynamic>? queries,
    void Function(Data) callback,
    bool loadAll,
    void Function(Data)? onNextLoad
  ) async {
    getMedia("schedules", queries, (data) {
      callback(data);
      loadAll ? loadAllPage(data.pagination, "schedules", 2, queries, (loadedData) {
        onNextLoad?.call(loadedData);
      }) : null;
    });
  }

  static void loadNextPage(
    Data data,
    bool isAnime,
    void Function(Data) newDataCallback,
    {VoidCallback? onComplete,
    Map<String, dynamic>? queries}
  ) async {
    if (data.pagination!.hasNextPage!) {
      final nextPage = data.pagination!.currentPage! + 1;
      getMedia(
        isAnime ? "anime" : "manga",
        {
          "page" : nextPage,
        }..addAll(queries ?? {}),
        newDataCallback
      );
      _log.i("current page: $nextPage}");
    } else {
      onComplete?.call();
    }
  }

  //load all page for a request.
  static void loadAllPage(
    Pagination? pagination,
    String path,
    int page,
    Map<String, dynamic>? queries,
    void Function(Data) newData
  ) {
    if (pagination != null) {
      if (pagination.hasNextPage!) {
        final Map<String, dynamic>? altered = queries?.map((key, value) {
          if (key == "page") {
            return MapEntry(key, page);
          }
          return MapEntry(key, value);
        });
        getMedia(
          path,
          altered,
          (data) {
            newData(data);
            // giving some delay here to not forbid the api regulation.
            Future.delayed(const Duration(milliseconds: 1000)).whenComplete(() {
              loadAllPage(data.pagination, path, page + 1, queries, newData);
            });
          }
        );
      }
    }
  }

  static void getGenres(
    bool isAnime,
    void Function(ResourceData) callback,
    {VoidCallback? onFailure}
  ) async {
    final String path = isAnime ? "genres/anime" : "genres/manga";
    try {
      final JikanApi api = JikanApiImpl();
      final ResourceData data = await api.getResources(path, null);
      callback(data);
    } catch(e) {
      onFailure?.call();
    }
  }

  static void getMediaByGenres(
    bool isAnime,
    List<int> genresIds,
    void Function(Data) callback
  ) async {
    getMedia(
      isAnime ? "anime" : "manga",
      {
        "sfw" : false,
        "genres" : genresIds.join(",")
      },
      callback,
    );
  }
}