
import 'dart:ui';

import 'package:anime_gallery/other/media_category.dart';
import 'package:anime_gallery/widgets/media_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:uuid/uuid.dart';

import '../model/media_node.dart';
import 'media_detail.dart';

// Categories that share similarities, such as using MediaNode,
// no additional display like showing score, rank, and no manga option
// e.g suggestions and on airing category
class GeneralCategory extends StatefulWidget {
  List<MediaNode> nodes;
  final MediaCategory mediaCategory;
  final List<Color> gradientColors;

  GeneralCategory({
    super.key,
    required this.nodes,
    required this.mediaCategory,
    required this.gradientColors,
  });

  @override
  State<GeneralCategory> createState() => _GeneralCategoryState();
}

class _GeneralCategoryState extends State<GeneralCategory> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(8),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 3.5,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: widget.gradientColors),
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: widget.nodes.isNotEmpty ? Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.mediaCategory.category,
                        style: Theme.of(context).textTheme.displayMedium!
                            .copyWith(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.white
                        ),
                      ),
                      const SizedBox(width: 4,),
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Icon(Icons.arrow_forward_rounded, color: Colors.white,),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8) ,
                child: ListView.builder(
                  itemExtent: 100,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    String heroTag = const Uuid().v4();
                    return Padding(
                        padding: const EdgeInsets.only(left: 4, right: 4),
                        child: MediaDisplay(
                          media: widget.nodes[index],
                          heroTag: heroTag,
                          onMediaUpdate: (updatedMedia) {
                            final List<MediaNode> updated = widget.nodes.map((e) {
                              if (e.id == updatedMedia.id) {
                                return updatedMedia;
                              } else {
                                return e;
                              }
                            }).toList();
                            setState(() {
                              widget.nodes = updated;
                            });
                          },
                        )
                    );
                  },
                  itemCount: widget.nodes.length,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.mediaCategory.description,
                style: Theme.of(context).textTheme.displaySmall!
                    .copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.white
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ) : BackdropFilter(
          filter: ImageFilter.blur(sigmaY: 3, sigmaX: 3),
          child: Center(
            child: SpinKitThreeBounce(
              color: Colors.grey.shade800,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}