import 'package:anime_gallery/api/api_helper.dart';
import 'package:anime_gallery/util/global_constant.dart';
import 'package:anime_gallery/widgets/app_main_page.dart';
import 'package:anime_gallery/widgets/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    const _App(),
  );
}

class _App extends StatefulWidget {
  const _App();

  @override
  State<_App> createState() => _AppState();
}

class _AppState extends State<_App> {
  final ScrollController controller = ScrollController();
  Widget _thisHome = LayoutBuilder(builder: (context, constraint) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 8.0,),
              Text(
                "Please Wait...",
                style: Theme.of(context).textTheme.displayMedium!.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  });

  void _isAuthorized() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    String? accessToken = sharedPreferences.get(GlobalConstant.spAccessToken) as String?;
    if (accessToken != null) {
      MalAPIHelper.userInformation((userInformation) {
        setState(() {
          _thisHome = MainPage(info: userInformation);
        });
      });
    } else {
      setState(() {
        _thisHome = LoginPage(afterAuthComplete: _isAuthorized);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _isAuthorized();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _appTheme(),
      darkTheme: _darkTheme(),
      home: _thisHome,
    );
  }

  ThemeData _appTheme() {
    return ThemeData(
      splashFactory: NoSplash.splashFactory,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.white,
        primary: const Color.fromARGB(255, 46, 90, 136),
        background: Colors.white,
        surface: Colors.white,
        brightness: Brightness.light
      ),
      textTheme: const TextTheme(
        labelSmall: TextStyle(fontFamily: "Cabin", color: Colors.black),
        bodySmall: TextStyle(fontFamily: "Cabin", color: Colors.black),
        displaySmall: TextStyle(fontFamily: "Cabin", color: Colors.black, fontSize: 20),
        displayMedium: TextStyle(fontFamily: "Cabin", color: Colors.black, fontSize: 26),
        displayLarge: TextStyle(fontFamily: "Cabin", color: Colors.black, fontSize: 32),
        bodyLarge: TextStyle(fontFamily: "Cabin", color: Colors.black),
        bodyMedium: TextStyle(fontFamily: "Cabin", color: Colors.black),
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(color: Colors.black);
          } else { return const TextStyle(color: Colors.grey); }
        }),
        indicatorColor: const Color.fromARGB(255, 46, 90, 136),
      ),
      tabBarTheme: const TabBarTheme(
        indicatorColor: Color.fromARGB(255, 46, 90, 136),
        labelColor: Color.fromARGB(255, 46, 90, 136),
        dividerColor: Colors.white,
        labelStyle: TextStyle(fontSize: 18, fontFamily: "Cabin"),
        unselectedLabelStyle: TextStyle(fontSize: 16, fontFamily: "Cabin"),
      ),
      iconTheme: const IconThemeData(
        color: Colors.black
      ),
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(
          iconColor: MaterialStatePropertyAll(Colors.black),
          )
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color.fromARGB(255, 46, 90, 136),
      ),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      tabBarTheme: const TabBarTheme(
        indicatorColor: Color.fromARGB(255, 46, 90, 136),
        labelColor: Color.fromARGB(255, 46, 90, 136),
        dividerColor: Color.fromARGB(255, 30, 30, 30),
        labelStyle: TextStyle(fontSize: 18, fontFamily: "Cabin"),
        unselectedLabelStyle: TextStyle(fontSize: 16, fontFamily: "Cabin"),
      ),
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.white,
        surfaceTint: const Color.fromARGB(255, 35, 35, 35),
        background: const Color.fromARGB(255, 30, 30, 30),
        surface: const Color.fromARGB(255, 35, 35, 35),
        primary: const Color.fromARGB(255, 46, 90, 136),
        secondary: const Color.fromARGB(255, 46, 90, 136),
        brightness: Brightness.dark
      ),
      textTheme: const TextTheme(
        labelSmall: TextStyle(fontFamily: "Cabin", color: Colors.white),
        bodySmall: TextStyle(fontFamily: "Cabin", color: Colors.white),
        displaySmall: TextStyle(fontFamily: "Cabin", color: Colors.white, fontSize: 20),
        displayMedium: TextStyle(fontFamily: "Cabin", color: Colors.white, fontSize: 26),
        displayLarge: TextStyle(fontFamily: "Cabin", color: Colors.white, fontSize: 32),
        bodyLarge: TextStyle(fontFamily: "Cabin", color: Colors.white),
        bodyMedium: TextStyle(fontFamily: "Cabin", color: Colors.white),
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(color: Colors.white);
          } else { return const TextStyle(color: Colors.grey); }
        }),
        indicatorColor: const Color.fromARGB(255, 46, 90, 136),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        largeSizeConstraints: BoxConstraints(minHeight: 80, minWidth: 80),
        backgroundColor: Color.fromARGB(255, 46, 90, 136),
      ),
      iconTheme: const IconThemeData(
          color: Colors.white
      ),
      iconButtonTheme: const IconButtonThemeData(
          style: ButtonStyle(
            iconColor: MaterialStatePropertyAll(Colors.white),
          )
      )
    );
  }
}
