import 'package:anime_gallery/api/api_helper.dart';
import 'package:anime_gallery/model/user_information.dart';
import 'package:anime_gallery/notifier/update_media_notifier.dart';
import 'package:anime_gallery/other/media_status.dart';
import 'package:anime_gallery/util/global_constant.dart';
import 'package:anime_gallery/widgets/media_list.dart';
import 'package:anime_gallery/widgets/media_toggle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../model/media_node.dart';

final Logger _log = Logger();

class UserList extends StatefulWidget {

  final UserInformation userInfo;
  final VoidCallback onProfileTap;
  const UserList({
    super.key,
    required this.userInfo,
    required this.onProfileTap
  });

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList>
    with SingleTickerProviderStateMixin {
  int _selectedStatusIndex = 0;
  bool _hideMediaToggle = false;
  bool _allowScrollPage = true;
  bool _isBarAutoJumpEnable = true;
  bool _isAppBarOnHide = false;
  List<MediaStatus> _mediaStatuses = MediaStatus.status(true, includeAll: true);
  late final TabController _tabController;
  late final ScrollController _scrollController;
  late final PageController _pageController;


  void _tabControllerListener() {
    if (_tabController.index == 0) {
      Provider.of<UpdateMediaNotifier>(context, listen: false).userListShowingAnime = true;
    } else {
      Provider.of<UpdateMediaNotifier>(context, listen: false).userListShowingAnime = false;
    }
    // if (_tabController.index == 0) {
    //   setState(() {
    //     _isAnime = true;
    //   });
    // } else {
    //   setState(() {
    //     _isAnime = false;
    //   });
    // }
  }

  void _scrollListener() {
    if (_scrollController.offset >= kToolbarHeight) {
      if (!_isAppBarOnHide) {
        setState(() {
          _isAppBarOnHide = true;
        });
      }
    } else {
      if (_isAppBarOnHide) {
        setState(() {
          _isAppBarOnHide = false;
        });
      }
    }
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (!_hideMediaToggle) {
        setState(() {
          _hideMediaToggle = true;
        });
      }
    }
    if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (_hideMediaToggle) {
        setState(() {
          _hideMediaToggle = false;
        });
      }
    }
  }

  void _pageListener() {
    if (!_isBarAutoJumpEnable) {
      setState(() {
        _isBarAutoJumpEnable = true;
      });
    }
    if (_pageController.page != null) {
      setState(() {
        _selectedStatusIndex = (_pageController.page! + 0.7).toInt();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_tabControllerListener);
    _scrollController = ScrollController()
      ..addListener(_scrollListener);
    _pageController = PageController()
      ..addListener(_pageListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _mediaStatuses = MediaStatus.status(
        Provider.of<UpdateMediaNotifier>(context).userListShowingAnime,
        includeAll: true
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _scrollController.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, boool) {
            return [
              SliverAppBar(
                snap: true,
                pinned: true,
                floating: true,
                leading: Padding(
                    padding: const EdgeInsets.all(8),
                    child: IconButton(
                      icon: const Icon(Icons.favorite_outline),
                      onPressed: () {
                        //TODO show user's favorite anime and manga
                      },
                    )
                ),
                title: Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 8, right: widget.userInfo.name.isEmpty ? 48 : 0),
                  child: Center(
                    child: Image.asset("images/mal-logo-full.png", height: 120, width: 120,),
                  ),
                ),
                actions: [
                  widget.userInfo.name.isNotEmpty ? Padding(
                    padding: const EdgeInsets.all(8),
                    child: GestureDetector(
                      onTap: widget.onProfileTap,
                      child: Hero(
                        tag: "profile-pic",
                        child: ClipOval(
                          child: Image(
                              height: 40.0,
                              width: 40.0,
                              image: Image.network(widget.userInfo.picture).image
                          ),
                        ),
                      ),
                    ),
                  ) : const SizedBox(),
                ],
                bottom: _TabBar(
                  selectedStatusIndex: _selectedStatusIndex,
                  isAnime: Provider.of<UpdateMediaNotifier>(context).userListShowingAnime,
                  isAutoJumpEnable: _isBarAutoJumpEnable,
                  onStatusTap: (status) {
                    setState(() {
                      _selectedStatusIndex = status.index;
                    });
                    _pageController.jumpToPage(status.index);
                  },
                  tabController: _tabController,
                ),
              ),
            ];
          },
          body: Stack(
            children: [
              PageView(
                onPageChanged: (index) {
                  _isAppBarOnHide ? _scrollController.jumpTo(kToolbarHeight) : null;
                  setState(() {
                    _allowScrollPage = false;
                  });
                  Future.delayed(const Duration(milliseconds: 550)).whenComplete(() {
                    setState(() {
                      _allowScrollPage = true;
                    });
                  });
                },
                physics: _allowScrollPage ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
                controller: _pageController,
                children: _mediaStatuses.map((status) {
                  return MediaQuery.removePadding(
                    removeTop: true,
                    context: context,
                    child: _Page(
                      status: status,
                    ),
                  );
                }).toList(),
              ),
              AnimatedPositioned(
                right: 0,
                left: 0,
                bottom: _hideMediaToggle ? -58 : 10,
                duration: const Duration(milliseconds: 150),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    MediaToggle(
                      onToggleChange: (index) {
                        if (index == 0) {
                          if (!Provider.of<UpdateMediaNotifier>(context, listen: false).userListShowingAnime) {
                            Provider.of<UpdateMediaNotifier>(context, listen: false).userListShowingAnime = true;
                            _log.i(Provider.of<UpdateMediaNotifier>(context, listen: false).userListShowingAnime);
                          }
                        } else {
                          if (Provider.of<UpdateMediaNotifier>(context, listen: false).userListShowingAnime) {
                            Provider.of<UpdateMediaNotifier>(context, listen: false).userListShowingAnime = false;
                            _log.i(Provider.of<UpdateMediaNotifier>(context, listen: false).userListShowingAnime);
                          }
                        }
                      },
                    )
                  ],
                )
              ),
            ],
          )
        );
      }
    );
  }
}

