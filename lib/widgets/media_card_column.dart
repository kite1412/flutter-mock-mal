import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../api/mal/api_helper.dart';
import '../model/mal/media_node.dart';
import '../util/global_constant.dart';
import 'media_card.dart';

class MediaListColumn extends StatefulWidget {
  final bool isAnime;
  final String mediaTitle;

  const MediaListColumn({
    super.key,
    required this.isAnime,
    required this.mediaTitle,
  });

  @override
  State<MediaListColumn> createState() => _MediaListColumnState();
}

class _MediaListColumnState extends State<MediaListColumn> {
  final Logger _log = Logger();
  bool _loadingState = true;
  bool _isAbleToRefresh = true;
  bool _isShowIndicator = true;
  bool _isAtMax = false;
  String _nextPage = "";
  List<MediaNode> _nodes = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      _loadingState = true;
    });
    _fetchMedia();
    _log.i("from init state");
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
          "q" : widget.mediaTitle,
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
    });
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
      return MediaCard(media: e, isAnime: widget.isAnime,);
    }).toList();
    return _loadingState ? SizedBox(
      height: MediaQuery.of(context).size.height - (kToolbarHeight + 46),
      width: MediaQuery.of(context).size.width,
      child: const Align(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
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
    return nodes.isNotEmpty ? Container(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Column(children: nodes,),
    ) : Center(child: Text("No Media Found", style: Theme.of(context).textTheme.displaySmall,),);
  }
}