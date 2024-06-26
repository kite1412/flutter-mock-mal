import 'package:anime_gallery/model/mal/access_token.dart';
import 'package:anime_gallery/model/mal/data_with_node_ranked.dart';

import '../../model/mal/data.dart';
import '../../model/mal/media_node.dart';
import '../../model/mal/update_media.dart';
import '../../model/mal/user_information.dart';

abstract class MalAPI {
  //fetch media from server, anime or manga
  Future<dynamic> fetchMedia(String path, Map<String, dynamic> queries, {bool needRank = false});

  //fetch user's information
  Future<UserInformation> fetchUserInfo(List<String> fields);

  //fetch media based on prior request's paging's nextPage
  Future<Data> nextPage(String nextPage);

  //fetch media by id
  Future<MediaNode> findMediaById(int id, bool isAnime, {List<String> fields = const []});

  Future<UpdateMedia> updateMedia(int mediaId, bool isAnime, Map<String, dynamic> body);

  Future<bool> removeMedia(int mediaId, bool isAnime);

  Future<DataWithRank> rankedNextPage(String nextPage);

  Future<AccessToken?> refreshToken(String refreshToken);
}