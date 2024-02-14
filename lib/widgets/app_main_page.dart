import 'package:anime_gallery/model/mal/user_information.dart';
import 'package:anime_gallery/util/global_constant.dart';
import 'package:anime_gallery/widgets/discovery_page.dart';
import 'package:anime_gallery/widgets/media_card.dart';
import 'package:anime_gallery/widgets/media_toggle.dart';
import 'package:anime_gallery/widgets/profile_detail.dart';
import 'package:anime_gallery/widgets/user_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../notifier/global_notifier.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.info});
  final UserInformation info;

  @override
  State<StatefulWidget> createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  final Logger _log = Logger();
  int _selectedIndex = 0;
  UserInformation userInfo = UserInformation.empty();
  double _appBarHeight = kToolbarHeight;
  bool _isOnHide = false;
  final ScrollController controller = ScrollController();

  void _updateIndex(int newIndex) {
    setState(() {
      _selectedIndex = newIndex;
    });
  }

  void _showProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return ProfileDetail(userInfo: userInfo);
      })
    );
  }

  Color navDesIconColor(int thisPage) {
    if (_selectedIndex == thisPage) {
      return Colors.white;
    } else {
      return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      userInfo = widget.info;
    });
  }

  void _adjustAppBarSize(ScrollController controller) {
    if (!_isOnHide) {
      if (controller.position.userScrollDirection == ScrollDirection.reverse) {
        _log.i("app bar is on hide");
        setState(() {
          _appBarHeight = 0.0;
          _isOnHide = true;
        });
      }
    } else {
      if (controller.position.userScrollDirection == ScrollDirection.forward) {
        _log.i("app bar is visible");
        setState(() {
          _appBarHeight = kToolbarHeight;
          _isOnHide = false;
        });
      }
    }
  }

  // TODO use slivers instead
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: GlobalConstant.tabs.length,
      child: Scaffold(
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => _updateIndex(index),
          destinations: <Widget>[
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: navDesIconColor(0), size: 30,),
              label: "Home",
              selectedIcon: Icon(Icons.home, color: navDesIconColor(0), size: 30,),
            ),
            NavigationDestination(
              icon: Icon(Icons.list, color: navDesIconColor(1), size: 30,),
              label: "My List",
              selectedIcon: Icon(Icons.list, color: navDesIconColor(1), size: 30,),
            ),
          ],
        ),
        body: [
          TabBarView(
            children: [
              // TODO(change to MMediaList and set the UpdateMediaNotifier.userListShowingAnime to true at init)
              MediaList(isAnime: true, appBarListener: (controller) => _adjustAppBarSize(controller)),
              MediaList(isAnime: false, appBarListener: (controller) => _adjustAppBarSize(controller)),
            ],
          ),
          PopScope(
            canPop: false,
            onPopInvoked: (index) {
              setState(() {
                _selectedIndex = 0;
              });
            },
            child: UserList(userInfo: userInfo, onProfileTap: () => _showProfile(context)),
          )
        ][_selectedIndex],
        // appBar: AppBar(
        //   toolbarHeight: _appBarHeight,
        //   bottom: _selectedIndex == 0 ? TabBar(
        //     splashFactory: NoSplash.splashFactory,
        //     tabs: GlobalConstant.tabs.map((e) {
        //       return Tab(text: e,);
        //     }).toList(),
        //   ) : null,
        //   title: Padding(
        //     padding: const EdgeInsets.all(8),
        //     child: Center(
        //       child: Image.asset("images/mal-logo-full.png", height: 120, width: 120,),
        //     ),
        //   ),
        //   leading: Padding(
        //       padding: const EdgeInsets.all(8),
        //       child: IconButton(
        //         icon: const Icon(Icons.favorite_outline),
        //         onPressed: () {
        //           //TODO show user's favorite anime and manga
        //         },
        //       )
        //   ),
        //   actions: [
        //     Padding(
        //       padding: const EdgeInsets.all(8),
        //       child: GestureDetector(
        //         onTap: () {
        //           _showProfile(context);
        //         },
        //         child: Hero(
        //           tag: "profile-pic",
        //           child: ClipOval(
        //             child: Image(
        //                 height: 40.0,
        //                 width: 40.0,
        //                 image: Image.network(userInfo.picture).image
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        floatingActionButton: _selectedIndex == 0 ? FloatingActionButton.large(
          onPressed: () {
            setState(() {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return const DiscoveryPage();
                })
              );
            });
          },
          shape: const CircleBorder(),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(200, 46, 90, 136),
                  MediaQuery.of(context).platformBrightness == Brightness.dark ?
                    Colors.black87 : Colors.grey.shade400,
                ]
              ),
              shape: BoxShape.circle
            ),
            child: const Icon(Icons.search_rounded, color: Colors.white, size: 40,),
          )
        ) : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}