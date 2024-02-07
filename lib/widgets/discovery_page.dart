import 'dart:ui';

import 'package:anime_gallery/api/api_helper.dart';
import 'package:anime_gallery/model/node_with_rank.dart';
import 'package:anime_gallery/notifier/update_media_notifier.dart';
import 'package:anime_gallery/util/history.dart';
import 'package:anime_gallery/util/show_dialog.dart';
import 'package:anime_gallery/widgets/general_category.dart';
import 'package:anime_gallery/widgets/media_card.dart';
import 'package:anime_gallery/widgets/media_list.dart';
import 'package:anime_gallery/widgets/ranked_category.dart';
import 'package:anime_gallery/widgets/search_bar.dart' as my;
import 'package:anime_gallery/util/global_constant.dart';
import 'package:anime_gallery/widgets/search_history.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../model/data.dart';
import '../model/media_node.dart';
import '../other/media_category.dart';
import 'category_bar.dart';
import 'media_card_column.dart';

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({super.key});

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  String _title = "";
  bool _isSearchBarOnFocus = false;
  bool _isShowingMediaList = false;
  bool _isOnMediaListLoading = false;
  bool _isTitleUpdated = false;
  bool _isClearButtonVisible = false;
  bool _isRankShowingAnime = true;
  List<MediaNodeRanked> _rankingNodes = [];
  List<MediaNodeRanked> _rankingNodesManga = [];
  List<MediaNodeRanked> _intermediateRankingNodes = [];
  List<MediaNode> _suggestionsNodes = [];
  List<MediaNode> _seasonalNodes = [];
  List<String> _searchesHistory = [];
  List<MediaNode> _nodes = [];
  late final History _history;
  late final TextEditingController _textEditingController;
  late final FocusNode _focusNode;
  late final ScrollController _scrollController;
  Data _suggestionsData = Data.empty();
  Data _onGoingData = Data.empty();

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
      category: "Currently Airing",
      description: "Currently airing or publishing works",
      path: "season/${DateTime.now().year}/$season",
      gradients: gradients,
      queryParams: {
        "limit" : 20,
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
      queryParam: _categories()[0].queryParams,
      needRank: true,
    );
    MalAPIHelper.mediaWithCategory(true, _categories()[1].path, (nodes) {
      setState(() {
        _suggestionsNodes = nodes;
      });
    },
    dataCallback: (data) {
      setState(() {
        _suggestionsData = data;
      });
    },
      queryParam: _categories()[1].queryParams
    );
    MalAPIHelper.mediaWithCategory(true, _categories()[2].path, (nodes) {
      setState(() {
        _seasonalNodes = nodes;
      });
    },
    dataCallback: (data) {
      setState(() {
        _onGoingData = data;
      });
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
      queryParam: _categories()[0].queryParams,
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
          _nodes = nodes;
          _isTitleUpdated = false;
        });
      },
      queryParam: {
        "q" : _title,
        "limit" : 100,
        "fields" : GlobalConstant.mandatoryFields
      }
    );
  }

  void _deleteAllHistory(BuildContext context) {
    mShowDialog(context, "Clear all recent history?", () {
      _history.deleteAll();
      _getHistory();
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _textEditingController = TextEditingController();
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
                leading: IconButton(
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
                              _isSearchBarOnFocus = false;
                              _isShowingMediaList = false;
                              _isClearButtonVisible = false;
                            });
                          }
                        } else {
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    icon: const Icon(Icons.arrow_back_rounded)
                ),
                title: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8, right: 48),
                  child: Center(
                    child: SvgPicture.asset(
                      "images/mock-mal-logo.svg",
                      height: 120,
                      width: 120,
                    ),
                  ),
                ),
                bottom: my.SearchBar(
                  focusNode: _focusNode,
                  debounceTimeInMilli: 1500,
                  controller: _textEditingController,
                  canPop: !_isSearchBarOnFocus,
                  onTap: () {
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
                    if (_isOnMediaListLoading) {
                      setState(() {
                        _isShowingMediaList = true;
                        _isOnMediaListLoading = false;
                      });
                    } else {
                      _scrollController.jumpTo(0);
                      _textEditingController.clear();
                      setState(() {
                        _isSearchBarOnFocus = false;
                        _isShowingMediaList = false;
                        _isClearButtonVisible = false;
                      });
                    }
                  },
                  isClearButtonVisible: _isClearButtonVisible && !_isShowingMediaList,
                  needDebounce: false,
                ),
              ),
              !_isSearchBarOnFocus ? SliverList(
                delegate: SliverChildListDelegate(
                    [
                      RankCategory(
                          nodes: _intermediateRankingNodes,
                          isAnime: _isRankShowingAnime,
                          mediaCategory: _categories()[0],
                          gradientColors: _categories()[0].gradients,
                          onToggle: (int index) {
                            if (index == 0) {
                              setState(() {
                                _intermediateRankingNodes = _rankingNodes;
                                _isRankShowingAnime = true;
                              });
                            } else {
                              setState(() {
                                _intermediateRankingNodes = _rankingNodesManga;
                                _isRankShowingAnime = false;
                              });
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
                    ]
                ),
              ) : !_isShowingMediaList ? SliverToBoxAdapter(
                child:  SearchHistory(
                  searchesHistory: _searchesHistory,
                  onTap: (string) {
                    _focusNode.unfocus();
                    _textEditingController.text = string;
                    setState(() {
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
              ) : _nodes.isNotEmpty && !_isTitleUpdated ? MMediaList(nodes: _nodes, isAnime: true,)
              : SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - (kToolbarHeight + 46),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            ],
          );
        }
      )
    );
  }
}