import 'dart:convert';
import 'dart:ui';

import 'package:anime_gallery/api/mal/mal_api.dart';
import 'package:anime_gallery/api/mal/token.dart';
import 'package:anime_gallery/model/mal/access_token.dart';
import 'package:anime_gallery/model/mal/media_node.dart';
import 'package:anime_gallery/util/global_constant.dart';
import 'package:http/http.dart';
import 'package:anime_gallery/api/mal/constant.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/mal/data.dart';
import '../../model/mal/data_with_node_ranked.dart';
import '../../model/mal/update_media.dart';
import '../../model/mal/user_information.dart';

typedef GenericCallback<T> = T Function();
typedef AccessTokenCallback<T> = T Function(String);

class MalAPIImpl implements MalAPI {

  final _log = Logger();
  final token = Token();

  Map<String, String> _authHeader(String accessToken) {
    return {"Authorization" : "Bearer $accessToken"};
  }

  Map<String, String> _authBasicHeader(String clientId) {
    return {"Authorization" : "Basic ${base64Encode(utf8.encode("$clientId:"))}"};
  }

  // Future<T> _getTokenAndPerformRequest<T>(
  //     {required AccessTokenCallback<Future<T>> tokenCallback,
  //       required GenericCallback<Future<T>> onTokenNull}
  //     ) async {
  //   final SharedPreferences sharedPreferences = await SharedPreferences
  //       .getInstance();
  //   final accessToken = sharedPreferences.get(
  //       GlobalConstant.spAccessToken) as String?;
  //   return accessToken != null ? await tokenCallback(accessToken) : await onTokenNull();
  // }

  @override
  Future<dynamic> fetchMedia(
    String path,
    Map<String, dynamic> queries,
    {bool needRank = false,
    VoidCallback? onFailure}
  ) async => await token<dynamic>(
    this,
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
        onFailure?.call();
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
  Future<UserInformation> fetchUserInfo(List<String> fields) => token<UserInformation>(
    this,
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
  Future<Data> nextPage(String nextPage) => token<Data>(
    this,
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
  ) => token<MediaNode>(
    this,
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
  ) => token<DataWithRank>(
      this,
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

  String _encodeBody(Map<String, dynamic> body) {
    return body.entries.map((e) {
      return "${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value.toString())}";
    }).join("&");
  }

  @override
  Future<UpdateMedia> updateMedia(
    int mediaId,
    bool isAnime,
    Map<String, dynamic> body,
  ) => token<UpdateMedia>(
    this,
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

  @override
  Future<bool> removeMedia(int mediaId, bool isAnime) => token<bool>(
    this,
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

  @override
  Future<DataWithRank> rankedNextPage(String nextPage) => token<DataWithRank>(
    this,
    tokenCallback: (token) async {
      try {
        if (nextPage.isNotEmpty) {
          final Response response = await get(Uri.parse(nextPage), headers: _authHeader(token));
          final Map<String, dynamic> json = jsonDecode(response.body);
          final DataWithRank data = DataWithRank.fromJson(json);
          _log.i("next page has been loaded");
          return data;
        } else {
          _log.w("next page is not exist");
          return DataWithRank.empty();
        }
      } catch (e) {
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
  Future<AccessToken?> refreshToken(String refreshToken) async {
    final body = {"grant_type" : "refresh_token", "refresh_token" : refreshToken};
    final sp = await SharedPreferences.getInstance();
    try {
      final response = await post(
          Uri.parse(MalConstant.tokenEndpoint),
          headers: _authBasicHeader(sp.getString(GlobalConstant.spClientId)!),
          body: _encodeBody(body)
      );
      final json = jsonDecode(response.body);
      return AccessToken.fromJson(json);
    } catch(e) {
      _log.e(e);
      return null;
    }
  }

  Future<AccessToken?> refreshToken_test(String refreshToken, String clientId) async {
    final body = {"grant_type" : "refresh_token", "refresh_token" : refreshToken};
    try {
      final response = await post(
          Uri.parse(MalConstant.tokenEndpoint),
          headers: _authBasicHeader(clientId),
          body: _encodeBody(body)
      );
      final json = jsonDecode(response.body);
      return AccessToken.fromJson(json);
    } catch(e) {
      _log.e(e);
      return null;
    }
  }
}