import 'package:anime_gallery/api/mal/api_helper.dart';
import 'package:anime_gallery/util/global_constant.dart';
import 'package:anime_gallery/widgets/media_detail.dart';
import 'package:anime_gallery/widgets/media_display_large.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../model/jikan/media.dart';

class JikanMediaList extends StatefulWidget {
  final List<JikanMedia>? media;
  final bool showHeartIcon;
  final bool isAnime;
  final bool showBroadcastTime;
  ScrollController? controller;

  JikanMediaList({
    super.key,
    required this.media,
    required this.showHeartIcon,
    required this.isAnime,
    required this.showBroadcastTime,
    this.controller
  });

  @override
  State<JikanMediaList> createState() => _JikanMediaListState();
}

class _JikanMediaListState extends State<JikanMediaList> {
  int _tappedMediaId = -1;

  void onMediaTap(BuildContext context, JikanMedia media, String heroTag, bool isContentSensitive) {
    setState(() {
      _tappedMediaId = media.malId!;
    });
    MalAPIHelper.fetchMediaById(
      media.malId!,
      widget.isAnime,
      (node) {
        setState(() {
          _tappedMediaId = -1;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaDetail(
              media: node,
              isAnime: widget.isAnime,
              heroTag: heroTag,
              isContentSensitive: isContentSensitive
            )
          )
        );
      },
      fields: widget.isAnime ? GlobalConstant.mandatoryFields :
        GlobalConstant.mangaMandatoryFields
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.media != null ? GridView(
      controller: widget.controller,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: MediaQuery.sizeOf(context).height / 2.6,
          mainAxisSpacing: 4
        ),
        children: widget.media!.map((e) => MediaDisplayLarge(
          media: e,
          isTransitioning: _tappedMediaId == e.malId,
          onTap: (media, isContentSensitive) =>
            onMediaTap(context, media, media.malId.toString(), isContentSensitive),
          showHeartIcon: widget.showHeartIcon,
          showBroadcastTime: widget.showBroadcastTime,
        )).toList()
    ) : Center(
      child: SpinKitCircle(
        color: MediaQuery.platformBrightnessOf(context) == Brightness.light ?
        Colors.black : Colors.white,
      ),
    );
  }
}