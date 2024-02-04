import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_helper.dart';
import '../model/media_node.dart';
import '../notifier/update_media_notifier.dart';
import '../util/global_constant.dart';
import 'media_detail.dart';

// For MediaNode display, aka suggestions and on airing
class MediaDisplay extends StatefulWidget {
  MediaNode media;
  final String heroTag;
  final void Function(MediaNode) onMediaUpdate;

  MediaDisplay({
    super.key,
    required this.media,
    required this.heroTag,
    required this.onMediaUpdate
  });

  @override
  State<MediaDisplay> createState() => _MediaDisplayState();
}

class _MediaDisplayState extends State<MediaDisplay> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final updatedMediaId = Provider.of<GlobalNotifier>(context).updatedMediaId;
    if (updatedMediaId != -1 && widget.media.id == updatedMediaId) {
      MalAPIHelper.fetchMediaById(
          updatedMediaId,
          true,
          (updatedMedia) {
            setState(() {
              widget.media = updatedMedia;
            });
            widget.onMediaUpdate(widget.media);
            Provider.of<GlobalNotifier>(context, listen: false).updatedMediaId = -1;
          },
          fields: GlobalConstant.mandatoryFields
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return MediaDetail(
                media: widget.media,
                isAnime: true,
                heroTag: widget.heroTag,
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
                    tag: widget.heroTag,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: Image.network(
                        widget.media.mediaPicture.medium,
                        height: 100,
                        width: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              )
          ),
          Text(
            widget.media.title,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.white
            ),
          )
        ],
      ),
    );
  }
}