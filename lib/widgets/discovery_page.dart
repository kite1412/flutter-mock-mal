import 'dart:math';
import 'dart:ui';

import 'package:anime_gallery/api/mal/api_helper.dart';
import 'package:anime_gallery/model/mal/data_with_node_ranked.dart';
import 'package:anime_gallery/model/mal/node_with_rank.dart';
import 'package:anime_gallery/model/mal/user_information.dart';
import 'package:anime_gallery/util/history.dart';
import 'package:anime_gallery/util/refresh_content_util.dart';
import 'package:anime_gallery/util/show_dialog.dart';
import 'package:anime_gallery/widgets/general_category.dart';
import 'package:anime_gallery/widgets/genre_sheet.dart';
import 'package:anime_gallery/widgets/media_list.dart';
import 'package:anime_gallery/widgets/media_toggle.dart';
import 'package:anime_gallery/widgets/ranked_category.dart';
import 'package:anime_gallery/widgets/schedule_page.dart';
import 'package:anime_gallery/widgets/search_bar.dart' as my;
import 'package:anime_gallery/util/global_constant.dart';
import 'package:anime_gallery/widgets/search_history.dart';
import 'package:anime_gallery/widgets/user_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logger/logger.dart';
import '../model/mal/data.dart';
import '../model/mal/media_node.dart';
import '../other/media_category.dart';

final Logger _log = Logger();

class DiscoveryPage extends StatefulWidget {
  final UserInformation userInfo;
  final VoidCallback onProfileTap;

