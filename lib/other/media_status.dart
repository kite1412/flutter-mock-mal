
import 'package:flutter/material.dart';

class MediaStatus {
  final int index;
  final String name;
  final String jsonName;
  final Color statusColor;
  final List<Color> gradientColors;

  MediaStatus({
    required this.index,
    required this.name,
    required this.jsonName,
    required this.statusColor,
    required this.gradientColors
  });

  static List<MediaStatus> status(bool isAnime, {bool includeAll = false}) => [
    if (includeAll) MediaStatus(
        index: 0,
        name: "All",
        jsonName: "",
        statusColor: const Color.fromARGB(255, 100, 100, 100),
        gradientColors: [const Color.fromARGB(255, 80, 80, 80), const Color.fromARGB(255, 60, 60, 60)]
    ),
    MediaStatus(
      index: includeAll ? 1 : 0,
      name: isAnime ? "Watching" : "Reading",
      jsonName: isAnime ? "watching" : "reading",
      statusColor: const Color.fromARGB(255, 0, 140, 0),
      gradientColors: [const Color.fromARGB(255, 0, 140, 0), const Color.fromARGB(255, 0, 90, 0)]
    ),
    MediaStatus(
      index: includeAll ? 2 : 1,
      name: "Completed",
      jsonName: "completed",
      statusColor: const Color.fromARGB(255, 46, 110, 160),
      gradientColors: [const Color.fromARGB(255, 46, 110, 160), const Color.fromARGB(255, 0, 50, 100)]
    ),
    MediaStatus(
      index: includeAll ? 3 : 2,
      name: "On Hold",
      jsonName: "on_hold",
      statusColor: const Color.fromARGB(255, 255, 191, 0),
      gradientColors: [const Color.fromARGB(255, 255, 191, 0), const Color.fromARGB(255, 255, 130, 0)]
    ),
    MediaStatus(
      index: includeAll ? 4 : 3,
      name: "Dropped",
      jsonName: "dropped",
      statusColor: const Color.fromARGB(255, 160, 0, 0),
      gradientColors: [const Color.fromARGB(255, 180, 0, 0), const Color.fromARGB(255, 100, 0, 0)]
    ),
    MediaStatus(
      index: includeAll ? 5 : 4,
      name: isAnime ? "Plan to Watch" : "Plan to Read",
      jsonName: isAnime ? "plan_to_watch" : "plan_to_read",
      statusColor: Colors.grey.shade600,
      gradientColors: [Colors.grey.shade500, Colors.grey.shade700]
    ),
  ];

  static String? mapStatus(MediaStatusConst? status) {
    String? statusString;
    if (status  != null) {
      switch (status.index) {
        case 0:
          statusString = "watching";
          break;
        case 1:
          statusString =  "reading";
          break;
        case 2:
          statusString = "completed";
          break;
        case 3:
          statusString = "on_hold";
          break;
        case 4:
          statusString = "dropped";
          break;
        case 5:
          statusString = "plan_to_watch";
          break;
        case 6:
          statusString = "plan_to_read";
          break;
        default:
          return "unidentified_status";
      }
    }
    return statusString;
  }
}

enum MediaStatusConst {
  watching,
  reading,
  completed,
  onHold,
  dropped,
  planToWatch,
  planToRead,
}