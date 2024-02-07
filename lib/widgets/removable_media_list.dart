import 'package:anime_gallery/notifier/update_media_notifier.dart';
import 'package:anime_gallery/util/mock_media.dart';
import 'package:anime_gallery/widgets/media_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../model/media_node.dart';
import '../notifier/removable_list_notifier.dart';
import '../other/media_status.dart';

// for solely user's media list purpose
class RemovableMediaList extends StatefulWidget {
  List<MediaNode> nodes;
  final bool isAnime;
  final MediaStatus status;

  RemovableMediaList({
    super.key,
    required this.nodes,
    required this.isAnime,
    required this.status
  });


  @override
  State<RemovableMediaList> createState() => _RemovableMediaListState();
}

class _RemovableMediaListState extends State<RemovableMediaList> {
  final Logger _log = Logger();
  final GlobalKey<AnimatedListState> _key = GlobalKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentIndex = Provider.of<RemovableListNotifier>(context, listen: false).currentIndex;
    final needToRemove = Provider.of<RemovableListNotifier>(context).removeCurrentItem;
    if (currentIndex != -1 && needToRemove && widget.status.jsonName.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        widget.nodes.removeAt(currentIndex);
        _key.currentState?.removeItem(currentIndex, (context, animation) {
          return SizeTransition(
            sizeFactor: animation,
            child: FadeTransition(
              opacity: animation,
              child: MediaCard(
                  media: Provider.of<RemovableListNotifier>(context, listen: false).currentMedia,
                  isAnime: widget.isAnime,
              ),
            )
          );
        },
          duration: const Duration(milliseconds: 1000)
        );
        Provider.of<RemovableListNotifier>(context, listen: false).removeCurrentItem = false;
        Provider.of<RemovableListNotifier>(context, listen: false).currentIndex = -1;
      });
    } else {
      if (widget.status.jsonName.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if (mounted) {
            Provider.of<RemovableListNotifier>(context, listen: false).removeCurrentItem = false;
            Provider.of<RemovableListNotifier>(context, listen: false).currentIndex = -1;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _key,
      initialItemCount: widget.nodes.length,
      itemBuilder: (context, index, animation) {
        return MediaCard(
            media: widget.nodes[index],
            isAnime: widget.isAnime,
            onTap: (media) {
              Provider.of<RemovableListNotifier>(context, listen: false).currentIndex = index;
              Provider.of<RemovableListNotifier>(context, listen: false).statusPage = widget.status.jsonName;
              Provider.of<RemovableListNotifier>(context, listen: false).currentMedia = media;
            }
        );
      },
    );
  }
}