class _TabBar extends StatefulWidget implements PreferredSizeWidget {
  int selectedStatusIndex = 0;
  bool isAutoJumpEnable = true;
  final bool isAnime;
  final void Function(MediaStatus) onStatusTap;
  final TabController? tabController;

  _TabBar({
    super.key,
    required this.isAnime,
    required this.onStatusTap,
    required this.selectedStatusIndex,
    required this.isAutoJumpEnable,
    this.tabController,
  });

  @override
  State<_TabBar> createState() => _TabBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);
}

class _TabBarState extends State<_TabBar> {
  final List<GlobalKey> _keys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];
  final List<double> _barsWidth = [];
  final Logger _log = Logger();
  late final ScrollController _scrollController;

  Widget _statusBar(MediaStatus status) {
    final isSelected = widget.selectedStatusIndex == status.index;
    return VisibilityDetector(
        key: _keys[status.index],
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  widget.isAutoJumpEnable = true;
                  widget.selectedStatusIndex = status.index;
                });
                widget.onStatusTap(status);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: status.gradientColors),
                  color: isSelected ? status.statusColor : Colors.transparent,
                  border: !isSelected ? Border.all(color: status.statusColor) : null,
                  borderRadius: const BorderRadius.all(Radius.circular(100))
                ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: status.name.length <= 3 ? 8 : 0),
                      child: Text(
                      status.name,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: isSelected ? Colors.white : status.statusColor,
                      fontWeight: FontWeight.w900
                    ),
                  )
                ),
              )
            ),
          )
        ),
      onVisibilityChanged: (visibilityInfo) {
        if (widget.selectedStatusIndex == status.index) {
          _log.i("on visible: ${status.index}");
          if (visibilityInfo.visibleFraction < 1.0  && widget.isAutoJumpEnable) {
            _jump(status.index);
          }
        }
      }
    );
  }

  double _decideBarWidth(GlobalKey key) {
    final double? width = key.currentContext?.size?.width;
    return width ?? 0.0;
  }

  void _jump(int currentIndex) async {
    try {
      final offset = (_barsWidth[currentIndex] / _scrollController.position.extentTotal) * _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
          currentIndex == 0 ? 0 :
          currentIndex == _barsWidth.length - 1 ? _scrollController.position.maxScrollExtent :
          currentIndex == 1 ? _barsWidth[0]:
          offset,
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear
      );
    } catch (_) {

    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          widget.isAutoJumpEnable = false;
        });
      });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      for (var value in _keys) {
        _barsWidth.add(_decideBarWidth(value));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.transparent,
        height: kTextTabBarHeight,
        width: widget.preferredSize.width,
        child: Row(
          children: [
            Expanded(
              child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return _statusBar(MediaStatus.status(widget.isAnime, includeAll: true)[index]);
                  },
                  itemCount: MediaStatus.status(widget.isAnime, includeAll: true).length
              ),
            ),
            IconButton(
                onPressed: () {},
                icon: Icon(
                  CupertinoIcons.list_bullet_indent,
                  color: Colors.grey.shade600,
                )
            ),
          ],
        )
    );
  }
}

class _Page extends StatefulWidget {
  MediaStatus status;

  _Page({
    super.key,
    required this.status,
  });

  @override
  State<_Page> createState() => _PageState();
}

class _PageState extends State<_Page>
  with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  List<MediaNode>? _nodes;

  @override
  bool get wantKeepAlive => true;

  void _fetchMedia(int limit) {
    final isAnime = Provider.of<UpdateMediaNotifier>(context, listen: false).userListShowingAnime;
    MalAPIHelper.userMedia(
        isAnime,
        {
          "limit" : limit,
          "fields" : isAnime  ?
            GlobalConstant.mandatoryFields : GlobalConstant.mangaMandatoryFields
        },
        (nodes) {
          setState(() {
            _nodes = nodes;
            _isLoading = false;
          });
        },
        status: widget.status.jsonName.isNotEmpty ? widget.status.jsonName : null
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _fetchMedia(100);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isAnime = Provider.of<UpdateMediaNotifier>(context).userListShowingAnime;
    if (isAnime) {
      setState(() {
        _isLoading = true;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }
    setState(() {
      widget.status = MediaStatus.status(isAnime, includeAll: true)[widget.status.index];
    });
    _log.i("page ${widget.status.jsonName} on didDependenciesChange, isAnime: $isAnime");
    _fetchMedia(100);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _nodes == null || _isLoading ? const Align(
      child: CircularProgressIndicator(),
    ) :
      _nodes!.isEmpty ? Align(
        child: Text(
          "Nothing in the list",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ) :
        MMediaList(
          nodes: _nodes!,
          isAnime: Provider.of<UpdateMediaNotifier>(context).userListShowingAnime,
          isSliver: false,
        );
  }
}