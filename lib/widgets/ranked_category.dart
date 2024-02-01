import 'dart:ui';

import 'package:anime_gallery/model/node_with_rank.dart';
import 'package:anime_gallery/notifier/update_media_notifier.dart';
import 'package:anime_gallery/other/media_category.dart';
import 'package:anime_gallery/widgets/media_ranked_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:uuid/uuid.dart';

class RankCategory extends StatefulWidget {
  List<MediaNodeRanked> nodes;
  final bool isAnime;
  final MediaCategory mediaCategory;
  final List<Color> gradientColors;
  final void Function(int) onToggle;

  RankCategory({
    super.key,
    required this.nodes,
    required this.isAnime,
    required this.mediaCategory,
    required this.gradientColors,
    required this.onToggle
  });

  @override
  State<RankCategory> createState() => _RankCategoryState();
}

class _RankCategoryState extends State<RankCategory> {
  int _initialIndex = 0;

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
                ToggleSwitch(
                  totalSwitches: 2,
                  onToggle: (int? index) {
                    setState(() {
                      _initialIndex = index!;
                    });
                    widget.onToggle(index!);
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
                  initialLabelIndex: _initialIndex,
                ),
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
                    return MediaRankedDisplay(
                      media: widget.nodes[index],
                      isAnime: widget.isAnime,
                      heroTag: heroTag,
                      onMediaUpdate: (updatedMedia) {
                        final List<MediaNodeRanked> updated = widget.nodes.map((e) {
                          if (e.node.id == updatedMedia.node.id) {
                            return updatedMedia;
                          } else {
                            return e;
                          }
                        }).toList();
                        setState(() {
                          widget.nodes = updated;
                        });
                      },
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