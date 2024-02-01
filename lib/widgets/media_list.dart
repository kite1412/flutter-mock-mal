import 'package:anime_gallery/widgets/media_card.dart';
import 'package:flutter/cupertino.dart';

import '../model/media_node.dart';

class MMediaList extends StatefulWidget {
  List<MediaNode> nodes;
  final bool isAnime;
  final bool? isSliver;
  ScrollController? scrollController;

  MMediaList({
    super.key,
    required this.nodes,
    required this.isAnime,
    this.isSliver,
    this.scrollController
  });

  @override
  State<MMediaList> createState() => _MMediaListState();
}

class _MMediaListState extends State<MMediaList> {

  @override
  Widget build(BuildContext context) {
    return widget.isSliver != null && !widget.isSliver! ? Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView(
        controller: widget.scrollController,
        children: widget.nodes.map((e) => MediaCard(
          media: e,
          isAnime: widget.isAnime,
          informOnUpdate: (newMedia) {
            final List<MediaNode> updated = widget.nodes.map((e) {
              if (e.id == newMedia.id) {
                return newMedia;
              }
              return e;
            }).toList();
            setState(() {
              widget.nodes = updated;
            });
          },
        )).toList(),
      ),
    ) : SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      sliver: SliverList(
          delegate: SliverChildListDelegate(
              widget.nodes.map((e) => MediaCard(
                media: e,
                isAnime: widget.isAnime,
                informOnUpdate: (newMedia) {
                  final List<MediaNode> updated = widget.nodes.map((e) {
                    if (e.id == newMedia.id) {
                      return newMedia;
                    }
                    return e;
                  }).toList();
                  setState(() {
                    widget.nodes = updated;
                  });
                },
              )).toList()
          )
      ),
    );
  }
}