import 'package:anime_gallery/widgets/media_card.dart';
import 'package:flutter/cupertino.dart';

import '../model/media_node.dart';

class MMediaList extends StatelessWidget {
  final List<MediaNode> nodes;
  final bool isAnime;

  const MMediaList({
    super.key,
    required this.nodes,
    required this.isAnime
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        children: nodes.map((e) => MediaCard(mediaNode: e, isAnime: isAnime)).toList(),
      ),
    );
  }
}