import 'package:anime_gallery/model/node_with_rank.dart';
import 'package:anime_gallery/util/refresh_content_util.dart';
import 'package:anime_gallery/widgets/media_card.dart';
import 'package:anime_gallery/widgets/media_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/data.dart';
import '../model/media_node.dart';

class RankedCategoryPage extends StatefulWidget {
  final String category;
  final List<MediaNodeRanked> nodes;
  final bool isAnime;
  final String heroTag;
  final List<Color> gradientColors;

  const RankedCategoryPage({
    super.key,
    required this.category,
    required this.nodes,
    required this.isAnime,
    required this.heroTag,
    required this.gradientColors
  });

  @override
  State<RankedCategoryPage> createState() => _RankedCategoryPageState();
}

class _RankedCategoryPageState extends State<RankedCategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: kToolbarHeight * 2,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: widget.gradientColors)
              ),
              child: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(vertical: 12),
                centerTitle: true,
                title: Hero(
                  tag: widget.heroTag,
                  child: Text(
                    widget.category,
                    style: Theme.of(context).textTheme.displayMedium!
                      .copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            sliver: SliverList(
                delegate: SliverChildListDelegate(widget.nodes.map((e) {
                  return Stack(
                    children: [
                      MediaCard(
                        media: e.node,
                        isAnime: widget.isAnime
                      ),
                      Positioned(
                        left: 8,
                        bottom: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          color: e.ranking.rank == 1 ? const Color.fromARGB(255, 255, 180, 0) :
                                  e.ranking.rank == 2 ? Colors.grey :
                                   e.ranking.rank == 3 ? const Color.fromARGB(255, 205, 100, 30) :
                                   Colors.black54,
                          child: Text(
                            "#${e.ranking.rank}",
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white)
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList())
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryPage extends StatefulWidget {
  final String category;
  final List<MediaNode> nodes;
  final String heroTag;
  final List<Color> gradientColors;
  final Data referenceData;

  const CategoryPage({
    super.key,
    required this.category,
    required this.nodes,
    required this.heroTag,
    required this.gradientColors,
    required this.referenceData
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late final ScrollController _scrollController;
  late final RefreshContentUtil _autoRefresh;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _autoRefresh = RefreshContentUtil(
        scrollController: _scrollController,
        onRefreshed: (newNodes) {
          setState(() {
            widget.nodes.addAll(newNodes);
          });
        },
        data: widget.referenceData
    );
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: kToolbarHeight * 2,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: widget.gradientColors)
              ),
              child: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(vertical: 12),
                centerTitle: true,
                title: Hero(
                  tag: widget.heroTag,
                  child: Text(
                    widget.category,
                    style: Theme.of(context).textTheme.displayMedium!
                        .copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            sliver: SliverList(
                delegate: SliverChildListDelegate(widget.nodes.map((e) {
                  return MediaCard(
                    media: e,
                    isAnime: true
                  );
                }
              ).toList())
            ),
          ),
        ],
      ),
    );
  }
}