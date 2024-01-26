import 'package:anime_gallery/api/mal_api_impl.dart';
import 'package:anime_gallery/model/data_with_node_ranked.dart';
import 'package:anime_gallery/model/node_with_rank.dart';
import 'package:logger/logger.dart';

import '../model/data.dart';
import '../model/media_node.dart';
import '../model/paging.dart';
import '../model/user_information.dart';
import 'mal_api.dart';

typedef ApiCallback<T> = void Function(T);

class MalAPIHelper {
  static final Logger _log = Logger();
  static final List<String> _mediaFields = [
    "pictures",
  ];

  // not intended to be instantiated
  MalAPIHelper._();

  static void _extractMediaNodes(List<dynamic> nodes, dynamic data) {
    if (data is Data) {
      for (var element in data.mediaNodes) {
        for (var i in element.values) {
          nodes.add(i);
        }
      }
    } else if (data is DataWithRank) {
      for (var element in data.data) {
        nodes.add(element);
      }
    }
  }

  static void media(
    bool isFetchingAnime,
    ApiCallback<List<MediaNode>> callback,
    {ApiCallback<Data>? dataCallback,
    Map<String, dynamic> queryParam = const {}}
  ) async {
    String path = isFetchingAnime ? "anime" : "manga";
    List<MediaNode> nodes;

    try {
      final MalAPI api = MalAPIImpl();
      nodes = [];
      Data data = await api.fetchMedia(path, queryParam);
      if (dataCallback != null) {
        dataCallback(data);
      }
      _extractMediaNodes(nodes, data);
      callback(nodes);
    } catch (e) {
      _log.e(e);
    }
  }

  static void mediaWithCategory(
    bool isFetchingAnime,
    String categoryPath,
    ApiCallback<dynamic> callback,
    {ApiCallback<dynamic>? dataCallback,
    Map<String, dynamic> queryParam = const {},
    bool needRank = false}
  ) async {
    String path = isFetchingAnime ? "anime/$categoryPath" : "manga/$categoryPath";

    try {
      final MalAPI api = MalAPIImpl();
      dynamic data = await api.fetchMedia(path, queryParam, needRank: needRank);
      if (data is Data) {
        List <MediaNode> nodes = [];
        _extractMediaNodes(nodes, data);
        callback(nodes);
      } else {
        List <MediaNodeRanked> nodes = [];
        _extractMediaNodes(nodes, data);
        callback(nodes);
      }
      if (dataCallback != null) {
        dataCallback(data);
      }
    } catch (e) {
      _log.e(e);
    }
  }

  static void rankedMedia(
    bool isFetchingAnime,
    ApiCallback<List<MediaNodeRanked>> callback,
    {ApiCallback<DataWithRank>? dataCallback,
    Map<String, dynamic> queryParam = const {},}
  ) async {
    String path = isFetchingAnime ? "anime/ranking" : "manga/ranking";
    List<MediaNodeRanked> nodes;

    try {
      final MalAPIImpl api = MalAPIImpl();
      nodes = [];
      DataWithRank data = await api.fetchRankedMedia(path, queryParam);
      if (dataCallback != null) {
        dataCallback(data);
      }
      _extractMediaNodes(nodes, data);
      callback(nodes);
    } catch (e) {
      _log.e(e);
    }
  }

  static void userInformation(
    ApiCallback<UserInformation> callback,
    {List<String> fields = const []}
  ) async {
    try {
      final MalAPI api = MalAPIImpl();
      final UserInformation userInfo = await api.fetchUserInfo(fields);
      callback(userInfo);
    } catch(e) {
      _log.e(e);
    }
  }

  static void prevNextPage(
    String nextPage,
    ApiCallback<List<MediaNode>> callback,
    ApiCallback<Paging> pagingCallback
  ) async {
    try {
      final MalAPI api = MalAPIImpl();
      final Data data = await api.nextPage(nextPage);
      final List<MediaNode> nodes = [];
      _extractMediaNodes(nodes, data);
      callback(nodes);
      data.paging.next != null || data.paging.previous != null ?
        pagingCallback(data.paging) : _log.i("paging callback is not invoked, paging's object empty");
    } catch(e) {
      _log.e(e);
    }
  }

  static void fetchMediaById(
    int id,
    bool isAnime,
    ApiCallback<MediaNode> callback
  ) async {
    final MalAPI api = MalAPIImpl();
    callback(await api.findMediaById(id, isAnime, fields: _mediaFields));
  }
}
