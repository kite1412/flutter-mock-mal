import 'package:anime_gallery/api/mal/mal_api.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../util/global_constant.dart';
import 'mal_api_impl.dart';

class Token {
  final Logger _log = Logger();

  bool _isExpired(String token) {
    try {
      final jwt = JWT.decode(token);
      final current = DateTime.now().millisecondsSinceEpoch;
      if (jwt.payload["exp"] > current) {
        return true;
      }
      return false;
    } catch(e) {
      _log.e(e);
      return false;
    }
  }

  Future<T> call<T>(
    MalAPI api,
  {
    required AccessTokenCallback<Future<T>> tokenCallback,
    required GenericCallback<Future<T>> onTokenNull,
  }) async {
    final SharedPreferences sharedPreferences = await SharedPreferences
        .getInstance();
    final accessToken = sharedPreferences.get(GlobalConstant.spAccessToken) as String?;
    if (accessToken == null) return onTokenNull();
    if (_isExpired(accessToken)) {
      final refresh = sharedPreferences.get(GlobalConstant.spRefreshToken) as String?;
      if (refresh != null) {
        final accessToken = await api.refreshToken(refresh);
        if (accessToken != null) {
          sharedPreferences.setString(GlobalConstant.spAccessToken, accessToken.token!);
          sharedPreferences.setString(GlobalConstant.spRefreshToken, accessToken.refreshToken!);
          return tokenCallback(accessToken.token!);
        }
      }
      return onTokenNull();
    }
    return tokenCallback(accessToken);
  }
}