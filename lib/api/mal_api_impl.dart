import 'dart:convert';

import 'package:anime_gallery/api/mal_api.dart';
import 'package:anime_gallery/model/data.dart';
import 'package:anime_gallery/model/media_node.dart';
import 'package:anime_gallery/model/update_media.dart';
import 'package:anime_gallery/util/global_constant.dart';
import 'package:http/http.dart';
import 'package:anime_gallery/api/constant.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/data_with_node_ranked.dart';
import '../model/user_information.dart';

typedef GenericCallback<T> = T Function();
typedef AccessTokenCallback<T> = T Function(String);

class MalAPIImpl implements MalAPI {

  final Logger _log = Logger();

  Map<String, String> _authHeader(String accessToken) {
    return {"Authorization" : "Bearer $accessToken"};
  }

  Future<T> _getTokenAndPerformRequest<T>(
    {required AccessTokenCallback<Future<T>> tokenCallback,
     required GenericCallback<Future<T>> onTokenNull}
  ) async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final accessToken = sharedPreferences.get(GlobalConstant.spAccessToken) as String?;
    return accessToken != null ? await tokenCallback(accessToken) : await onTokenNull();
  }

  @override
  Future<dynamic> fetchMedia(
    String path,
    Map<String, dynamic> queries,
    {bool needRank = false}
  ) async => await _getTokenAndPerformRequest<dynamic>(
    tokenCallback: (token) async {
      String fullPath = "";
      String query = "";
      int index = 0;
      if (!path.startsWith("/")) {
        path = "/$path";
      }
      if (queries.isNotEmpty) {
        path = "$path?";
        queries.forEach((key, value) {
          if (value is List) {
            query += "$key=${value.join(",")}";
          } else {
            query += "$key=$value";
          }
          if (index + 1 < queries.length) {
            query += "&";
          }
          index++;
        });
      }
      fullPath = "$path$query";
      try {
        final Response response = await get(Uri.parse("${MalConstant.uriString}$fullPath"), headers: _authHeader(token));
        final Map<String, dynamic> json = jsonDecode(response.body);
        dynamic data;
        data = !needRank ? Data.fromJson(json) : DataWithRank.fromJson(json);
        _log.i("fetching media success with path: $fullPath");
        return data;
      } catch (e) {
        _log.w("fail to fetch media with path: $fullPath");
        if (!needRank) {
          return Data.empty();
        } else {
          return DataWithRank.empty();
        }
      }
    },
    onTokenNull: () {
      _log.w("access token is null");
      if (!needRank) {
        return Future.value(Data.empty());
      } else {
        return Future.value(DataWithRank.empty());
      }
    }
  );

  @override
  Future<UserInformation> fetchUserInfo(List<String> fields) => _getTokenAndPerformRequest<UserInformation>(
    tokenCallback: (token) async {
      try {
        String query = "";
        String fullPath = "";
        if (fields.isNotEmpty) {
          query = "?fields=";
          query += fields.join(",");
        }
        fullPath = "${MalConstant.userInformationUrl}$query";
        _log.i(fullPath);
        final Response response = await get(Uri.parse(fullPath), headers: _authHeader(token));
        final Map<String, dynamic> json = jsonDecode(response.body);
        final userInformation = UserInformation.fromJson(json);
        _log.i("user's information successfully received: ${userInformation.name}");
        return userInformation;
      } catch(e) {
        _log.e(e);
        return UserInformation.empty();
      }
    },
    onTokenNull: () {
      _log.w("access token is null");
      return Future.value(UserInformation.empty());
    }
  );

  @override
  Future<Data> nextPage(String nextPage) => _getTokenAndPerformRequest<Data>(
    tokenCallback: (token) async {
      try {
        if (nextPage.isNotEmpty) {
          final Response response = await get(Uri.parse(nextPage), headers: _authHeader(token));
          final Map<String, dynamic> json = jsonDecode(response.body);
          final Data data = Data.fromJson(json);
          _log.i("next page has been loaded");
          return data;
        } else {
          _log.w("next page is not exist");
          return Data.empty();
        }
      } catch (e) {
        _log.e(e);
        return Data.empty();
      }
    },
    onTokenNull: () {
      _log.w("access token is null");
      return Future.value(Data.empty());
    }
  );

  @override
  Future<MediaNode> findMediaById(
    int id,
    bool isAnime,
    {List<String> fields= const []}
  ) => _getTokenAndPerformRequest(
    tokenCallback: (token) async {
      String mediaType = "";
      isAnime ? mediaType = "anime" : mediaType = "manga";
      String url = "${MalConstant.uriString}/$mediaType/$id";
      if (fields.isNotEmpty) {
        String joinedFields = fields.join(",");
        url += "?fields=$joinedFields";
      }
      final Response response =
        await get(Uri.parse(url), headers: _authHeader(token));
      final Map<String, dynamic> json = jsonDecode(response.body);
      final MediaNode media = MediaNode.fromJson(json);
      _log.i("success retrieving media");
      return media;
    },
    onTokenNull: () {
      _log.i("token is null");
      return Future.value(MediaNode.empty());
    }
  );

  Future<DataWithRank> fetchRankedMedia(
    String path,
    Map<String, dynamic> queries,
  ) => _getTokenAndPerformRequest(
      tokenCallback: (token) async {
        String fullPath = "";
        String query = "";
        int index = 0;
        if (!path.startsWith("/")) {
          path = "/$path";
        }
        if (queries.isNotEmpty) {
          path = "$path?";
          queries.forEach((key, value) {
            if (value is List) {
              query += "$key=${value.join(",")}";
            } else {
              query += "$key=$value";
            }
            if (index + 1 < queries.length) {
              query += "&";
            }
            index++;
          });
        }
        fullPath = "$path$query";
        _log.i(fullPath);
        try {
          final Response response = await get(Uri.parse("${MalConstant.uriString}$fullPath"), headers: _authHeader(token));
          final Map<String, dynamic> json = jsonDecode(response.body);
          DataWithRank data = DataWithRank.fromJson(json);
          _log.i("fetching media success");
          return data;
        } catch (e) {
          _log.w("fail to fetch media");
          _log.e(e);
          return DataWithRank.empty();
        }
      },
      onTokenNull: () {
        _log.w("access token is null");
        return Future.value(DataWithRank.empty());
      }
  );

  @override
  Future<UpdateMedia> updateMedia(
    int mediaId,
    bool isAnime,
    Map<String, dynamic> body,
  ) => _getTokenAndPerformRequest(
    tokenCallback: (token) async {
      String path = isAnime ? "anime/" : "manga/";
      path += "$mediaId/my_list_status";
      final Response response = await patch(
        Uri.parse("${MalConstant.uriString}/$path"),
        headers: _authHeader(token)..addAll({
          "Content-Type" : "application/x-www-form-urlencoded"
        }),
        body: _encodeBody(body)
      );
      final UpdateMedia updated = UpdateMedia.fromJson(jsonDecode(response.body));
      _log.i("updated: ${updated.score}");
      return updated;
    },
    onTokenNull: () {
      _log.w("token is null, can't perform the request");
      return Future.value(UpdateMedia());
    }
  );

  String _encodeBody(Map<String, dynamic> body) {
    return body.entries.map((e) {
      return "${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value.toString())}";
    }).join("&");
  }

  @override
  Future<bool> removeMedia(int mediaId, bool isAnime) => _getTokenAndPerformRequest(
    tokenCallback: (token) async {
      final path = isAnime ? "anime/$mediaId/my_list_status" : "manga/$mediaId/my_list_status";
      try {
        await delete(Uri.parse("${MalConstant.uriString}/$path"), headers: _authHeader(token));
        _log.i("delete media success with id: (isAnime: $isAnime) $mediaId");
        return true;
      } catch (e) {
        _log.w("fail to delete media");
        return false;
      }
    },
    onTokenNull: () async {
      _log.w("token is null");
      return false;
    }
  );
}