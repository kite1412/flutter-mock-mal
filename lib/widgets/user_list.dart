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
import 'package:flutter_svg/svg.dart';
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
  bool _isAnime = true;
  List<MediaStatus> _mediaStatuses = MediaStatus.status(true, includeAll: true);
  late ScrollController _scrollController;
  List<MediaNode>? _allNodes;
  List<MediaNode>? _onGoingNodes;
  List<MediaNode>? _completedNodes;
  List<MediaNode>? _onHoldNodes;
  List<MediaNode>? _droppedNodes;
  List<MediaNode>? _onPlanNodes;
  late final TabController _tabController;
  late final PageController _pageController;

  void _tabControllerListener() {
    if (_tabController.index == 0) {
      Provider.of<GlobalNotifier>(context, listen: false).userListShowingAnime = true;
    } else {
      Provider.of<GlobalNotifier>(context, listen: false).userListShowingAnime = false;
    }
  }

  void _scrollListener() {
    _log.i(_scrollController.offset);
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

  SnackBar _warningSnackBar() {
    return SnackBar(
      content: Text(
        "Please wait...",
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: Colors.white
        ),
      ),
      duration: const Duration(milliseconds: 500),
      backgroundColor: Theme.of(context).colorScheme.primary,
      dismissDirection: DismissDirection.up,
    );
  }

  void _decideNodes(List<MediaNode> newNodes, String? status) {
    if (status == "watching" || status == "reading") {
      setState(() {
        _onGoingNodes = newNodes;
      });
    } else if (status == "completed") {
      setState(() {
        _completedNodes = newNodes;
      });
    } else if (status == "on_hold") {
      setState(() {
        _onHoldNodes = newNodes;
      });
    } else if (status == "dropped") {
      setState(() {
        _droppedNodes = newNodes;
      });
    } else if (status == "plan_to_watch" || status == "plan_to_read") {
      setState(() {
        _onPlanNodes = newNodes;
      });
    } else {
      setState(() {
        _allNodes = newNodes;
      });
    }
  }

  void _fetchMedia(String? status) {
    if (status != "*") {
      MalAPIHelper.userMedia(
          _isAnime,
          {
            "limit" : 100,
            "fields" : _isAnime  ?
            GlobalConstant.mandatoryFields : GlobalConstant.mangaMandatoryFields
          },
          (nodes) {
            _decideNodes(nodes, status);
            Provider.of<GlobalNotifier>(context, listen: false).statusNeedUpdate = "*";
          },
          status: status
      );
    }
  }

  void _updatePreviousStatus(String previousStatus) {
    if (previousStatus != "*") {
      MalAPIHelper.userMedia(
          _isAnime,
          {
            "limit" : 100,
            "fields" : _isAnime  ?
            GlobalConstant.mandatoryFields : GlobalConstant.mangaMandatoryFields
          },
              (nodes) {
            _decideNodes(nodes, previousStatus);
            Provider.of<GlobalNotifier>(context, listen: false).statusBeforeUpdate = "*";
          },
          status: previousStatus
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_tabControllerListener);
    _scrollController = ScrollController()
      ..addListener(_scrollListener);
    _pageController = PageController(keepPage: false)
      ..addListener(_pageListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isAnime = Provider.of<GlobalNotifier>(context).userListShowingAnime;
    final statusNeedUpdate = Provider.of<GlobalNotifier>(context).statusNeedUpdate;
    final statusBeforeUpdate = Provider.of<GlobalNotifier>(context).statusBeforeUpdate;
    if (statusNeedUpdate != "*") {
      _fetchMedia(statusNeedUpdate);
      _updatePreviousStatus(statusBeforeUpdate);
      _fetchMedia(null);
    }
    if (_isAnime != isAnime) {
      setState(() {
        _mediaStatuses = MediaStatus.status(
          isAnime,
          includeAll: true
        );
        _isAnime = isAnime;
        _allNodes = null;
        _onGoingNodes = null;
        _completedNodes = null;
        _onHoldNodes = null;
        _droppedNodes = null;
        _onPlanNodes = null;
      });
      Future.delayed(const Duration(milliseconds: 50)).whenComplete(() {
        Provider.of<GlobalNotifier>(context, listen: false).changeMediaTypeReady = true;
      });
    }
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
                    child: SvgPicture.asset(
                      "images/mock-mal-logo.svg",
                      height: 120,
                      width: 120,
                    ),
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
                  isAnime: Provider.of<GlobalNotifier>(context).userListShowingAnime,
                  isAutoJumpEnable: _isBarAutoJumpEnable,
                  onStatusTap: (status) {
                    _isAppBarOnHide && _hideMediaToggle ? _scrollController.jumpTo(kToolbarHeight) : _scrollController.jumpTo(0);
                    // prevent deleting upon status change in 'all' page
                    // on the next selected page.
                    Provider.of<GlobalNotifier>(context, listen: false).isDismissalDone = true;
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
                  _isAppBarOnHide && _hideMediaToggle ? _scrollController.jumpTo(kToolbarHeight) : _scrollController.jumpTo(0);
                  setState(() {
                    _allowScrollPage = false;
                  });
                  // prevent deleting upon status change in 'all' page
                  // on the next selected page.
                  Provider.of<GlobalNotifier>(context, listen: false).isDismissalDone = true;
                  Future.delayed(const Duration(milliseconds: 550)).whenComplete(() {
                    setState(() {
                      _allowScrollPage = true;
                    });
                  });
                },
                physics: _allowScrollPage ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
                controller: _pageController,
                children: [
                  MediaQuery.removePadding(
                    removeTop: true,
                    context: context,
                    child: _Page(
                      status: _mediaStatuses[0],
                      nodes: _allNodes,
                      isAnime: _isAnime,
                      doWithNewNodes: (newNodes) {
                        setState(() {
                          _allNodes = newNodes;
                        });
                      },
                    ),
                  ),
                  MediaQuery.removePadding(
                    removeTop: true,
                    context: context,
                    child: _Page(
                      status: _mediaStatuses[1],
                      nodes: _onGoingNodes,
                      isAnime: _isAnime,
                      doWithNewNodes: (newNodes) {
                        setState(() {
                          _onGoingNodes = newNodes;
                        });
                      },
                    ),
                  ),
                  MediaQuery.removePadding(
                    removeTop: true,
                    context: context,
                    child: _Page(
                      status: _mediaStatuses[2],
                      nodes: _completedNodes,
                      isAnime: _isAnime,
                      doWithNewNodes: (newNodes) {
                        setState(() {
                          _completedNodes = newNodes;
                        });
                      },
                    ),
                  ),
                  MediaQuery.removePadding(
                    removeTop: true,
                    context: context,
                    child: _Page(
                      status: _mediaStatuses[3],
                      nodes: _onHoldNodes,
                      isAnime: _isAnime,
                      doWithNewNodes: (newNodes) {
                        setState(() {
                          _onHoldNodes = newNodes;
                        });
                      },
                    ),
                  ),
                  MediaQuery.removePadding(
                    removeTop: true,
                    context: context,
                    child: _Page(
                      status: _mediaStatuses[4],
                      nodes: _droppedNodes,
                      isAnime: _isAnime,
                      doWithNewNodes: (newNodes) {
                        setState(() {
                          _droppedNodes = newNodes;
                        });
                      },
                    ),
                  ),
                  MediaQuery.removePadding(
                    removeTop: true,
                    context: context,
                    child: _Page(
                      status: _mediaStatuses[5],
                      nodes: _onPlanNodes,
                      isAnime: _isAnime,
                      doWithNewNodes: (newNodes) {
                        setState(() {
                          _onPlanNodes = newNodes;
                        });
                      },
                    ),
                  ),
                ],
              ),
              AnimatedPositioned(
                right: 0,
                left: 0,
                bottom: _hideMediaToggle ? -58 : 10,
                duration: const Duration(milliseconds: 150),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (!Provider.of<GlobalNotifier>(context, listen: false).enableMediaToggleChange) {
                          ScaffoldMessenger.of(context).showSnackBar(_warningSnackBar());
                        }
                      },
                      child: MediaToggle(
                        onToggleChange: (index) {
                          if (index == 0) {
                            if (!Provider.of<GlobalNotifier>(context, listen: false).userListShowingAnime) {
                              Provider.of<GlobalNotifier>(context, listen: false).userListShowingAnime = true;
                              _log.i(Provider.of<GlobalNotifier>(context, listen: false).userListShowingAnime);
                              Provider.of<GlobalNotifier>(context, listen: false).enableMediaToggleChange = false;
                            }
                          } else {
                            if (Provider.of<GlobalNotifier>(context, listen: false).userListShowingAnime) {
                              Provider.of<GlobalNotifier>(context, listen: false).userListShowingAnime = false;
                              _log.i(Provider.of<GlobalNotifier>(context, listen: false).userListShowingAnime);
                              Provider.of<GlobalNotifier>(context, listen: false).enableMediaToggleChange = false;
                            }
                          }
                        },
                      ),
                    ),
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

/*
   TODO
    Make the page to persists its state across page change,
    update the page accordingly based on updated media's status.
    (my head was already full while writing this sht)
 */
class _Page extends StatefulWidget {
  MediaStatus status;
  List<MediaNode>? nodes;
  bool isAnime;
  void Function(List<MediaNode>)? doWithNewNodes;

  _Page({
    super.key,
    required this.status,
    required this.isAnime,
    this.nodes,
    this.doWithNewNodes
  });

  @override
  State<_Page> createState() => _PageState();
}

class _PageState extends State<_Page> {
  bool _isLoading = true;
  List<MediaNode>? _nodes;

  void _fetchMedia(int limit, bool isAnime) async {
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
          Provider.of<GlobalNotifier>(context, listen: false).enableMediaToggleChange = true;
          _log.i("onFirstCall is null: ${widget.doWithNewNodes == null}");
          widget.doWithNewNodes?.call(nodes);
        },
        status: widget.status.jsonName.isNotEmpty ? widget.status.jsonName : null
    );
  }

  @override
  void initState() {
    super.initState();
    _log.i("init user list: ${widget.status.name}");
    if (widget.nodes != null) {
      setState(() {
        _nodes = widget.nodes;
        _isLoading = false;
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Provider.of<GlobalNotifier>(context, listen: false).enableMediaToggleChange = false;
        _fetchMedia(100, widget.isAnime);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isReady = Provider.of<GlobalNotifier>(context).changeMediaTypeReady;
    final statusNeedUpdate = Provider.of<GlobalNotifier>(context).statusNeedUpdate;
    // transition from anime to manga and vice versa
    if (isReady) {
      setState(() {
        _isLoading = true;
      });
      setState(() {
        widget.status = MediaStatus.status(widget.isAnime, includeAll: true)[widget.status.index];
      });
      if (widget.nodes != null) {
        setState(() {
          _nodes = widget.nodes;
          _isLoading = false;
        });
      } else {
        _fetchMedia(100, widget.isAnime);
      }
      Future.delayed(const Duration(milliseconds: 50)).whenComplete(() {
        Provider.of<GlobalNotifier>(context, listen: false).enableMediaToggleChange = false;
        Provider.of<GlobalNotifier>(context, listen: false).changeMediaTypeReady = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        isAnime: widget.isAnime,
        isSliver: false,
        isCardDismissible: widget.status.jsonName.isEmpty ? false : true,
        newNodes: (newNodes) {
          widget.doWithNewNodes?.call(newNodes);
          setState(() {
            _nodes = newNodes;
          });
        },
      );
  }
}