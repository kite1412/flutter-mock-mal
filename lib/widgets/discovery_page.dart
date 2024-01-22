import 'dart:ui';

import 'package:anime_gallery/api/api_helper.dart';
import 'package:anime_gallery/model/node_with_rank.dart';
import 'package:anime_gallery/widgets/media_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:uuid/uuid.dart';

import '../model/media_node.dart';

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({super.key});

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  List<MediaNodeRanked> _rankingNodes = [];
  List<MediaNode> _suggestionsNodes = [];
  List<MediaNode> _seasonalNodes = [];
  final List<String> _mandatoryFields = [
    "synopsis",
    "mean",
    "media_type",
    "status",
    "genres",
    "num_scoring_users",
    "rank",
    "popularity",
    "my_list_status"
  ];

  List<dynamic> categoryNodes(int index) {
    switch(index) {
      case 0:
        return _rankingNodes;
      case 1:
        return _suggestionsNodes;
      case 2:
        return _seasonalNodes;
      default:
        return [];
    }
  }

  _MediaCategory _seasonalCategory() {
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
    return _MediaCategory(
      index: 2,
      category: "Currently Airing",
      description: "Currently airing or publishing works",
      path: "season/${DateTime.now().year}/$season",
      gradients: gradients,
      queryParams: {
        "limit" : 20,
        "fields" : _mandatoryFields,
      }
    );
  }

  List<_MediaCategory> _categories() => [
    _MediaCategory(
      index: 0,
      category: "Rank",
      description: "Works ranking",
      path: "ranking",
      gradients: const [
        Color.fromARGB(255, 240, 89, 65),
        Color.fromARGB(255, 190, 49, 68),
        Color.fromARGB(255, 135, 65, 68),
        Color.fromARGB(255, 34, 9, 44),
      ],
      queryParams: {
        "ranking_type" : "all",
        "limit" : 20,
        "fields" : _mandatoryFields,
      }
    ),
    _MediaCategory(
      index: 1,
      category: "Suggestions",
      description: "Suggestions based on your history",
      path: "suggestions",
      gradients: const [
        Color.fromARGB(255, 194, 217, 255),
        Color.fromARGB(255, 142, 143, 250),
        Color.fromARGB(255, 46, 90, 136)
      ],
      queryParams: {
        "limit" : 20,
        "fields" : _mandatoryFields,
      }
    ),
    _seasonalCategory(),
  ];

  @override
  void initState() {
    super.initState();
    MalAPIHelper.mediaWithCategory(true, _categories()[0].path, (nodes) {
        setState(() {
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
        queryParam: _categories()[1].queryParams
    );
    MalAPIHelper.mediaWithCategory(true, _categories()[2].path, (nodes) {
        setState(() {
           _seasonalNodes = nodes;
        });
      },
        queryParam: _categories()[2].queryParams
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8, right: 40),
              child: Center(
                child: Image.asset("images/mal-logo-full.png", height: 120, width: 120,),
              ),
            ),
            bottom: _SearchBar(),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              _categories().map((category) {
                return _Bar(
                  mediaCategory: category,
                  gradientColors: category.gradients,
                  nodes: categoryNodes(category.index),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 16, left: 16, bottom: 2),
      width: preferredSize.width,
      height: preferredSize.height,
      child: Card(
        color: Colors.black54,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8, top: 6, bottom: 6, right: 4),
              child: Icon(Icons.search_rounded, color: Colors.white),
            ),
            const SizedBox(width: 6,),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: TextField(
                  cursorColor: Theme.of(context).textTheme.bodyMedium!.color!,
                  decoration: const InputDecoration(
                      border: InputBorder.none
                  ),
                ),
              )
            )
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(46.0);
}

class _Bar extends StatelessWidget {
  final _MediaCategory mediaCategory;
  final List<Color> gradientColors;
  final List<dynamic> nodes;

  const _Bar({
    super.key,
    required this.mediaCategory,
    required this.gradientColors,
    required this.nodes,
  });

  bool _isMediaNode(int index) {
    if (nodes is List<MediaNode>) {
      return true;
    } else {
      return false;
    }
  }

  String _image(int index) {
    if (_isMediaNode(index)) {
      return nodes[index].mediaPicture.medium;
    }
    return nodes[index].node.mediaPicture.medium;
  }

  String _title(int index) {
    if (_isMediaNode(index)) {
      return nodes[index].title;
    }
    return nodes[index].node.title;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(8),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 3.5,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: nodes.isNotEmpty ? Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  mediaCategory.category,
                  style: Theme.of(context).textTheme.displayMedium!
                      .copyWith(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                ),
                const SizedBox(width: 4,),
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(Icons.arrow_forward_rounded,),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8) ,
                child: ListView.builder(
                  itemExtent: 100,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    String heroTag = const Uuid().v4();
                    return Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) {
                            return MediaDetail(
                              media: nodes is List<MediaNode> ?
                                nodes[index] : MediaNodeRanked.toMediaNode(nodes[index]),
                              isAnime: true,
                              heroTag: heroTag,
                              isContentSensitive: false
                            );
                          })
                        ),
                        child: Column(
                          children: [
                            Material(
                                elevation: 10,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(8))
                                ),
                                child: Stack(
                                  children: [
                                    Hero(
                                      tag: heroTag,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                                        child: Image.network(
                                          _image(index),
                                          height: 100,
                                          width: 70,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    if (nodes is List<MediaNodeRanked>) Positioned(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(8))
                                        ),
                                        padding: const EdgeInsets.only(left: 2, right: 2),
                                        child: Text(
                                          "#${nodes[index].ranking.rank}",
                                          style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white)),
                                      ),
                                    ),
                                    if (nodes is List<MediaNodeRanked>) Positioned(
                                      bottom: 0,
                                      right: 0,
                                        child: Container(
                                          color: Colors.black54,
                                          padding: const EdgeInsets.only(right: 2),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.star_rounded, size: 10, color: Colors.white,),
                                              Text(
                                                "${nodes[index].node.mean}",
                                                style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                            ),
                            Text(
                              _title(index),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      )
                    );
                  },
                  itemCount: nodes.length,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                mediaCategory.description,
                style: Theme.of(context).textTheme.displaySmall!
                    .copyWith(fontStyle: FontStyle.italic),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ) : BackdropFilter(
          filter: ImageFilter.blur(sigmaY: 3, sigmaX: 3),
          child: Center(
            child: SpinKitThreeBounce(
              color: Colors.grey.shade800,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class _MediaCategory {
  final int index;
  final String category;
  final String description;
  final String path;
  final List<Color> gradients;
  final Map<String, dynamic> queryParams;

  const _MediaCategory({
    required this.index,
    required this.category,
    required this.description,
    required this.path,
    required this.gradients,
    required this.queryParams
  });
}