// contract for Jikan api
import '../../model/jikan/character_data.dart';

abstract class JikanApi {
  Future<CharacterData?> getCharacters(int malMediaId, bool isAnime);
}