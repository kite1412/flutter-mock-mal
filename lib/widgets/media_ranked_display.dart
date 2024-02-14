import 'package:anime_gallery/api/mal/api_helper.dart';
import 'package:anime_gallery/model/mal/node_with_rank.dart';
import 'package:anime_gallery/notifier/global_notifier.dart';
import 'package:anime_gallery/util/global_constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'media_detail.dart';

class MediaRankedDisplay extends StatefulWidget {
  MediaNodeRanked media;
  final bool isAnime;
  final String heroTag;
  final void Function(MediaNodeRanked) onMediaUpdate;

  MediaRankedDisplay({
    super.key,
    required this.media,
    required this.isAnime,
    required this.heroTag,
    required this.onMediaUpdate
  });

  @override
  State<MediaRankedDisplay> createState() => _MediaRankedDisplayState();
}

class _MediaRankedDisplayState extends State<MediaRankedDisplay> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final updatedMediaId = Provider.of<GlobalNotifier>(context).updatedMediaId;
    if (updatedMediaId != -1 && widget.media.node.id == updatedMediaId) {
      MalAPIHelper.fetchMediaById(
        updatedMediaId,
        widget.isAnime,
        (updatedMedia) {
          setState(() {
            widget.media = MediaNodeRanked(updatedMedia, widget.media.ranking);
          });
          widget.onMediaUpdate(widget.media);
          Provider.of<GlobalNotifier>(context, listen: false).updatedMediaId = -1;
        },
        fields: widget.isAnime ? GlobalConstant.mandatoryFields : GlobalConstant.mangaMandatoryFields
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return MediaDetail(
                media: MediaNodeRanked.toMediaNode(widget.media),
                isAnime: widget.isAnime,
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
                        widget.media.node.mediaPicture.medium,
                        height: 100,
                        width: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                          color: widget.media.ranking.rank == 1 ? const Color.fromARGB(255, 255, 180, 0) :
                                   widget.media.ranking.rank == 2 ? Colors.grey :
                                     widget.media.ranking.rank == 3 ? const Color.fromARGB(255, 205, 100, 30) :
                                       Colors.black54,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(8))
                      ),
                      padding: const EdgeInsets.only(left: 2, right: 2),
                      child: Text(
                          "#${widget.media.ranking.rank}",
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white)),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black54,
                      padding: const EdgeInsets.only(right: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 10, color: Colors.white,),
                          Text(
                            "${widget.media.node.mean}",
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
          ),
          Text(
            widget.media.node.title,
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