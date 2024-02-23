import 'package:anime_gallery/api/mal/api_helper.dart';
import 'package:anime_gallery/notifier/global_notifier.dart';
import 'package:anime_gallery/other/media_status.dart';
import 'package:anime_gallery/util/global_constant.dart';
import 'package:anime_gallery/widgets/media_list.dart';
import 'package:anime_gallery/widgets/media_toggle.dart';
import 'package:anime_gallery/widgets/removable_media_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../model/mal/data.dart';
import '../model/mal/media_node.dart';
import '../model/mal/user_information.dart';

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

class _UserListState extends State<UserList> {
  int _selectedStatusIndex = 0;
  bool _hideMediaToggle = false;
  bool _allowScrollPage = true;
  bool _isAppBarOnHide = false;
  bool _isAnime = true;
  bool _isAutoJumpEnabled = false;
  List<MediaStatus> _mediaStatuses = MediaStatus.status(true, includeAll: true);
  List<MediaNode>? _allNodes;
  List<MediaNode>? _onGoingNodes;
  List<MediaNode>? _completedNodes;
  List<MediaNode>? _onHoldNodes;
  List<MediaNode>? _droppedNodes;
  List<MediaNode>? _onPlanNodes;
  late ScrollController _scrollController;
  late final PageController _pageController;

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
    if (!_isAutoJumpEnabled) {
      setState(() {
        _isAutoJumpEnabled = true;
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

  void _decideNodesLoad(List<MediaNode> newLoadedNodes, String? status) {
    if (status == "watching" || status == "reading") {
      setState(() {
        _onGoingNodes?.addAll(newLoadedNodes);
      });
    } else if (status == "completed") {
      setState(() {
        _completedNodes?.addAll(newLoadedNodes);
      });
    } else if (status == "on_hold") {
      setState(() {
        _onHoldNodes?.addAll(newLoadedNodes);
      });
    } else if (status == "dropped") {
      setState(() {
        _droppedNodes?.addAll(newLoadedNodes);
      });
    } else if (status == "plan_to_watch" || status == "plan_to_read") {
      setState(() {
        _onPlanNodes?.addAll(newLoadedNodes);
      });
    } else {
      setState(() {
        _allNodes?.addAll(newLoadedNodes);
      });
    }
  }

  void _fetchMedia(String? status ,{bool isUpdatingPriorStatus = false}) {
    if (status != "*") {
      _LoadData.fetchMedia(
          status: status ?? "",
          isAnime: _isAnime,
          limit: 100,
          doBeforeLoad: () {
            if (status == null) {
              Provider.of<GlobalNotifier>(context, listen: false).allPageUpdate = true;
            }
          },
          onNewNodes: (newNodes) {
            _decideNodes(newNodes, status);
          },
          onNewLoaded: (onNewLoaded) {
            _decideNodesLoad(onNewLoaded, status);
          },
          onComplete: () {
            if (status == null) {
              Provider.of<GlobalNotifier>(context, listen: false).allPageUpdate = false;
            }
            if (isUpdatingPriorStatus) {
              Provider.of<GlobalNotifier>(context, listen: false).statusBeforeUpdate = "*";
            } else {
              if (status != null) {
                Provider.of<GlobalNotifier>(context, listen: false).statusNeedUpdate = "*";
              }
            }
          }
      );
    }
  }

  void _resetState() {
    Provider.of<GlobalNotifier>(context, listen: false).enableMediaToggleChange = true;
    Provider.of<GlobalNotifier>(context ,listen: false).userListShowingAnime = true;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<GlobalNotifier>(context, listen: false).statusNeedUpdate = "*";
      Provider.of<GlobalNotifier>(context, listen: false).statusBeforeUpdate = "*";
      Provider.of<GlobalNotifier>(context, listen: false).currentSessionAlreadyUpdated = true;
    });
    _scrollController = ScrollController()
      ..addListener(_scrollListener);
    _pageController = PageController()
      ..addListener(_pageListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isAnime = Provider.of<GlobalNotifier>(context).userListShowingAnime;
    final statusNeedUpdate = Provider.of<GlobalNotifier>(context).statusNeedUpdate;
    final statusBeforeUpdate = Provider.of<GlobalNotifier>(context, listen: false).statusBeforeUpdate;
    final alreadyUpdated = Provider.of<GlobalNotifier>(context).currentSessionAlreadyUpdated;
    if (statusNeedUpdate != "*" && !alreadyUpdated) {
      _fetchMedia(statusNeedUpdate);
      _fetchMedia(statusBeforeUpdate, isUpdatingPriorStatus: true);
      _fetchMedia(null);
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Provider.of<GlobalNotifier>(context, listen: false).currentSessionAlreadyUpdated = true;
      });
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
    _scrollController.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        onPopInvoked: (isPopped) => _resetState(),
        child: LayoutBuilder(
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
                              icon: const Icon(Icons.arrow_back_rounded),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            )
                        ),
                        title: Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 8, right: widget.userInfo.name.isNotEmpty ? 48 : 0),
                          child: Center(
                            child: SvgPicture.asset(
                              "images/mock-mal-logo.svg",
                              height: 120,
                              width: 120,
                            ),
                          ),
                        ),
                        bottom: _TabBar(
                          selectedStatusIndex: _selectedStatusIndex,
                          isAnime: Provider.of<GlobalNotifier>(context).userListShowingAnime,
                          onStatusTap: (status) {
                            _isAppBarOnHide && _hideMediaToggle ? _scrollController.jumpTo(kToolbarHeight) : _scrollController.jumpTo(0);
                            // prevent deleting upon status change in 'all' page
                            // on the next selected page.
                            // Provider.of<GlobalNotifier>(context, listen: false).isDismissalDone = true;
                            setState(() {
                              _isAutoJumpEnabled = true;
                              _selectedStatusIndex = status.index;
                            });
                            _pageController.jumpToPage(status.index);
                          },
                          isAutoJumpEnabled: _isAutoJumpEnabled,
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
                          // Provider.of<GlobalNotifier>(context, listen: false).isDismissalDone = true;
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
        ),
      )
    );
  }
}