  const DiscoveryPage({
    super.key,
    required this.userInfo,
    required this.onProfileTap
  });

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> with SingleTickerProviderStateMixin {
  String _title = "";
  bool _isSearchBarOnFocus = false;
  bool _isShowingMediaList = false;
  bool _isOnMediaListLoading = false;
  bool _isTitleUpdated = false;
  bool _isClearButtonVisible = false;
  bool _isRankShowingAnime = true;
  bool _fetchAnimeSuccess = false;
  bool _fetchMangaSuccess = false;
  bool _isAnime = true;
  List<MediaNodeRanked> _rankingNodes = [];
  List<MediaNodeRanked> _rankingNodesManga = [];
  List<MediaNodeRanked> _intermediateRankingNodes = [];
  List<MediaNode> _suggestionsNodes = [];
  List<MediaNode> _seasonalNodes = [];
  List<String> _searchesHistory = [];
  List<MediaNode>? _animeNodes;
  List<MediaNode>? _mangaNodes;
  RefreshContentUtil? _animeAutoRefresh;
  RefreshContentUtil? _mangaAutoRefresh;
  Data _animeSearchData = Data.empty();
  Data _mangaSearchData = Data.empty();
  Data _suggestionsData = Data.empty();
  Data _onGoingData = Data.empty();
  DataWithRank _rankAnimeData = DataWithRank.empty();
  DataWithRank _rankMangaData = DataWithRank.empty();
  late final History _history;
  late final TextEditingController _textEditingController;
  late final FocusNode _focusNode;
  late final ScrollController _scrollController;
  late final AnimationController _bottomSheetController;

  List<dynamic> categoryNodes(int index) {
    switch(index) {
      case 0:
        return _intermediateRankingNodes;
      case 1:
        return _suggestionsNodes;
      case 2:
        return _seasonalNodes;
      default:
        return [];
    }
  }

  MediaCategory _seasonalCategory() {
    String season = "";
    List<Color> gradients = [];
    switch (DateTime.now().month) {
      case 1:
      case 2:
      case 3:
        season = "winter";
        gradients.addAll( const [
          Color.fromARGB(255, 46, 90, 160),
          Color.fromARGB(200, 46, 90, 136),
          Color.fromARGB(150, 46, 90, 136)
        ]);
          break;
      case 4:
      case 5:
      case 6:
        season = "spring";
        gradients.addAll( const [
          Color.fromARGB(255, 191, 220, 174),
          Color.fromARGB(255, 129, 178, 20),
        ]);
          break;
      case 7:
      case 8:
      case 9:
        season = "summer";
        gradients.addAll( const [
          Color.fromARGB(255, 255, 216, 104),
          Color.fromARGB(255, 248, 97, 90),
          Color.fromARGB(255, 184, 13, 87),
        ]);
          break;
      case 10:
      case 11:
      case 12:
        season = "fall";
        gradients.addAll( const [
          Color.fromARGB(255, 255, 122, 0),
          Color.fromARGB(255, 212, 64, 0),
        ]);
          break;
    }
    return MediaCategory(
      index: 2,
      category: "Seasonal",
      description: "Seasonal anime",
      path: "season/${DateTime.now().year}/$season",
      gradients: gradients,
      queryParams: {
        "limit" : 20,
        "nsfw" : true,
        "fields" : GlobalConstant.mandatoryFields,
      }
    );
  }

  List<MediaCategory> _categories() => [
    const MediaCategory(
      index: 0,
      category: "Rank",
      description: "Works ranking",
      path: "ranking",
      gradients: [
        Color.fromARGB(255, 240, 89, 65),
        Color.fromARGB(255, 190, 49, 68),
        Color.fromARGB(255, 135, 65, 68),
        Color.fromARGB(255, 34, 9, 44),
      ],
      queryParams: {
        "ranking_type" : "all",
        "limit" : 20,
        "nsfw" : true,
        "fields" : GlobalConstant.mandatoryFields,
      }
    ),
    const MediaCategory(
      index: 1,
      category: "Suggestions",
      description: "Suggestions based on your history",
      path: "suggestions",
      gradients: [
        Color.fromARGB(255, 194, 217, 255),
        Color.fromARGB(255, 142, 143, 250),
        Color.fromARGB(255, 46, 90, 136)
      ],
      queryParams: {
        "limit" : 20,
        "fields" : GlobalConstant.mandatoryFields,
        "nsfw" : true,
      }
    ),
    _seasonalCategory(),
  ];

  void _fetchCategoryBasedAnime() {
    MalAPIHelper.mediaWithCategory(true, _categories()[0].path, (nodes) {
      setState(() {
        _intermediateRankingNodes = nodes;
        _rankingNodes = nodes;
      });
    },
      dataCallback: (data) {
        _rankAnimeData = data;
      },
      queryParam: _categories()[0].queryParams,
      needRank: true,
    );
    MalAPIHelper.mediaWithCategory(true, _categories()[1].path, (nodes) {
      setState(() {
        _suggestionsNodes = nodes;
      });
    },
    dataCallback: (data) {
      _suggestionsData = data;
    },
      queryParam: _categories()[1].queryParams
    );
    MalAPIHelper.mediaWithCategory(true, _categories()[2].path, (nodes) {
      setState(() {
        _seasonalNodes = nodes;
      });
    },
    dataCallback: (data) {
      _onGoingData = data;
    },
      queryParam: _categories()[2].queryParams
    );
  }

  void _fetchRankedManga() {
    MalAPIHelper.mediaWithCategory(false, _categories()[0].path, (nodes) {
      setState(() {
        _rankingNodesManga = nodes;
      });
    },
    dataCallback: (data) {
      _rankMangaData = data;
    },
    queryParam: {
      "ranking_type" : "all",
      "limit" : 20,
      "nsfw" : true,
      "fields" : GlobalConstant.mangaMandatoryFields,
    },
    needRank: true,
    );
  }

  void _beginFetching() {
    _fetchCategoryBasedAnime();
    _fetchRankedManga();
  }

  void _getHistory() async {
    var temp = await _history.getSearchHistory();
    setState(() {
      _searchesHistory = temp;
    });
  }

  void _deleteHistory(String search) {
    _history.delete(search);
    _getHistory();
  }

  void _fetchMedia() {
    MalAPIHelper.media(
      true,
      (nodes) {
        setState(() {
          _animeNodes = nodes;
          _isTitleUpdated = false;
        });
      },
      dataCallback: (data) {
        setState(() {
          _animeSearchData = data;
          _fetchAnimeSuccess = true;
        });
        _animeAutoRefresh = RefreshContentUtil(
          scrollController: _scrollController,
          onRefreshed: (newNodes) {
            setState(() {
              _animeNodes!.addAll(newNodes as List<MediaNode>);
            });
          },
          data: _animeSearchData,
          enabled: _isAnime
        );
      },
      beforeFetching: () => setState(() {
        _animeNodes = null;
      }),
      onFailure: () => setState(() {
        _fetchAnimeSuccess = false;
      }),
      queryParam: {
        "q" : _title,
        "limit" : 100,
        "nsfw" : true,
        "fields" : GlobalConstant.mandatoryFields
      }
    );
    MalAPIHelper.media(
        false,
        (nodes) {
          setState(() {
            _mangaNodes = nodes;
            _isTitleUpdated = false;
          });
        },
        dataCallback: (data) {
          setState(() {
            _mangaSearchData = data;
            _fetchMangaSuccess = true;
          });
          _mangaAutoRefresh = RefreshContentUtil(
              scrollController: _scrollController,
              onRefreshed: (newNodes) {
                setState(() {
                  _mangaNodes!.addAll(newNodes as List<MediaNode>);
                });
              },
              data: _mangaSearchData,
              enabled: !_isAnime
          );
        },
        beforeFetching: () => setState(() {
          _mangaNodes = null;
        }),
        onFailure: () => setState(() {
          _fetchMangaSuccess = false;
        }),
        queryParam: {
          "q" : _title,
          "limit" : 100,
          "nsfw" : true,
          "fields" : GlobalConstant.mangaMandatoryFields
        }
    );
  }

  void _deleteAllHistory(BuildContext context) {
    mShowDialog(context, "Clear all recent history?", () {
      _history.deleteAll();
      _getHistory();
    });
  }

  void _scrollListener() {
    if (!_isShowingMediaList) {
      if (_fetchAnimeSuccess) {
        setState(() {
          _fetchAnimeSuccess = false;
          _animeAutoRefresh?.detachListener();
          _animeAutoRefresh = null;
        });
      }
      if (_fetchMangaSuccess) {
        setState(() {
          _fetchMangaSuccess = false;
          _mangaAutoRefresh?.detachListener();
          _mangaAutoRefresh = null;
        });
      }
    }
  }

  void _showGenreSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => GenreSheet(
        parentContext: this.context,
      )
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(_scrollListener);
    _textEditingController = TextEditingController();
    _bottomSheetController = AnimationController(vsync: this);
    _focusNode = FocusNode();
    _history = History();
    _getHistory();
    _beginFetching();
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _bottomSheetController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
          builder: (context, constraint) {
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  leading: _isShowingMediaList || _isSearchBarOnFocus ?  IconButton(
                      onPressed: () {
                        if (_focusNode.hasFocus) {
                          _focusNode.unfocus();
                        } else {
                          if (_isSearchBarOnFocus) {
                            if (_isOnMediaListLoading) {
                              setState(() {
                                _isShowingMediaList = true;
                                _isOnMediaListLoading = false;
                              });
                            } else {
                              _scrollController.jumpTo(0);
                              _textEditingController.clear();
                              setState(() {
                                _isAnime = true;
                                _isSearchBarOnFocus = false;
                                _isShowingMediaList = false;
                                _isClearButtonVisible = false;
                              });
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.arrow_back_rounded)
                  ) : null,
                  title: Padding(
                    padding: EdgeInsets.only(
                        top: 8,
                        bottom: 8,
                        left: widget.userInfo.name.isNotEmpty ? _isShowingMediaList || _isSearchBarOnFocus ?
                        0 : 56 : 0
                    ),
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
                  bottom: my.SearchBar(
                    focusNode: _focusNode,
                    debounceTimeInMilli: 1500,
                    controller: _textEditingController,
                    canPop: !_isSearchBarOnFocus,
                    onTap: () {
                      _scrollController.jumpTo(0);
                      if (_isShowingMediaList) {
                        setState(() {
                          _isOnMediaListLoading = true;
                          _isShowingMediaList = false;
                        });
                      } else {
                        setState(() {
                          _isSearchBarOnFocus = true;
                        });
                      }
                    },
                    onChange: (value) {
                      if (value.isEmpty) {
                        setState(() {
                          _isClearButtonVisible = false;
                        });
                      } else {
                        setState(() {
                          _isClearButtonVisible = true;
                        });
                      }
                    },
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        _history.saveSearchHistory(value);
                        _getHistory();
                        setState(() {
                          _isAnime = true;
                          _isShowingMediaList = true;
                        });
                        if (_isOnMediaListLoading) {
                          setState(() {
                            _isOnMediaListLoading = false;
                          });
                        }
                        if (_title != value) {
                          setState(() {
                            _title = value;
                            _isTitleUpdated = true;
                          });
                          _fetchMedia();
                        }
                      }
                    },
                    onClear: () {
                      _textEditingController.clear();
                      setState(() {
                        _isClearButtonVisible = false;
                      });
                    },
                    onPopInvoked: (b) {
                      if (_focusNode.hasFocus) {
                        _focusNode.unfocus();
                      } else {
                        if (_isSearchBarOnFocus) {
                          if (_isOnMediaListLoading) {
                            setState(() {
                              _isShowingMediaList = true;
                              _isOnMediaListLoading = false;
                            });
                          } else {
                            _scrollController.jumpTo(0);
                            _textEditingController.clear();
                            setState(() {
                              _isAnime = true;
                              _isSearchBarOnFocus = false;
                              _isShowingMediaList = false;
                              _isClearButtonVisible = false;
                            });
                          }
                        }
                      }
                    },
                    isClearButtonVisible: _isClearButtonVisible && !_isShowingMediaList,
                    needDebounce: false,
                  ),
                ),
                !_isSearchBarOnFocus ? SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SchedulePage())
                        ),
                        child: Hero(
                          tag: "schedule",
                          child: Stack(
                            children: [
                              Container(
                                height: 80,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                      const Color.fromARGB(255, 46, 90, 136),
                                      Colors.grey.shade300
                                    ]),
                                    borderRadius: BorderRadius.circular(8)
                                ),
                              ),
                              Positioned(
                                  right: 25,
                                  child: SizedBox(
                                    height: 80,
                                    child: ClipRect(
                                      child: Opacity(
                                        opacity: 0.4,
                                        child: Transform.rotate(
                                            angle: pi / 15,
                                            child: Transform.translate(
                                              offset: const Offset(0, -20),
                                              child: const Icon(
                                                CupertinoIcons.calendar,
                                                color: Color.fromARGB(255, 46, 90, 136),
                                                size: 130,
                                              ),
                                            )
                                        ),
                                      ),
                                    ),
                                  )
                              ),
                              SizedBox(
                                height: 80,
                                child: Center(
                                  child: Text(
                                      "Anime Schedule",
                                      style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                          color: Colors.white,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.bold
                                      )
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _Grid(
                      onGenreTap: _showGenreSheet,
                      onMyListTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (innerContext) =>
                                UserList(userInfo: widget.userInfo, onProfileTap: widget.onProfileTap)
                            )
                        );
                      },
                    ),
                    RankCategory(
                        nodes: _intermediateRankingNodes,
                        isAnime: _isRankShowingAnime,
                        mediaCategory: _categories()[0],
                        gradientColors: _categories()[0].gradients,
                        initialData: _isRankShowingAnime ? _rankAnimeData : _rankMangaData,
                        onToggle: (int index) {
                          if (index == 0) {
                            if (!_isRankShowingAnime) {
                              setState(() {
                                _intermediateRankingNodes = _rankingNodes;
                                _isRankShowingAnime = true;
                              });
                            }
                          } else {
                            if (_isRankShowingAnime) {
                              setState(() {
                                _intermediateRankingNodes = _rankingNodesManga;
                                _isRankShowingAnime = false;
                              });
                            }
                          }
                        }
                    ),
                    GeneralCategory(
                      nodes: _suggestionsNodes,
                      mediaCategory: _categories()[1],
                      gradientColors: _categories()[1].gradients,
                      data: _suggestionsData,
                    ),
                    GeneralCategory(
                      nodes: _seasonalNodes,
                      mediaCategory: _categories()[2],
                      gradientColors: _categories()[2].gradients,
                      data: _onGoingData,
                    ),
                  ]),
                ) : !_isShowingMediaList ? SliverToBoxAdapter(
                    child: SearchHistory(
                      searchesHistory: _searchesHistory,
                      onTap: (string) {
                        _focusNode.unfocus();
                        _textEditingController.text = string;
                        setState(() {
                          _isAnime = true;
                          _isClearButtonVisible = true;
                          _isShowingMediaList = true;
                          if (_isOnMediaListLoading) {
                            _isOnMediaListLoading = false;
                          }
                        });
                        if (_title != string) {
                          setState(() {
                            _isTitleUpdated = true;
                            _title = string;
                          });
                          _fetchMedia();
                        }
                      },
                      onDelete: _deleteHistory,
                      onDeleteAll: () => _deleteAllHistory(context),
                    )
                ) : _isAnime ? _MediaList(
                  nodes: _animeNodes,
                  isAnime: true,
                  isShowingList: _animeNodes != null && !_isTitleUpdated,
                  scrollController: _scrollController,
                ) : _MediaList(
                  nodes: _mangaNodes,
                  isAnime: false,
                  isShowingList: _mangaNodes != null && !_isTitleUpdated,
                  scrollController: _scrollController,
                )
              ],
            );
          }
      ),
      floatingActionButton: _isShowingMediaList ? MediaToggle(
        onToggleChange: (index) {
          if (index == 0) {
            if (!_isAnime) {
              _scrollController.jumpTo(0);
              setState(() {
                _isAnime = true;
              });
            }
          } else {
            if (_isAnime) {
              _scrollController.jumpTo(0);
              setState(() {
                _isAnime = false;
              });
            }
          }
        }
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _MediaList extends StatefulWidget {
  final List<MediaNode>? nodes;
  final bool isAnime;
  final bool isShowingList;
  ScrollController? scrollController;
  RefreshContentUtil? autoRefresh;

  _MediaList({
    super.key,
    required this.nodes,
    required this.isAnime,
    required this.isShowingList,
    this.scrollController,
    this.autoRefresh
  });

  @override
  State<_MediaList> createState() => _MediaListState();
}

class _MediaListState extends State<_MediaList> {
  @override
  Widget build(BuildContext context) {
    return widget.isShowingList ? widget.nodes!.isNotEmpty ?  MMediaList(
      nodes: widget.nodes!,
      isAnime: widget.isAnime,
      scrollController: widget.scrollController,
      autoRefresh: widget.autoRefresh,
    ) : SliverFillRemaining(
      child: Center(
        child: Text(
          "No Media Found",
          style: Theme.of(context).textTheme.displaySmall,
        ),
      ),
    ) : SliverToBoxAdapter(
      child: SizedBox(
        height: MediaQuery.of(context).size.height - (kToolbarHeight + 46),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  final VoidCallback onGenreTap;
  final VoidCallback onMyListTap;

  const _Grid({
    super.key,
    required this.onGenreTap,
    required this.onMyListTap
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).width / 2,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          childAspectRatio: 1.03,
        ),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _GenreBox(
            title: "Genre",
            description: "Search by genres",
            onTap: onGenreTap,
            titleStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
            descStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Colors.white
            ),
          ),
          _MyListBox(
            title: "My List",
            description: "My media list",
            onTap: onMyListTap,
            titleStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold
            ),
            descStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Colors.white
            ),
          )
        ],
      ),
    );
  }
}

