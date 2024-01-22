import 'package:anime_gallery/api/api_helper.dart';
import 'package:anime_gallery/widgets/swipeable_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/media_node.dart';
import '../model/media_picture.dart';
import '../util/info_bar.dart';

class MediaDetail extends StatefulWidget {
  const MediaDetail({
    super.key,
    required this.media,
    required this.isAnime,
    required this.heroTag,
    required this.isContentSensitive
  });
  final MediaNode media;
  final bool isAnime;
  final String heroTag;
  final bool isContentSensitive;

  @override
  State<MediaDetail> createState() => _MediaDetailState();
}

class _MediaDetailState extends State<MediaDetail> {
  MediaNode media = MediaNode.empty();
  List<MediaPicture> pictures = [];
  late final Widget fabIcon;

  @override
  void initState() {
    super.initState();
    pictures.add(widget.media.mediaPicture);
    MalAPIHelper.fetchMediaById(
      widget.media.id,
      widget.isAnime,
      (media) {
        setState(() {
          this.media = media;
        });
        if (media.pictures != null) {
          media.pictures!.removeWhere((picture) {
            return pictures[0].medium == picture.medium;
          });
          setState(() {
            pictures = List.of(pictures)..addAll(media.pictures!);
          });
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraint) {
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              pinned: true,
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: (constraint.maxWidth / 2.2) * 1.5,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("Score", style: Theme.of(context).textTheme.displaySmall,),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          size: 38,
                                        ),
                                        const SizedBox(width: 4,),
                                        Text(
                                          "${widget.media.mean ??= 0}",
                                          style: Theme.of(context).textTheme.displayMedium!.copyWith(fontStyle: FontStyle.italic),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("Members", style: TextStyle(color: Colors.grey.shade700),),
                                    Text(
                                      NumberFormat.decimalPattern().format(widget.media.numScoringUsers ??= 0),
                                      style: Theme.of(context).textTheme.displaySmall!.copyWith(fontStyle: FontStyle.italic),
                                    ),
                                    const SizedBox(height: 2,),
                                    Text("Rank", style: TextStyle(color: Colors.grey.shade700),),
                                    Row(
                                      children: [
                                        Icon(Icons.numbers_rounded, size: 24, color: Colors.grey.shade700,),
                                        Text(
                                          NumberFormat.decimalPattern().format(widget.media.rank ??= 0),
                                          style: Theme.of(context).textTheme.displaySmall!.copyWith(fontStyle: FontStyle.italic),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2,),
                                    Text("Popularity", style: TextStyle(color: Colors.grey.shade700),),
                                    Text(
                                      NumberFormat.decimalPattern().format(widget.media.popularity ??= 0),
                                      style: Theme.of(context).textTheme.displaySmall!.copyWith(fontStyle: FontStyle.italic),
                                    ),
                                    const SizedBox(height: 8,),
                                    Row(children: InfoBar.bars(widget.media, context, showWarning: widget.isContentSensitive))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Hero(
                          tag: widget.heroTag,
                          child: SwipeableImage(
                              width: constraint.maxWidth / 2.2,
                              pictures: pictures
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                        child: Text(
                          widget.media.title,
                          style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {

        },
        child: _fabIcon(),
      ),
    );
  }

  Widget _fabIcon() {
    Color color = Colors.white;
    return const SizedBox();
  }
}