import 'package:anime_gallery/api/api_helper.dart';
import 'package:anime_gallery/util/global_constant.dart';
import 'package:anime_gallery/widgets/media_detail.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../model/media_node.dart';
import '../util/info_bar.dart';

typedef AppBarListener = void Function(ScrollController);

class MediaList extends StatefulWidget {
  const MediaList({super.key, required this.isAnime, required this.appBarListener});
  final bool isAnime;
  final AppBarListener appBarListener;

  @override
  State<MediaList> createState() => _MediaListState();
}

class _MediaListState extends State<MediaList> {
  final Logger _log = Logger();
  bool _loadingState = true;
  bool _isAbleToRefresh = true;
  bool _isShowIndicator = true;
  bool _isAtMax = false;
  String _nextPage = "";
  List<MediaNode> _nodes = [];
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _loadingState = true;
    });
    _fetchMedia();
    _log.i("from init state");
    scrollController.addListener(_scrollListener);
    scrollController.addListener(() {
      widget.appBarListener(scrollController);
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  void _fetchMedia() {
    MalAPIHelper.media(
      widget.isAnime,
      (nodes) {
        _retainPreviousAddNew(nodes);
        setState(() {
          _loadingState = false;
        });
        _log.i(_nodes.isEmpty);
      },
      queryParam: {
        "q" : "High school",
        "limit" : 70,
        "fields" : widget.isAnime ? GlobalConstant.mandatoryFields : GlobalConstant.mangaMandatoryFields
      },
      dataCallback: (data) {
        final next = data.paging.next;
        if (next != null) {
          _nextPage = next;
          if (next.isEmpty) {
            setState(() {
              _isShowIndicator = false;
              _isAtMax = true;
            });
          }
        }
      }
    );
  }

  void _scrollListener() {
    var belowContents = scrollController.position.extentAfter;
    var viewportDimension = scrollController.position.viewportDimension;
    if (belowContents < (viewportDimension * 3) && _isAbleToRefresh && !_isAtMax) {
      _refresh();
    }
  }
  
  void _refresh() {
    setState(() {
      _isAbleToRefresh = false;
    });
    MalAPIHelper.prevNextPage(_nextPage, (nodes) {
      _retainPreviousAddNew(nodes);
      Future.delayed(const Duration(milliseconds: 300)).then((value) {
        setState(() {
          _isAbleToRefresh = true;
        });
      });
    }, (paging) {
         final next = paging.next;
         if (next != null) {
           _nextPage = next;
           if (next.isEmpty) {
             setState(() {
              _isShowIndicator = false;
              _isAtMax = true;
             });
           }
         }
         _log.i(_nextPage);
         _log.i(_nodes.isEmpty);
       }
    );
  }

  void _retainPreviousAddNew(List<MediaNode> newNodes) {
    if (newNodes.isEmpty) {
      return;
    }
    List<MediaNode> temp = [];
    temp.addAll(_nodes);
    temp.addAll(newNodes);
    setState(() {
      _nodes = List.of(temp);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<MediaCard> nodes = _nodes.map((e) {
      return MediaCard(mediaNode: e, isAnime: widget.isAnime,);
    }).toList();
    return _loadingState ? const Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      children: [
        CircularProgressIndicator()
      ],
    ) : _isNodeEmpty(context, nodes);
  }

  Widget _isNodeEmpty(BuildContext context, List<MediaCard> nodes) {
    List<Widget> contents = [];
    contents.addAll(nodes);
    if (_isShowIndicator) {
      contents.add(
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Center(
            child: Wrap(
              children: [
                CircularProgressIndicator()
              ],
            ),
          ),
        ),
      );
    }
    return nodes.isNotEmpty ? ListView.builder(
      itemBuilder: (context, index) {
        return contents[index];
      },
      itemCount: contents.length,
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      controller: scrollController,
    ) : Center(child: Text("No Media Found", style: Theme.of(context).textTheme.displaySmall,),);
  }
}

class MediaCard extends StatefulWidget {
  const MediaCard({super.key, required this.mediaNode, required this.isAnime});
  final MediaNode mediaNode;
  final bool isAnime;

  @override
  State<MediaCard> createState() => _MediaCardState();
}

class _MediaCardState extends State<MediaCard> {
  final _heroTag = const Uuid().v4();
  var _isContentSensitive = false;

  Widget _showWarning(BuildContext context) {
    if (widget.mediaNode.genres != null) {
      String warningType = "";
      for (var value in widget.mediaNode.genres!) {
        switch(value.name) {
          case "Ecchi":
            warningType = "Ecchi";
            break;
          case "Erotica":
            warningType = "Erotica";
            break;
          case "Hentai":
            warningType = "Hentai";
            break;
        }
      }
      if (warningType.isNotEmpty) {
        _isContentSensitive = true;
        return InfoBar.infoBar(
          context,
          warningType != "Hentai" ? Colors.pink : Colors.black,
          warningType,
          borderRadius: 0
        );
      } else {
        return const SizedBox();
      }
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle? tStyle = Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold);
    TextStyle? cStyle = Theme.of(context).textTheme.bodySmall;
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Card(
        child: InkResponse(
          splashColor: Colors.grey.shade800,
          highlightShape: BoxShape.rectangle,
          splashFactory: InkSplash.splashFactory,
          containedInkWell: true,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10)
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
               builder: (context) {
                 return MediaDetail(
                   media: widget.mediaNode,
                   isAnime: widget.isAnime,
                   heroTag: _heroTag,
                   isContentSensitive: _isContentSensitive,
                );
              }
            )
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: _heroTag,
                    child: Image(
                      image: Image.network(widget.mediaNode.mediaPicture.medium).image,
                      height: 140,
                      width: 110,
                      fit: BoxFit.cover,
                    ),
                  ),
                Positioned(
                    right: 0,
                    child: Container(
                      color: Colors.black54,
                      padding: const EdgeInsets.only(right: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 12, color: Colors.white,),
                          Text(
                            InfoBar.assertNullNumField(widget.mediaNode.mean).toString(),
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white),),
                        ],
                      ),
                    )
                  ),
                  Positioned(
                    bottom: 0,
                    child: _showWarning(context),
                  ),
                ],
              ),
              _cardInfo(context, tStyle, cStyle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardInfo(BuildContext context, TextStyle? tStyle, TextStyle? cStyle) {
    return Expanded(
      child: SizedBox(
        height: 140,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.mediaNode.title,
                style: tStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4,),
              Text(
                InfoBar.assertNullStringField(widget.mediaNode.synopsis),
                style: cStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 4,
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: InfoBar.bars(widget.mediaNode, context)..add(
                    widget.mediaNode.userMediaStatus != null ?
                      Expanded(
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          children: [_mediaStatusBar(context)],
                        )
                      ) : const SizedBox()
                  )
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  Widget _mediaStatusBar(BuildContext context) {
    var userStatus = widget.mediaNode.userMediaStatus!;
    Color conColor = Colors.transparent;
    String status = "";
    switch (userStatus.status) {
      case "watching":
        conColor = const Color.fromARGB(255, 70, 180, 90);
        status = "Watching";
        break;
      case "completed":
        conColor = const Color.fromARGB(255, 46, 90, 136);
        status = "Completed";
        break;
      case "on_hold":
        conColor = const Color.fromARGB(255, 255, 191, 0);
        status = "On Hold";
        break;
      case "dropped":
        conColor = const Color.fromARGB(255, 140, 0, 0);
        status = "Dropped";
        break;
      case "plan_to_watch":
        conColor = Colors.grey.shade500;
        status = "Plan To Watch";
        break;
    }
    return InfoBar.infoBar(context, conColor, status);
  }
}