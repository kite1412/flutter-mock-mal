import 'dart:math';

import 'package:anime_gallery/util/refresh_content_util.dart';
import 'package:anime_gallery/widgets/jikan_media_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/jikan/data.dart';
import '../model/jikan/media.dart';

class GenrePage extends StatefulWidget {
  List<JikanMedia> media;
  final bool isAnime;
  final Data initialData;
  final List<int> genres;

  GenrePage({
    super.key,
    required this.media,
    required this.isAnime,
    required this.initialData,
    required this.genres
  });

  @override
  State<GenrePage> createState() => _GenrePageState();
}

class _GenrePageState extends State<GenrePage> {
  late final ScrollController _controller;
  late final RefreshJikanContentUtil _autoRefresh;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _autoRefresh = RefreshJikanContentUtil(
      scrollController: _controller,
      onRefreshed: (newMedia) => setState(() {
        widget.media.addAll(newMedia as List<JikanMedia>);
      }),
      data: widget.initialData,
      isAnime: widget.isAnime,
      queries: {
        "sfw" : false,
        "genres" : widget.genres.join(",")
      }
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _autoRefresh.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (innerContext, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              floating: true,
              title: Row(
                children: [
                  Text(
                    "Search Result",
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(width: 4,),
                  Transform.translate(
                    offset: const Offset(0, -1),
                    child: Transform.rotate(
                      angle: pi / 2,
                      child: const Icon(
                        CupertinoIcons.search,
                        size: 32,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
          body: widget.media.isNotEmpty ? Padding(
            padding: const EdgeInsets.only(top: 8),
            child: MediaQuery.removePadding(
                removeTop: true,
                context: context,
                child: JikanMediaList(
                  media: widget.media,
                  showHeartIcon: false,
                  isAnime: widget.isAnime,
                  controller: _controller,
                  showBroadcastTime: false,
                )
            ),
          ) :
          Center(
            child: Text(
              "No media found",
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
        )
    );
  }
}