class _GenreBox extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;
  final TextStyle? titleStyle;
  final TextStyle? descStyle;

  const _GenreBox({
    super.key,
    required this.title,
    required this.description,
    required this.onTap,
    this.titleStyle,
    this.descStyle
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color.fromARGB(255, 14, 31, 64), Color.fromARGB(255, 255, 62, 157),],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight
                ),
                borderRadius: BorderRadius.circular(10)
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Transform.rotate(
                      angle: pi / 15,
                      child: Transform.translate(
                        offset: const Offset(24, 24),
                        child: const Icon(
                          CupertinoIcons.list_bullet_indent,
                          size: 90,
                          color: Color.fromARGB(200, 14, 31, 64),
                        ),
                      )
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: 10,
                  child: Transform.rotate(
                    angle: pi / 2.2,
                    child: Transform.translate(
                      offset: const Offset(0, 0),
                      child: const Icon(
                        CupertinoIcons.search,
                        size: 80,
                        color: Color.fromARGB(255, 14, 31, 64),
                      ),
                    )
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      style: titleStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16,),
                    Text(
                      description,
                      style: descStyle,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              ],
            )
        ),
      )
    );
  }
}

class _MyListBox extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;
  final TextStyle? titleStyle;
  final TextStyle? descStyle;

  const _MyListBox({
    super.key,
    required this.title,
    required this.description,
    required this.onTap,
    this.titleStyle,
    this.descStyle
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color.fromARGB(255, 94, 55, 25), Color.fromARGB(255, 136, 110, 88),],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight
                  ),
                  borderRadius: BorderRadius.circular(10)
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Stack(
                children: [
                  Positioned(
                    right: 45,
                    bottom: 0,
                    child: Transform.rotate(
                        angle: pi * 1.95,
                        child: Transform.translate(
                          offset: const Offset(0, 30),
                          child: const Icon(
                            Icons.person,
                            size: 90,
                            color: Color.fromARGB(220, 94, 55, 25),
                          ),
                        )
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Transform.rotate(
                        angle: pi / 15,
                        child: Transform.translate(
                          offset: const Offset(24, 24),
                          child: const Icon(
                            CupertinoIcons.list_bullet_indent,
                            size: 90,
                            color: Color.fromARGB(255, 94, 55, 25),
                          ),
                        )
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        style: titleStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16,),
                      Text(
                        description,
                        style: descStyle,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ],
              )
          ),
        )
    );
  }
}