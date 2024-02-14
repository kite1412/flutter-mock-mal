import 'dart:convert';

import 'package:anime_gallery/api/jikan/constant.dart';
import 'package:anime_gallery/api/jikan/jikan_api.dart';
import 'package:anime_gallery/model/jikan/character_data.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';

class JikanApiImpl implements JikanApi {
  final Logger _log = Logger();

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
}