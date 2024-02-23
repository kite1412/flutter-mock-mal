import 'dart:convert';
import 'dart:ui';

import 'package:anime_gallery/api/jikan/constant.dart';
import 'package:anime_gallery/api/jikan/jikan_api.dart';
import 'package:anime_gallery/model/jikan/character_data.dart';
import 'package:anime_gallery/model/jikan/data.dart';
import 'package:anime_gallery/model/jikan/resource_data.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';

class JikanApiImpl implements JikanApi {
  final Logger _log = Logger();

  String concatQueriesToPath(String path, Map<String, dynamic> queries) {
    if (queries.isNotEmpty) {
      path += "?";
      for (var e in queries.entries.indexed) {
        path += "${e.$2.key}=${e.$2.value}";
        if (e.$1 != queries.length - 1) {
          path += "&";
        }
      }
    }
    return path;
  }

  @override
  Future<CharacterData?> getCharacters(int malMediaId, bool isAnime) async {
    try {
      String path = "";
      path += isAnime ? "/anime" : "/manga";
      path += "/$malMediaId/characters";
      final Response response = await get(Uri.parse("${JikanConstant.uri}$path"));
      final data =  CharacterData.fromJson(jsonDecode(response.body));
      _log.i("${JikanConstant.uri}/$path");
      _log.i("success fetching media's characters with length: ${data.data?.length}");
      return data;
    } catch (e) {
      _log.e(e);
      return null;
    }
  }

  @override
  Future<Data> getMedia(String path, Map<String, dynamic>? queries) async {
    try {
      if (queries != null && queries.isNotEmpty) {
        path = concatQueriesToPath(path, queries);
      }
      _log.d("path: $path");
      final Response response = await get(Uri.parse("${JikanConstant.uri}/$path"));
      final Data data = Data.fromJson(jsonDecode(response.body));
      _log.i("success fetching jikan's media, length: ${data.data?.length}");
      return data;
    } catch(e) {
      _log.e(e);
      return Future.error(Exception("Fail to get media"));
    }
  }

  @override
  Future<ResourceData> getResources(
    String path,
    Map<String, dynamic>? queries,
  ) async {
    if (queries != null && queries.isNotEmpty) {
      path = concatQueriesToPath(path, queries);
    }
    try {
      final Response response = await get(Uri.parse("${JikanConstant.uri}/$path"));
      final data = ResourceData.fromJson(jsonDecode(response.body));
      _log.i("success fetching resource: ${JikanConstant.uri}/$path");
      return data;
    } catch(e) {
      _log.e(e);
      return Future.error(Exception("Fail to fetch $path resource"));
    }
  }
}