class _TabBar extends StatefulWidget implements PreferredSizeWidget {
  int selectedStatusIndex = 0;
  bool isAutoJumpEnabled = true;
  final bool isAnime;
  final void Function(MediaStatus) onStatusTap;

  _TabBar({
    super.key,
    required this.isAnime,
    required this.onStatusTap,
    required this.selectedStatusIndex,
    required this.isAutoJumpEnabled,
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
        if (mounted) {
          if (isSelected) {
            _log.i("on visible: ${status.index}");
            if (visibilityInfo.visibleFraction < 1.0 &&
                !Provider.of<GlobalNotifier>(context, listen: false).isOnDetail &&
                widget.isAutoJumpEnabled) {
              _jump(status.index);
            }
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
          widget.isAutoJumpEnabled = false;
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
  List<MediaNode>? nodes;
  bool isAnime;
  void Function(List<MediaNode>)? doWithNewNodes;

  _Page({
    super.key,
    required this.status,
    required this.isAnime,
    this.nodes,
    this.doWithNewNodes,
  });

  @override
  State<_Page> createState() => _PageState();
}

class _PageState extends State<_Page> {
  bool _isLoading = true;
  bool _isOnUpdate = false;
  bool _warnOnce = true;

  SnackBar _snackBar() {
    return SnackBar(
      content: Text(
        "Almost done...",
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      duration: const Duration(milliseconds: 1000),
      behavior: SnackBarBehavior.floating,
      width: 200,
    );
  }

  @override
  void initState() {
    super.initState();
    _log.i("init user list: ${widget.status.name}");
    if (widget.nodes == null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Provider.of<GlobalNotifier>(context, listen: false).enableMediaToggleChange = false;
        final now = Provider.of<GlobalNotifier>(context, listen: false).statusNeedUpdate;
        final before = Provider.of<GlobalNotifier>(context, listen: false).statusBeforeUpdate;
        if (before != widget.status.jsonName && now != widget.status.jsonName) {
          _LoadData.fetchMedia(
            status: widget.status.jsonName,
            isAnime: widget.isAnime,
            limit: 100,
            onNewNodes: (newNodes) {
              if (newNodes.isEmpty) {
                setState(() {
                  widget.nodes = [];
                  _isLoading = false;
                });
                Provider.of<GlobalNotifier>(context, listen: false).enableMediaToggleChange = true;
              } else {
                setState(() {
                  widget.nodes = newNodes;
                });
              }
              // ensure the parent's nodes is not null in initial fetch,
              // hence avoid null check error on onComplete callback.
              widget.doWithNewNodes?.call(widget.nodes!);
            },
            isLoadNew: (isLoadNew) {
              if (isLoadNew) {
                if (_warnOnce) {
                  ScaffoldMessenger.of(context).showSnackBar(_snackBar());
                  _warnOnce = false;
                }
              }
            },
            onNewLoaded: (newLoadedNodes) {
              setState(() {
                widget.nodes!.addAll(newLoadedNodes);
              });
            },
            onComplete: () {
              setState(() {
                _isLoading = false;
              });
              _warnOnce = true;
              Provider.of<GlobalNotifier>(context, listen: false).enableMediaToggleChange = true;
              widget.doWithNewNodes?.call(widget.nodes!);
            },
          );
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isReady = Provider.of<GlobalNotifier>(context).changeMediaTypeReady;
    final needUpdate = Provider.of<GlobalNotifier>(context).statusNeedUpdate;
    final allPageUpdate = Provider.of<GlobalNotifier>(context, listen: false).allPageUpdate;
    if (needUpdate == widget.status.jsonName && needUpdate != "*") {
      setState(() {
        _isOnUpdate = true;
      });
    } else {
      if (_isOnUpdate && needUpdate == "*") {
        setState(() {
          _isOnUpdate = false;
        });
      }
    }
    if (allPageUpdate && widget.status.jsonName.isEmpty) {
      setState(() {
        _isOnUpdate = true;
      });
    } else {
      if (_isOnUpdate && widget.status.jsonName.isEmpty) {
        setState(() {
          _isOnUpdate = false;
        });
      }
    }

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
          _isLoading = false;
        });
      } else {
        _LoadData.fetchMedia(
            status: widget.status.jsonName,
            isAnime: widget.isAnime,
            limit: 100,
            onNewNodes: (newNodes) {
              if (newNodes.isEmpty) {
                setState(() {
                  widget.nodes = [];
                  _isLoading = false;
                });
                Provider.of<GlobalNotifier>(context, listen: false).enableMediaToggleChange = true;
              } else {
                setState(() {
                  widget.nodes = newNodes;
                });
              }
              widget.doWithNewNodes?.call(newNodes);
            },
            isLoadNew: (isLoadNew) {
              if (isLoadNew) {
                if (_warnOnce) {
                  ScaffoldMessenger.of(context).showSnackBar(_snackBar());
                  _warnOnce = false;
                }
              }
            },
            onNewLoaded: (newLoadedNodes) {
              if (_warnOnce) {
                ScaffoldMessenger.of(context).showSnackBar(_snackBar());
                _warnOnce = false;
              }
              setState(() {
                widget.nodes?.addAll(newLoadedNodes);
              });
            },
            onComplete: () {
              setState(() {
                _isLoading = false;
              });
              _warnOnce = true;
              Provider.of<GlobalNotifier>(context, listen: false).enableMediaToggleChange = true;
              widget.doWithNewNodes?.call(widget.nodes!);
            }
        );
      }
      Future.delayed(const Duration(milliseconds: 50)).whenComplete(() {
        Provider.of<GlobalNotifier>(context, listen: false).enableMediaToggleChange = false;
        Provider.of<GlobalNotifier>(context, listen: false).changeMediaTypeReady = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.nodes == null || _isLoading ? const Align(
      child: CircularProgressIndicator(),
    ) :
      widget.nodes!.isEmpty ? Align(
        child: Text(
          "Nothing in the list",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ) :
      Stack(
        children: [
          RemovableMediaList(
            nodes: widget.nodes!,
            isAnime: widget.isAnime,
            status: widget.status,
          ),
          AnimatedPositioned(
            bottom: !_isOnUpdate ? 0 : -50,
            right: 0,
            duration: const Duration(milliseconds: 500),
            child: Container(
              decoration: BoxDecoration(
                color: widget.status.statusColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(10)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              child: Text(
                "${widget.nodes!.length} Entries",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.white
                ),
              ),
            )
          ),
        ],
      );
  }
}

class _LoadData {

  static void fetchMedia(
    {required String status,
    required bool isAnime,
    required int limit,
    // init new nodes, not for loading next nodes
    required void Function(List<MediaNode>) onNewNodes,
    required void Function(List<MediaNode>) onNewLoaded,
    required VoidCallback onComplete,
    VoidCallback? doBeforeLoad,
    void Function(bool)? isLoadNew}
  ) {
    MalAPIHelper.userMedia(
        isAnime,
        {
          "limit" : limit,
          "nsfw" : true,
          "fields" : isAnime  ?
          GlobalConstant.mandatoryFields : GlobalConstant.mangaMandatoryFields
        },
        (data, nodes) async {
          if (doBeforeLoad != null) {
            doBeforeLoad.call();
            await Future.delayed(const Duration(milliseconds: 100));
          }
          if (nodes.isEmpty) {
            onNewNodes(nodes);
            return;
          } else {
            onNewNodes(nodes);
          }
          if (data.paging.next != null) {
            isLoadNew?.call(true);
            _getNextNodes(
              data.paging.next ?? "",
              onNewLoaded: onNewLoaded,
              onLoadComplete: onComplete
            );
          } else {
            isLoadNew?.call(false);
            onComplete();
          }
        },
        status: status.isNotEmpty ? status : null
    );
  }

  static void _getNextNodes(
    String nextPage,
    {void Function(List<MediaNode>)? onNewLoaded,
    VoidCallback? onLoadComplete}
  ) {
    MalAPIHelper.prevNextPage(
      nextPage,
      (newLoaded) {
        onNewLoaded?.call(newLoaded);
      },
      (p0) {},
      dataCallback: (Data data) {
        if (data.paging.next != null) {
          _getNextNodes(
            data.paging.next ?? "",
            onNewLoaded: onNewLoaded,
            onLoadComplete: onLoadComplete
          );
        } else {
          onLoadComplete?.call();
        }
      }
    );
  }
}