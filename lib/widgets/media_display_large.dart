import 'dart:math';

import 'package:anime_gallery/model/jikan/media.dart';
import 'package:anime_gallery/util/info_bar.dart';
import 'package:anime_gallery/util/time_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../model/jikan/resource.dart';

class MediaDisplayLarge extends StatelessWidget {
  final JikanMedia media;
  final bool isTransitioning;
  final void Function(JikanMedia, bool) onTap;
  final bool showHeartIcon;
  final bool showBroadcastTime;

  const MediaDisplayLarge({
    super.key,
    required this.media,
    required this.isTransitioning,
    required this.onTap,
    required this.showHeartIcon,
    required this.showBroadcastTime
  });

  bool isContentSensitive() {
    bool isSensitive = false;
    for (var e in media.genres ?? <Resource>[]) {
      if (e.name == "Ecchi" || e.name == "Erotica" || e.name == "Hentai") {
        isSensitive = true;
      }
    }
    return isSensitive;
  }

  String _adjust(String string) {
    String s = "";
    if (string.length == 2
        || string.length == 3
        || (string.length > 3 && !string.contains(" ") && !string.contains("-"))) {
      s = string.toLowerCase();
    } else if (string.contains(" ")) {
      final split = string.split(" ");
      s = split.join("_").toLowerCase();
    } else if (string.contains("-")) {
      final split = string.split("-");
      s = split.join("_").toLowerCase();
    }
    return s;
  }

  String _adjustStatus(String status) {
    String adjusted = status;
    if (status == "Finished Airing") {
      adjusted = "Finished";
    } else if (status == "Currently Airing") {
      adjusted = "Airing";
    }
    return adjusted;
  }



  @override
  Widget build(BuildContext context) {
    final double imageHeight = MediaQuery.sizeOf(context).height / 3.2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: GestureDetector(
        onTap: () => onTap(media, isContentSensitive()),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Hero(
                      tag: media.malId.toString(),
                      child: Image.network(
                        media.images?.jpg?.largeImageUrl ??
                          media.images?.jpg?.imageUrl ??
                            "https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty-300x240.jpg",
                        fit: BoxFit.cover,
                        height: imageHeight,
                        width: double.infinity,
                      ),
                    )
                ),
                Positioned(
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                      color: Colors.black45,
                    ),
                    padding: const EdgeInsets.only(right: 4, left: 2, bottom: 2),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.white,
                        ),
                        Text(
                          "${media.score ?? "N/A"}",
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.white
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                if (((media.score ?? 0) >= 8.0) && showHeartIcon) Transform.translate(
                  offset: const Offset(-6, -6),
                  child: Transform.rotate(
                      angle: pi * 1.9,
                      child: Icon(
                        CupertinoIcons.heart_solid,
                        color: !isTransitioning ?
                        const Color.fromARGB(255, 200, 0, 0) : Colors.black26,
                        size: 32,
                      )
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(170, 0, 0, 0),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      )
                    ),
                    child: Row(
                      children: [
                        InfoBar.infoBar(
                            context,
                            InfoBar.mediaTypeColor(_adjust(media.type!)),
                            InfoBar.mapField(media.type!),
                            fontSize: 11
                        ),
                        const SizedBox(width: 4,),
                        InfoBar.infoBar(
                            context,
                            InfoBar.statusColor(_adjust(media.status!)),
                            _adjustStatus(media.status!),
                            fontSize: 11
                        ),
                        if (isContentSensitive()) Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: InfoBar.infoBar(
                                context,
                                Colors.pink,
                                "18+",
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ),
                if (media.broadcast?.time != null && showBroadcastTime) Positioned(
                  bottom: 30,
                  child: GestureDetector(
                    onTap: !(TimeUtil.needAdjustment(media.broadcast!.getTime()) == 1 || TimeUtil.needAdjustment(media.broadcast!.getTime()) == -1) ?
                      null : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            TimeUtil.needAdjustment(media.broadcast!.getTime()) == -1 ?
                              "Aired the day before" : TimeUtil.needAdjustment(media.broadcast!.getTime()) == 1 ?
                                "Aired the day after" : "",
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.white
                            ),
                          ),
                          duration: const Duration(milliseconds: 1200),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        )
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                      decoration: const BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5)
                          )
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.clock,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 2,),
                          Text(
                            TimeUtil.adjustToLocal(media.broadcast!.getTime()),
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Colors.white,
                                fontSize: 12
                            ),
                          ),
                          if (TimeUtil.needAdjustment(media.broadcast!.getTime()) == -1) const Row(
                            children: [
                              SizedBox(width: 2,),
                              Icon(
                                CupertinoIcons.arrowtriangle_down_fill,
                                color: Colors.red,
                                size: 12,
                              )
                            ],
                          ),
                          if (TimeUtil.needAdjustment(media.broadcast!.getTime()) == 1)  const Row(
                            children: [
                              SizedBox(width: 2,),
                              Icon(
                                CupertinoIcons.arrowtriangle_up_fill,
                                color: Colors.green,
                                size: 12,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ),
                if (isTransitioning) AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  decoration: BoxDecoration(
                      color: isTransitioning ? Colors.black54 : Colors.transparent,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  height: imageHeight,
                  child: Center(
                    child: isTransitioning ? const SpinKitCircle(color: Colors.white,) : const SizedBox(),
                  ),
                ),
              ],
            ),
            Text(
              media.titles![0].title!,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}