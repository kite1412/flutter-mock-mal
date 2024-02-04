import 'package:anime_gallery/other/update_type.dart';
import 'package:anime_gallery/widgets/media_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../model/media_node.dart';
import '../notifier/update_media_notifier.dart';

class MMediaList extends StatefulWidget {
  List<MediaNode> nodes;
  final bool isAnime;
  final bool? isSliver;
  ScrollController? scrollController;
  bool isCardDismissible;
  void Function(List<MediaNode>)? newNodes;

  MMediaList({
    super.key,
    required this.nodes,
    required this.isAnime,
    this.isSliver,
    this.scrollController,
    this.isCardDismissible = false,
    this.newNodes
  });

  @override
  State<MMediaList> createState() => _MMediaListState();
}

class _MMediaListState extends State<MMediaList> {

  List<MediaNode> _doWithUpdate(MediaNode newMedia, UpdateType type) {
    List<MediaNode> updatedNodes = [];
    // search page and 'all' page in user list
    if (type.index == 0) {
      for (var value in widget.nodes) {
        if (value.id == newMedia.id) {
          updatedNodes.add(newMedia);
        } else {
          updatedNodes.add(value);
        }
      }
    } else {
      // every page of user list except 'all' page
      widget.nodes.removeWhere((element) => newMedia.id == element.id);
      updatedNodes = widget.nodes;
    }
    return updatedNodes;
  }

  @override
  Widget build(BuildContext context) {
    return widget.isSliver != null && !widget.isSliver! ? Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView(
        controller: widget.scrollController,
        children: widget.nodes.map((e) => MediaCard(
          media: e,
          isAnime: widget.isAnime,
          isDismissible: widget.isCardDismissible,
          informOnUpdate: (updatedMedia, updateType) {
            Provider.of<GlobalNotifier>(context, listen: false).statusNeedUpdate = updatedMedia.userMediaStatus?.status ?? "*";
            final List<MediaNode> updatedNodes = _doWithUpdate(updatedMedia, updateType);
            widget.newNodes?.call(updatedNodes);
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
                isDismissible: widget.isCardDismissible,
                informOnUpdate: (updatedMedia, updateType) {
                  final List<MediaNode> updatedNodes = _doWithUpdate(updatedMedia, updateType);
                  setState(() {
                    widget.nodes = updatedNodes;
                  });
                },
              )).toList()
          )
      ),
    );
  }
}