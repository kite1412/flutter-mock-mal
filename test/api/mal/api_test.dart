import 'package:anime_gallery/api/mal/mal_api_impl.dart';
import 'package:anime_gallery/model/mal/access_token.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../sensitive.dart';

class _MalTest {
  _MalTest() {
    _testAll();
  }

  final MalAPIImpl _api = MalAPIImpl();

  void _testAll() {
    _refreshToken();
  }

  void _refreshToken() {
    test("refresh token", () async {
      final res = await _api.refreshToken_test(malRefreshToken, clientId);
      expect(res.runtimeType, AccessToken);
    });
  }
}

void main() {
  _MalTest();
}