import '../model/data.dart';
import '../model/media_node.dart';
import '../model/user_information.dart';

abstract class MalAPI {
  //fetch media from server, anime or manga
  Future<dynamic> fetchMedia(String path, Map<String, dynamic> queries, {bool needRank = false});

  //fetch user's information
  Future<UserInformation> fetchUserInfo(List<String> fields);

  //fetch media based on prior request's paging's nextPage
  Future<Data> nextPage(String nextPage);

  //fetch media by id
  Future<MediaNode> findMediaById(int id, bool isAnime, {List<String> fields = const []});
}