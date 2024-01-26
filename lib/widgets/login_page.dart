import 'package:anime_gallery/util/global_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.afterAuthComplete});
  final Function afterAuthComplete;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _androidChannel = const MethodChannel("authorization:android");
  final MethodChannel _methodChannel = const MethodChannel("android:authorization");
  final Logger _log = Logger();

  void _authorize() async {
    await _methodChannel.invokeMethod<String>("authorization");
  }

  void _saveAccessToken(String accessToken) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(GlobalConstant.spAccessToken, accessToken);
  }

  @override
  void initState() {
    super.initState();

    _androidChannel.setMethodCallHandler((call) async {
      if (call.method == "authCode") {
        final authCode = call.arguments as String?;
        if (authCode != null) {
          _log.i("auth code received");
        } else {
          _log.w("auth code is null, token access can't take place");
        }
      }
      if (call.method == "accessToken") {
        final accessToken = call.arguments as String?;
        if (accessToken != null) {
          _log.i("access token is received");
          _saveAccessToken(accessToken);
          widget.afterAuthComplete();
        } else {
          _log.w("access token is null, can't proceed to main menu");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GestureDetector(
            onTap: () {
              _authorize();
            },
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(100)
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Image.asset(
                      "images/mal-logo.png",
                      height: 60,
                      width: 60,
                    ),
                    const SizedBox(width: 16,),
                    Text(
                      "Login with MAL account",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              )
            ),
          )
        )
      ),
    );
  }
}