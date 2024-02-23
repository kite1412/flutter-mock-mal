import 'package:anime_gallery/api/jikan/api_helper.dart';
import 'package:anime_gallery/view_model/view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../model/jikan/media.dart';
import '../widgets/schedule_page.dart';

class ScheduleViewModel extends ViewModel {
  ScheduleViewModel() {
    init();
  }

  bool isAutoJumpEnabled = true;
  Day selectedDay = Day.monday;
  List<JikanMedia>? monday;
  List<JikanMedia>? tuesday;
  List<JikanMedia>? wednesday;
  List<JikanMedia>? thursday;
  List<JikanMedia>? friday;
  List<JikanMedia>? saturday;
  List<JikanMedia>? sunday;
  final Logger _log = Logger();
  final List<Day> days = [
    Day.monday,
    Day.tuesday,
    Day.wednesday,
    Day.thursday,
    Day.friday,
    Day.saturday,
    Day.sunday,
  ];
  final List<GlobalKey> tabBarKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];
  final List<double> barsWidth = [];
  final List<double> lengthToIndex = [];
  late final PageController pageController;
  late final ScrollController tabBarController;
  late final ScrollController scrollController;

  void _updateMedia(Day day, List<JikanMedia>? newMedia) {
    if (day.index == 0) {
      setState(() {
        monday = newMedia;
      });
    } else if (day.index == 1) {
      setState(() {
        tuesday = newMedia;
      });
    } else if (day.index == 2) {
      setState(() {
        wednesday = newMedia;
      });
    } else if (day.index == 3) {
      setState(() {
        thursday = newMedia;
      });
    } else if (day.index == 4) {
      setState(() {
        friday = newMedia;
      });
    } else if (day.index == 5) {
      setState(() {
        saturday = newMedia;
      });
    } else if (day.index == 6) {
      setState(() {
        sunday = newMedia;
      });
    }
  }

  void _loadNewMedia(Day day, List<JikanMedia>? newMedia) {
    if (day.index == 0) {
      setState(() {
        monday!.addAll(newMedia!);
      });
    } else if (day.index == 1) {
      setState(() {
        tuesday!.addAll(newMedia!);
      });
    } else if (day.index == 2) {
      setState(() {
        wednesday!.addAll(newMedia!);
      });
    } else if (day.index == 3) {
      setState(() {
        thursday!.addAll(newMedia!);
      });
    } else if (day.index == 4) {
      setState(() {
        friday!.addAll(newMedia!);
      });
    } else if (day.index == 5) {
      setState(() {
        saturday!.addAll(newMedia!);
      });
    } else if (day.index == 6) {
      setState(() {
        sunday!.addAll(newMedia!);
      });
    }
  }

  void fetchMedia(Day day) {
    JikanApiHelper.getAnimeSchedules(
        {
          "page" : 1,
          "filter" : day.name,
          "sfw" : false
        },
        (media) {
          _updateMedia(day, media.data);
        },
        true,
        (media) {
          _loadNewMedia(day, media.data);
        },
    );
  }

  void setDay(Day newDay) => setState(() {
    selectedDay = newDay;
  });

  void setSelectedDayIndex(Day newValue) => setState(() {
    selectedDay = newValue;
  });

  void setIsAutoJumpEnabled(bool newValue) => setState(() {
    isAutoJumpEnabled = newValue;
  });

  void onPageChange(int index) => setState(() {
    selectedDay = days[index];
    VisibilityDetectorController.instance.forget(tabBarKeys[index]);
    scrollToTop();
  });

  void onPageChangedByTap(int index) {
    onPageChange(index);
    pageController.jumpToPage(index);
    setIsAutoJumpEnabled(true);
    VisibilityDetectorController.instance.forget(tabBarKeys[index]);
    scrollToTop();
  }

  void scrollToTop() {
    if (scrollController.offset >= kToolbarHeight) {
      scrollController.jumpTo(kToolbarHeight);
    } else {
      scrollController.jumpTo(0);
    }
  }

  void decideBarsWidth() {
    for (var i in tabBarKeys.indexed) {
      if (i.$1 != tabBarKeys.length - 1) {
        // 6 is separator's width of the ListView
        barsWidth.add(i.$2.currentContext!.size!.width + 6);
      } else {
        barsWidth.add(i.$2.currentContext!.size!.width);
      }
      if (i.$1 != 0) {
        lengthToIndex.add(lengthToIndex[i.$1 - 1] + barsWidth[i.$1]);
      } else {
        lengthToIndex.add(barsWidth[0]);
      }
    }
  }

  void jumpToSelectedBar(BuildContext context, int currentIndex) async {
    try {
      tabBarController.animateTo(
          _offset(currentIndex, MediaQuery.sizeOf(context).width),
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear
      );
    } catch (_) {}
  }

  double _offset(
      int itemIndex,
      double screenWidth
      ) {
    final lengthTo = lengthToIndex[itemIndex];
    // jump on left side
    if (lengthTo <= screenWidth) {
      if (itemIndex == 0) {
        return 0;
      } else {
        return lengthToIndex[itemIndex - 1] - 8 - 8;
      }
    }
    // jump on right side
    else {
      // 8 is from padding value of the ListView
      final offset = lengthTo - screenWidth + 8 + 8;
      return offset;
    }
  }

  void decideDay(BuildContext context) async {
    final DateTime date = DateTime.now();
    final today = DayExtension.fromDateTime(date);
    setDay(today);
    jumpToSelectedBar(context, today.index);
    onPageChangedByTap(today.index);
  }

  void init() {
    pageController = PageController()
      ..addListener(() {
        setIsAutoJumpEnabled(true);
      });
    tabBarController = ScrollController()
      ..addListener(() {
        setIsAutoJumpEnabled(false);
      });
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
    tabBarController.dispose();
    scrollController.dispose();
  }
}