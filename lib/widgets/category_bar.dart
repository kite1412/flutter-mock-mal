import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:uuid/uuid.dart';

import '../model/media_node.dart';
import '../model/node_with_rank.dart';
import '../util/media_category.dart';
import 'media_detail.dart';

class CategoryBar extends StatefulWidget {
  final MediaCategory mediaCategory;
  final List<Color> gradientColors;
  final List<dynamic> nodes;
  final bool isRanking;
  final OnToggle? onToggle;

  const CategoryBar({
    super.key,
    required this.mediaCategory,
    required this.gradientColors,
    required this.nodes,
    required this.isRanking,
    required this.onToggle
  });

  @override
  State<CategoryBar> createState() => _CategoryBarState();
}

class _CategoryBarState extends State<CategoryBar> {
  int integer = 0;
  bool _isMediaNode(int index) {
    if (widget.nodes is List<MediaNode>) {
      return true;
    } else {
      return false;
    }
  }

  String _image(int index) {
    if (_isMediaNode(index)) {
      return widget.nodes[index].mediaPicture.medium;
    }
    return widget.nodes[index].node.mediaPicture.medium;
  }

  String _title(int index) {
    if (_isMediaNode(index)) {
      return widget.nodes[index].title;
    }
    return widget.nodes[index].node.title;
  }

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.isRanking ? ToggleSwitch(
                  totalSwitches: 2,
                  onToggle: (int? index) {
                    setState(() {
                      integer = index!;
                    });
                    widget.onToggle!(index);
                  },
                  changeOnTap: false,
                  minWidth: 28,
                  minHeight: 20,
                  labels: const ["A", "M"],
                  customTextStyles: const [
                    TextStyle(fontWeight: FontWeight.bold)
                  ],
                  inactiveBgColor: Colors.white24,
                  inactiveFgColor: Colors.black,
                  activeBgColor: [
                    widget.gradientColors.last,
                    if (widget.gradientColors.length > 2) widget.gradientColors[(widget.gradientColors.length - 1) ~/ 2],
                    widget.gradientColors.first,
                  ],
                  activeFgColor: Colors.white,
                  dividerColor: widget.gradientColors.last,
                  animate: true,
                  animationDuration: 250,
                  initialLabelIndex: integer,
                ) : const SizedBox(width: 1,),
                Row(
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
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) {
                                return MediaDetail(
                                    media: widget.nodes is List<MediaNode> ?
                                    widget.nodes[index] : MediaNodeRanked.toMediaNode(widget.nodes[index]),
                                    isAnime: true,
                                    heroTag: heroTag,
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
                                        tag: heroTag,
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                                          child: Image.network(
                                            _image(index),
                                            height: 100,
                                            width: 70,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      if (widget.nodes is List<MediaNodeRanked>) Positioned(
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(8))
                                          ),
                                          padding: const EdgeInsets.only(left: 2, right: 2),
                                          child: Text(
                                              "#${widget.nodes[index].ranking.rank}",
                                              style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white)),
                                        ),
                                      ),
                                      if (widget.nodes is List<MediaNodeRanked>) Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          color: Colors.black54,
                                          padding: const EdgeInsets.only(right: 2),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.star_rounded, size: 10, color: Colors.white,),
                                              Text(
                                                "${widget.nodes[index].node.mean}",
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
                                _title(index),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Colors.white
                                ),
                              )
                            ],
                          ),
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