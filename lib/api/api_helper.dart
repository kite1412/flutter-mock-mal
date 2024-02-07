import 'dart:convert';

import 'package:anime_gallery/api/constant.dart';
import 'package:anime_gallery/api/mal_api_impl.dart';
import 'package:anime_gallery/model/data_with_node_ranked.dart';
import 'package:anime_gallery/model/node_with_rank.dart';
import 'package:anime_gallery/model/update_media.dart';
import 'package:anime_gallery/other/media_status.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
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
      dataCallback?.call(data);
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

  // So messy, just use the Data callback instead next time, also for any other helper methods.
  static void prevNextPage(
    String nextPage,
    ApiCallback<List<MediaNode>> callback,
    ApiCallback<Paging> pagingCallback,
    {void Function(Data)? dataCallback}
  ) async {
    try {
      if (nextPage.isEmpty) {
        return;
      }
      final MalAPI api = MalAPIImpl();
      final Data data = await api.nextPage(nextPage);
      final List<MediaNode> nodes = [];
      _extractMediaNodes(nodes, data);
      callback(nodes);
      dataCallback?.call(data);
      data.paging.next != null || data.paging.previous != null ?
        pagingCallback(data.paging) : _log.i("paging callback is not invoked, paging's object empty");
    } catch(e) {
      _log.e(e);
    }
  }

  static void fetchMediaById(
    int id,
    bool isAnime,
    ApiCallback<MediaNode> callback,
    {List<String>? fields}
  ) async {
    final MalAPI api = MalAPIImpl();
    callback(await api.findMediaById(id, isAnime, fields: fields ?? _mediaFields));
  }

  static void updateMedia(
    int mediaId,
    bool isAnime,
    void Function(UpdateMedia) callback,
    {String? status,
    int? score,
    int? progress}
  ) async {
    final MalAPI api = MalAPIImpl();
    Map<String, dynamic> body = isAnime ? UpdateMedia.anime(status, score, progress)
        : UpdateMedia.manga(status, score, progress);

    try {
      final UpdateMedia updated = await api.updateMedia(mediaId, isAnime, body);
      _log.i("update media success");
      callback(updated);
    } catch (e) {
      _log.e(e);
      _log.i("fail to updating media");
    }
  }

  static void removeMedia(
    int mediaId,
    bool isAnime,
    void Function(bool) callback
  ) async {
    final MalAPI api = MalAPIImpl();
    final isUpdated = await api.removeMedia(mediaId, isAnime);
    callback(isUpdated);
  }

  static void userMedia(
    bool isAnime,
    Map<String, dynamic> queryParams,
    void Function(Data, List<MediaNode>) callback,
    {String? status,
    String? sort,}
  ) async {
    String path = isAnime ? "users/@me/animelist" : "users/@me/mangalist";
    queryParams.addAll({
      if (status != null) "status" : status,
      if (sort != null) "sort" : sort
    });
    final MalAPI api = MalAPIImpl();
    final List<MediaNode> nodes = [];
    try {
      final Data data = await api.fetchMedia(path, queryParams);
      _extractMediaNodes(nodes, data);
      _log.i("success getting user media list with length: ${nodes.length}");
      callback(data, nodes);
    } catch (e) {
      _log.e(e);
    }
  }
}
