
import 'package:flutter/material.dart';

import '../model/media_node.dart';

class InfoBar {

  InfoBar._();

  static String assertNullStringField(String? field) {
    return field == null || field.isEmpty ? "No Content" : field;
  }

  static String assertNullNumField(num? field) {
    return field != null ? field.toString() : "N/A" ;
  }

  static String _mapStatus(String status) {
    String end = "";
    switch(status) {
      case "finished_airing":
      case "finished":
        end =  "Finished";
        break;
      case "currently_airing":
        end = "Airing";
        break;
      case "currently_publishing":
        end = "Publishing";
        break;
      case "not_yet_aired":
      case "not_yet_published":
        end = "Not yet aired";
        break;
      default:
        end = "No status";
    }
    return end;
  }

  static Color _mediaTypeColor(String mediaType) {
    Color color  = Colors.transparent;
    switch(mediaType) {
      case "unknown":
      case "cm":
        color = Colors.grey.shade400;
        break;
      case "tv" :
      case "manga" :
        color = const Color.fromARGB(255, 46, 90, 136);
        break;
      case "ova":
      case "one_shot":
        color = const Color.fromARGB(255, 255, 180, 0);
        break;
      case "movie":
      case "light_novel":
        color = const Color.fromARGB(255, 255, 105, 97);
        break;
      case "ona":
      case "oel":
        color = const Color.fromARGB(255, 255, 220, 0);
        break;
      case "special":
      case "manhwa":
        color = const Color.fromARGB(255, 90, 90, 90);
        break;
      case "music":
      case "doujinshi":
        color = Colors.pink;
        break;
      case "tv_special":
      case "manhua":
        color = const Color.fromARGB(255, 140, 140, 140);
        break;
      case "pv":
        color = Colors.grey.shade600;
        break;
    }
    return color;
  }

  static Color _statusColor(String status) {
    Color color = Colors.transparent;
    switch(status) {
      case "finished_airing":
      case "finished":
        color = const Color.fromARGB(255, 46, 90, 180);
        break;
      case "currently_airing":
      case "currently_publishing":
        color = const Color.fromARGB(255, 70, 180, 90);
        break;
      case "not_yet_aired":
      case "not_yet_published":
        color = Colors.grey;
        break;
    }
    return color;
  }

  static Widget infoBar(
      BuildContext context,
      Color containerColor,
      String text,
      {double borderRadius = 4}
  ) {
    return Container(
      padding: const EdgeInsets.all(3),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: containerColor,
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      ),
      child: Text(
        _mapField(text),
        style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white),
      ),
    );
  }

  static Widget infoBarWidget(
      BuildContext context,
      Color containerColor,
      Widget widget,
      {double borderRadius = 4}
  ) {
    return Container(
      padding: const EdgeInsets.all(3),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: containerColor,
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      ),
      child: widget,
    );
  }

  static String _mapField(String field) {
    if (field.contains("_")) {
      final strings = field.split("_");
      return "${strings[0][0].toUpperCase()}${strings[0].substring(1)}"
          " ${strings[1][0].toUpperCase()}${strings[1].substring(1)}";
    } else if (field == "cm") {
      return "Commercial";
    } else if (field.length == 3 || field.length == 2) {
      return field.toUpperCase();
    }
    return field[0].toUpperCase() + field.substring(1);
  }

  static List<Widget> bars(
    MediaNode media,
    BuildContext context,
    {bool showWarning = false}
  ) {
    return [
      infoBar(
        context,
        _mediaTypeColor(assertNullStringField(media.mediaType)),
        _mapField(assertNullStringField(media.mediaType))
      ),
      const SizedBox(width: 8,),
      infoBar(
        context,
        _statusColor(assertNullStringField(media.status)),
        _mapStatus(assertNullStringField(media.status))
      ),
      if (showWarning) Row(
        children: [
          const SizedBox(width: 8,),
          infoBar(
              context,
              Colors.pink,
              "18+"
          ),
        ],
      ),
    ];
  }
}