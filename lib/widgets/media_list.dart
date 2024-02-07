import 'package:anime_gallery/other/update_type.dart';
import 'package:anime_gallery/widgets/media_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../model/media_node.dart';
import '../notifier/update_media_notifier.dart';

class MMediaList extends StatefulWidget {
  List<MediaNode> nodes;
  final bool isAnime;
  final bool? isSliver;
  ScrollController? scrollController;
  void Function(List<MediaNode>)? newNodes;

  MMediaList({
    super.key,
    required this.nodes,
    required this.isAnime,
    this.isSliver,
    this.scrollController,
    this.newNodes
  });

  @override
  State<MMediaList> createState() => _MMediaListState();
}

class _MMediaListState extends State<MMediaList> {
  final Logger _log = Logger();

  List<MediaNode> _doWithUpdate(MediaNode updatedMedia, UpdateType type) {
    List<MediaNode> updatedNodes = [];
    // search page and 'all' page in user list
    if (type.index == 0) {
      for (var value in widget.nodes) {
        if (value.id == updatedMedia.id) {
          updatedNodes.add(updatedMedia);
        } else {
          updatedNodes.add(value);
        }
      }
    } else {
      // every page of user list except 'all' page
      updatedNodes = widget.nodes;
      updatedNodes.removeWhere((element) => updatedMedia.id == element.id);
    }
    return updatedNodes;
  }

  @override
  Widget build(BuildContext context) {
    return widget.isSliver != null && !widget.isSliver! ? Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        controller: widget.scrollController,
        itemBuilder: (context, index) {
          return MediaCard(
            media: widget.nodes[index],
            isAnime: widget.isAnime,
            informOnUpdate: (newMedia, type) {
              final nodes = widget.nodes.map((e) {
                if (e.id == newMedia.id) {
                  return newMedia;
                }
                return e;
              }).toList();
              setState(() {
                widget.nodes = nodes;
              });
            },
          );
        },
      itemCount: widget.nodes.length,
      ),
    ) : SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      sliver: SliverList(
          delegate: SliverChildListDelegate(
              widget.nodes.map((e) => MediaCard(
                media: e,
                isAnime: widget.isAnime,
                informOnUpdate: (newMedia, type) {
                  final nodes = widget.nodes.map((e) {
                    if (e.id == newMedia.id) {
                      return newMedia;
                    }
                    return e;
                  }).toList();
                  setState(() {
                    widget.nodes = nodes;
                  });
                }
              )).toList()
          )
      ),
    );
  }
}