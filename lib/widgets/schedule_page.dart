import 'dart:math';

import 'package:anime_gallery/util/mock_media.dart';
import 'package:anime_gallery/view_model/schedule_view_model.dart';
import 'package:anime_gallery/view_model/view_model.dart';
import 'package:anime_gallery/widgets/media_list.dart';
import 'package:anime_gallery/widgets/jikan_media_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../model/jikan/media.dart';

class SchedulePage extends StatefulWidget {

  const SchedulePage({
    super.key,
  });

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late final ScheduleViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = ScheduleViewModel();
  }

  @override
  void dispose() {
    super.dispose();
    viewModel.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ViewModelProvider(
        viewModel: viewModel,
        builder: (vm) => NestedScrollView(
          controller: vm.scrollController,
            headerSliverBuilder: (context, innerScrollIsScrolled) => [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                floating: true,
                expandedHeight: (kToolbarHeight * 2),
                leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white,)
                ),
                flexibleSpace: SizedBox(
                  // height: (kToolbarHeight * 2) + kTextTabBarHeight ,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              const Color.fromARGB(255, 46, 90, 136),
                              Colors.grey.shade300
                            ]),
                          ),
                        ),
                        Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: ClipRect(
                                child: Opacity(
                                    opacity: 0.4,
                                    child: Transform.translate(
                                        offset: const Offset(0, -15),
                                        child: Transform.rotate(
                                          angle: pi / 15,
                                          child: const Icon(
                                            CupertinoIcons.calendar,
                                            size: 180,
                                            color: Color.fromARGB(255, 46, 90, 136),
                                          ),
                                        )
                                    )
                                )
                            )
                        ),
                        FlexibleSpaceBar(
                            expandedTitleScale: 1.3,
                            titlePadding: const EdgeInsets.all(0),
                            title: Hero(
                                tag: "schedule",
                                child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Text(
                                        "Schedule",
                                        style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    )
                                )
                            )
                        ),
                      ],
                    ),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverPersistentHeaderDelegate(
                  selectedDay: vm.selectedDay,
                  onTap: (day) {
                    vm.setDay(day);
                    vm.onPageChangedByTap(day.index);
                  },
                  viewModel: vm
                ),
                pinned: true,
              )
            ],
            body: MediaQuery.removePadding(
              removeTop: true,
              context: context,
              child: PageView(
                controller: vm.pageController,
                onPageChanged: vm.onPageChange,
                children: [
                  _DayMedia(
                    day: Day.monday,
                    media: vm.monday,
                    viewModel: vm
                  ),
                  _DayMedia(
                    day: Day.tuesday,
                    media: vm.tuesday,
                    viewModel: vm
                  ),
                  _DayMedia(
                    day: Day.wednesday,
                    media: vm.wednesday,
                    viewModel: vm
                  ),
                  _DayMedia(
                    day: Day.thursday,
                    media: vm.thursday,
                    viewModel: vm
                  ),
                  _DayMedia(
                    day: Day.friday,
                    media: vm.friday,
                    viewModel: vm
                  ),
                  _DayMedia(
                    day: Day.saturday,
                    media: vm.saturday,
                    viewModel: vm
                  ),
                  _DayMedia(
                    day: Day.sunday,
                    media: vm.sunday,
                    viewModel: vm
                  ),
                ],
              )
            )
        ),
      )
    );
  }
}

enum Day { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

extension DayExtension on Day {
  static Day fromDateTime(DateTime dateTime) {
    int day = dateTime.weekday - 1;
    Day? mDay;
    switch (day) {
      case 0:
        mDay = Day.monday;
        break;
      case 1:
        mDay = Day.tuesday;
        break;
      case 2:
        mDay = Day.wednesday;
        break;
      case 3:
        mDay = Day.thursday;
        break;
      case 4:
        mDay = Day.friday;
        break;
      case 5:
        mDay = Day.saturday;
        break;
      case 6:
        mDay = Day.sunday;
        break;
    }
    return mDay!;
  }
}

class _SliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Day selectedDay;
  final void Function(Day) onTap;
  final ScheduleViewModel viewModel;

  _SliverPersistentHeaderDelegate({
    required this.selectedDay,
    required this.onTap,
    required this.viewModel
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _TabBar(
      selectedDay: selectedDay,
      onTap: onTap,
      viewModel: viewModel,
    );
  }

  @override
  double get maxExtent => kTextTabBarHeight;

  @override
  double get minExtent => kTextTabBarHeight;

  @override
  bool shouldRebuild(covariant _SliverPersistentHeaderDelegate oldDelegate) => true;
}

class _TabBar extends StatefulWidget implements PreferredSizeWidget {
  final Day selectedDay;
  final void Function(Day) onTap;
  final ScheduleViewModel viewModel;

  _TabBar({
    super.key,
    required this.selectedDay,
    required this.onTap,
    required this.viewModel
  });

  @override
  State<_TabBar> createState() => _TabBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);
}

class _TabBarState extends State<_TabBar> {
  String _cap(String word) {
    return word[0].toUpperCase() + word.substring(1);
  }

  Widget _dayBar(BuildContext context, Day day) {
    return VisibilityDetector(
        key: widget.viewModel.tabBarKeys[day.index],
        onVisibilityChanged: (info) {
          if (widget.selectedDay == day) {
            if (info.visibleFraction < 1.0 && widget.viewModel.isAutoJumpEnabled) {
              widget.viewModel.jumpToSelectedBar(context, day.index);
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: GestureDetector(
            onTap: () => widget.onTap(day),
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: day == widget.selectedDay ? [
                          Colors.grey.shade400, const Color.fromARGB(255, 46, 90, 136)
                        ] : [Colors.transparent, Colors.transparent]
                    ),
                    border: Border.all(
                      color: day == widget.selectedDay ? Colors.transparent :
                      MediaQuery.platformBrightnessOf(context) == Brightness.light ?
                      Colors.grey.shade600 : Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(100)
                ),
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                child: Center(
                  child: Text(
                    _cap(day.name),
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: day == widget.selectedDay ? Colors.white :
                        MediaQuery.platformBrightnessOf(context) == Brightness.light ?
                        Colors.grey.shade600 : Colors.grey,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                )
            ),
          ),
        )
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.viewModel.decideBarsWidth();
      widget.viewModel.decideDay(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kTextTabBarHeight,
      color: Theme.of(context).colorScheme.background,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ListView.separated(
        controller: widget.viewModel.tabBarController,
        itemBuilder: (innerContext, index) =>
          _dayBar(context, widget.viewModel.days[index]),
        separatorBuilder: (context, index) => const SizedBox(width: 6,),
        itemCount: widget.viewModel.days.length,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}

class _DayMedia extends StatefulWidget {
  final Day day;
  final List<JikanMedia>? media;
  final ScheduleViewModel viewModel;

  const _DayMedia({
    super.key,
    required this.day,
    required this.media,
    required this.viewModel
  });

  @override
  State<_DayMedia> createState() => _DayMediaState();
}

class _DayMediaState extends State<_DayMedia> {
  @override
  void initState() {
    super.initState();
    if (widget.media == null) {
      widget.viewModel.fetchMedia(widget.day);
    }
  }

  @override
  Widget build(BuildContext context) {
    return JikanMediaList(media: widget.media, showHeartIcon: true, isAnime: true);
  }
}