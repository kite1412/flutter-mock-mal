import '../../model/jikan/character_data.dart';
import '../../model/jikan/data.dart';
import '../../model/jikan/resource_data.dart';

// contract for Jikan api
abstract class JikanApi {
  Future<CharacterData?> getCharacters(int malMediaId, bool isAnime);

  // any request with Data response
  Future<Data> getMedia(String path, Map<String, dynamic>? queries);

  Future<ResourceData> getResources(String path, Map<String, dynamic>? queries);


}