import 'package:anime_gallery/api/jikan/jikan_api.dart';
import 'package:anime_gallery/api/jikan/jikan_api_impl.dart';
import 'package:anime_gallery/model/jikan/character_data.dart';

class JikanApiHelper {
  static void getMediaCharacters(
    int malMediaId,
    bool isAnime,
    void Function(CharacterData?) callback
  ) async {
    final JikanApi api = JikanApiImpl();
    callback(await api.getCharacters(malMediaId, isAnime));
  }
}