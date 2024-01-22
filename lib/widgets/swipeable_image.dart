import 'package:anime_gallery/model/media_picture.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';


class SwipeableImage extends StatefulWidget {
  const SwipeableImage({
    super.key,
    required this.width,
    required this.pictures,
  });

  final double width;
  final List<MediaPicture> pictures;

  @override
  State<SwipeableImage> createState() => _SwipeableImageState();
}

class _SwipeableImageState extends State<SwipeableImage> {
  final Logger _log = Logger();
  int _selectedIndex = 0;

  List<Widget> _pictureIndicators() {
    List<Widget> indicators = [];
    for (int i = 0; i < widget.pictures.length; i++) {
      indicators.add(
        Padding(
          padding: const EdgeInsets.only(right: 1, left: 1),
          child: _PointIndicator(index: i, selectedIndex: _selectedIndex),
        )
      );
    }
    return indicators;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: widget.width,
          height: widget.width * 1.5,
          child: PageView(
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            scrollDirection: Axis.horizontal,
            children: widget.pictures.map((picture) {
              return Padding(
                  padding: const EdgeInsets.only(right: 4, left: 4),
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    clipBehavior: Clip.antiAlias,
                    child: Image(
                      image: Image.network(picture.medium).image,
                      fit: BoxFit.cover,
                    ),
                  )
              );
            }).toList(),
          ),
        ),
        Positioned(
          bottom: 3,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _pictureIndicators(),
          ),
        ),
      ],
    );
  }
}

class _PointIndicator extends StatefulWidget {
  final int index;
  final int selectedIndex;

  const _PointIndicator({required this.index, required this.selectedIndex});

  @override
  State<_PointIndicator> createState() => _PointIndicatorState();
}

class _PointIndicatorState extends State<_PointIndicator> {
  Color _color() {
    if (widget.index == widget.selectedIndex) {
      return Colors.black;
    }
    return Colors.black45;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      width: 8,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: _color(),
      ),
      clipBehavior: Clip.antiAlias,
    );
  }
}