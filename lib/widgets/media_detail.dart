import 'package:anime_gallery/api/api_helper.dart';
import 'package:anime_gallery/model/alternative_titles.dart';
import 'package:anime_gallery/model/update_media.dart';
import 'package:anime_gallery/model/user_media_status.dart';
import 'package:anime_gallery/notifier/removable_list_notifier.dart';
import 'package:anime_gallery/notifier/update_media_notifier.dart';
import 'package:anime_gallery/util/global_constant.dart';
import 'package:anime_gallery/widgets/edit_media_page.dart';
import 'package:anime_gallery/widgets/swipeable_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import '../model/media_node.dart';
import '../model/media_picture.dart';
import '../util/info_bar.dart';

class MediaDetail extends StatefulWidget {
  const MediaDetail({
    super.key,
    required this.media,
    required this.isAnime,
    required this.heroTag,
    required this.isContentSensitive
  });
  final MediaNode media;
  final bool isAnime;
  final String heroTag;
  final bool isContentSensitive;

  @override
  State<MediaDetail> createState() => _MediaDetailState();
}

class _MediaDetailState extends State<MediaDetail> {
  MediaNode _media = MediaNode.empty();
  List<MediaPicture> _pictures = [];
  Color _fabColor = Colors.black;
  String _synopsis = "";
  bool _isAbleExpandSynopsis = false;
  bool _isShowingFullSynopsis = false;
  bool _enableDismissal = false;
  String _calledFromPage = "*";
  final Logger _log = Logger();
  late final PageController _pageController;

  Widget _fabIcon() {
    IconData icon = CupertinoIcons.add;
    if (_media.userMediaStatus != null) {
      icon = Icons.edit_note_rounded;
    }
    return Icon(icon, color: Colors.white, size: 44,);
  }

  void _decideFabColor(UserMediaStatus? mediaStatus) {
    if (mediaStatus != null) {
      switch(mediaStatus.status) {
        case "watching":
          setState(() {
            _fabColor = const Color.fromARGB(255, 70, 180, 90);
          });
          break;
        case "completed":
          setState(() {
            _fabColor = const Color.fromARGB(255, 46, 90, 136);
          });
          break;
        case "on_hold":
          setState(() {
            _fabColor = const Color.fromARGB(255, 255, 191, 0);
          });
          break;
        case "dropped":
          setState(() {
            _fabColor = const Color.fromARGB(255, 140, 0, 0);
          });
          break;
        case "plan_to_watch":
          setState(() {
            _fabColor = Colors.grey.shade500;
          });
          break;
      }
    } else {
      setState(() {
        _fabColor = Colors.black;
      });
    }
  }

  void _cutSynopsis() {
    String? synopsis = widget.media.synopsis;
    if (synopsis == null || synopsis.isEmpty) {
      setState(() {
        synopsis = "";
      });
      return;
    } else if (_synopsisWords(synopsis).length <= 50) {
      setState(() {
        _synopsis = synopsis!;
      });
      return;
    }
    _isAbleExpandSynopsis = true;
    if (_isShowingFullSynopsis) {
      setState(() {
        _synopsis = _synopsisWords(synopsis!).join(" ");
      });
      _log.i("synopsis expanded");
    } else {
      List<String> synopsisWords = _synopsisWords(synopsis);
      int newlineIndex = synopsisWords.indexWhere((element) => element.contains("\n"));
      if (newlineIndex != -1 && newlineIndex < 50 && newlineIndex >= 30) {
        _log.i("new paragraph found");
        setState(() {
          _synopsis = "${synopsisWords.getRange(0, newlineIndex).join(" ")} "
              "${_trimAfterNewline(synopsisWords[newlineIndex])}";
        });
      } else {
        setState(() {
          _synopsis = "${synopsisWords.getRange(0, 50).join(" ")}...";
        });
      }
    }
  }

  void _showHideSynopsis() {
    setState(() {
      _isShowingFullSynopsis = !_isShowingFullSynopsis;
    });
    _cutSynopsis();
  }

  List<String> _synopsisWords(String synopsis) {
    return synopsis.split(" ");
  }

  String _trimAfterNewline(String string) {
    return string.split("\n")[0];
  }

  TextStyle _detailsTitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!;
  }

  TextStyle _detailsStyle(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ?
      Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey.shade400)
        : Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey.shade800);
  }

  void _onPopInvoked(bool b) {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.linear
    );
  }

  SnackBar _snackBar(String text) {
    return SnackBar(
      duration: const Duration(milliseconds: 500),
      content: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Colors.white
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  void _checkDismissal() {
    if (_enableDismissal) {
      Provider.of<RemovableListNotifier>(context, listen: false).removeCurrentItem = true;
      Provider.of<GlobalNotifier>(context, listen: false).currentSessionAlreadyUpdated = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _log.i(widget.heroTag);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _calledFromPage = Provider.of<RemovableListNotifier>(context, listen: false).statusPage;
      });
      Provider.of<RemovableListNotifier>(context, listen: false).statusPage = "*";
    });
    _log.i("media detail init");
    _media = widget.media;
    _pageController = PageController();
    _cutSynopsis();
    _pictures.add(widget.media.mediaPicture);
    if (widget.media.userMediaStatus != null) {
      _decideFabColor(widget.media.userMediaStatus!);
    }
    MalAPIHelper.fetchMediaById(
      _media.id,
      widget.isAnime,
      (media) {
        setState(() {
          _media = media;
        });
        if (media.pictures != null) {
          media.pictures!.removeWhere((picture) {
            return _pictures[0].medium == picture.medium;
          });
          setState(() {
            _pictures = List.of(_pictures)..addAll(media.pictures!);
          });
        }
      },
      fields: widget.isAnime ? GlobalConstant.mandatoryFields : GlobalConstant.mangaMandatoryFields
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool isUpdated = Provider.of<GlobalNotifier>(context).updated;
    if (isUpdated) {
      _log.i("media updated");
      MalAPIHelper.fetchMediaById(
        _media.id,
        widget.isAnime,
        (MediaNode node) {
          Provider.of<GlobalNotifier>(context, listen: false).statusNeedUpdate = node.userMediaStatus?.status ?? "*";
          if (_calledFromPage.isEmpty) {
            Provider.of<GlobalNotifier>(context, listen: false).statusBeforeUpdate = _media.userMediaStatus?.status ?? "*";
          }
          _decideFabColor(node.userMediaStatus);
          if (_media.userMediaStatus?.status != node.userMediaStatus?.status) {
            if (_calledFromPage != "*") {
              setState(() {
                _enableDismissal = true;
              });
            }
          }
          setState(() {
            _media = node;
          });
          Provider.of<GlobalNotifier>(context, listen: false).updated = false;
          _onPopInvoked(false);
          _log.i("media detail changing");
        },
        fields: widget.isAnime ? GlobalConstant.mandatoryFields : GlobalConstant.mangaMandatoryFields
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        PopScope(
          onPopInvoked: (didPop) {
            _checkDismissal();
          },
          child: Scaffold(
            body: LayoutBuilder(builder: (context, constraint) {
              final size = constraint.maxHeight >= constraint.maxWidth ?
              constraint.maxWidth / 2.2 : constraint.maxHeight / 2.2;
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    stretchTriggerOffset: 10,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    pinned: true,
                    leading: IconButton(
                      onPressed: () {
                        _checkDismissal();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    title: Padding(
                      padding: const EdgeInsets.only(top: 8, right: 48, bottom: 8),
                      child: Center(
                        child: Image.asset("images/mal-logo-full.png", height: 120, width: 120,),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                              )
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  height: size * 1.5,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text("Score", style: Theme.of(context).textTheme.displaySmall,),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star_rounded,
                                                  size: 38,
                                                ),
                                                const SizedBox(width: 4,),
                                                Text(
                                                  _media.mean != null ? _media.mean.toString() : "N/A",
                                                  style: Theme.of(context).textTheme.displayMedium!.copyWith(fontStyle: FontStyle.italic),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text("Members", style: TextStyle(color: Colors.grey.shade700),),
                                            Text(
                                              NumberFormat.decimalPattern().format(_media.numScoringUsers ??= 0),
                                              style: Theme.of(context).textTheme.displaySmall!.copyWith(fontStyle: FontStyle.italic),
                                            ),
                                            const SizedBox(height: 2,),
                                            Text("Rank", style: TextStyle(color: Colors.grey.shade700),),
                                            Row(
                                              children: [
                                                Icon(Icons.numbers_rounded, size: 24, color: Colors.grey.shade700,),
                                                Text(
                                                  NumberFormat.decimalPattern().format(_media.rank ??= 0),
                                                  style: Theme.of(context).textTheme.displaySmall!.copyWith(fontStyle: FontStyle.italic),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2,),
                                            Text("Popularity", style: TextStyle(color: Colors.grey.shade700),),
                                            Text(
                                              NumberFormat.decimalPattern().format(_media.popularity ??= 0),
                                              style: Theme.of(context).textTheme.displaySmall!.copyWith(fontStyle: FontStyle.italic),
                                            ),
                                            const SizedBox(height: 8,),
                                            Row(children: InfoBar.bars(_media, context, showWarning: widget.isContentSensitive))
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Hero(
                                  tag: widget.heroTag,
                                  child: SwipeableImage(
                                      width: size,
                                      pictures: _pictures
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 16),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                              child: Text(
                                _media.title,
                                style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 4),
                          child: Column(
                            children: [
                              SizedBox(
                                child: Text(
                                  _synopsis,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                              _isAbleExpandSynopsis ? Center(
                                child: _RotateableArrow(
                                  onTap: () {
                                    _showHideSynopsis();
                                  },
                                ),
                              ) : const SizedBox(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8,),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 4),
                          child: _MediaDetails(
                              media: _media,
                              width: constraint.maxWidth,
                              titleStyle: _detailsTitleStyle(context),
                              contentStyle: _detailsStyle(context),
                              isAnime: widget.isAnime
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              );
            }),
            floatingActionButton: FloatingActionButton.large(
              backgroundColor: _fabColor,
              heroTag: null,
              shape: const CircleBorder(),
              onPressed: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.linear
              ),
              child: _fabIcon(),
            ),
          ),
        ),
        EditMediaPage(
          media: _media,
          isAnime: widget.isAnime,
          onPopInvoked: _onPopInvoked,
          onEditUpdated: () {
            ScaffoldMessenger.of(context).showSnackBar(_snackBar("List updated"));
          },
          onRemoved: (isUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(_snackBar(isUpdated ? "Removed" : "Fail to remove"));
          },
          cardEnableUpdate: _calledFromPage == "*",
        ),
      ],
    );
  }
}

class _RotateableArrow extends StatefulWidget {
  final VoidCallback onTap;
  final double? iconSize;

  const _RotateableArrow({
    required this.onTap,
    this.iconSize
  });

  @override
  State<_RotateableArrow> createState() => _RotateableArrowState();
}

class _RotateableArrowState extends State<_RotateableArrow> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _rotationValue;
  bool _isRotate = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 80));
    _rotationValue = Tween<double>(begin: 0.0, end: 0.5).animate(_animationController);
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _rotationValue,
      child: GestureDetector(
        onTap: () {
          if (_isRotate) {
            _animationController.forward();
            setState(() {
              _isRotate = !_isRotate;
            });
          } else {
            _animationController.reverse();
            setState(() {
              _isRotate = !_isRotate;
            });
          }
          widget.onTap();
        },
        child: Icon(Icons.keyboard_arrow_down_rounded, size: widget.iconSize ?? 32,),
      ),
    );
  }
}

class _MediaDetails extends StatefulWidget {
  final MediaNode media;
  final double width;
  final TextStyle titleStyle;
  final TextStyle contentStyle;
  final bool isAnime;

  const _MediaDetails({
    required this.media,
    required this.width,
    required this.titleStyle,
    required this.contentStyle,
    required this.isAnime
  });

  @override
  State<_MediaDetails> createState() => _MediaDetailsState();
}

class _MediaDetailsState extends State<_MediaDetails>{
  bool _isExpanded = false;

  bool _checkGenre() {
    return widget.media.genres != null && widget.media.genres!.isNotEmpty;
  }

  bool _checkAlternativeTitle() {
    return widget.media.alternativeTitles != null;
  }

  bool _checkSeason() {
    return widget.media.startSeason != null;
  }

  bool _checkRating() {
    return widget.media.rating != null && widget.media.rating!.isNotEmpty;
  }

  bool _needContent() {
    return !_checkGenre() || !_checkAlternativeTitle() || !_checkSeason();
  }

  bool _checkStudio() {
    return widget.media.studios != null && widget.media.studios!.isNotEmpty;
  }

  bool _checkAuthor() {
    return widget.media.authors != null && widget.media.authors!.isNotEmpty;
  }

  bool _isExpandable() {
    return !_needContent() && (
      _checkRating() || (_checkStudio() || _checkAuthor())
    );
  }

  Widget _detail(String title, String content, {Widget? custom}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: widget.titleStyle,
        ),
        custom ?? Text(
          content,
          style: widget.contentStyle,
        ),
        const SizedBox(height: 6,)
      ],
    );
  }

  Widget _alternativeTitles(BuildContext context) {
    final AlternativeTitles alternativeTitles = widget.media.alternativeTitles!;
    final Map<String, String> alternatives = {
    if (alternativeTitles.synonyms != null && alternativeTitles.synonyms!.isNotEmpty)
        "Synonym:" : alternativeTitles.synonyms!.join(", ")
      ,
      if (alternativeTitles.en != null && alternativeTitles.en!.isNotEmpty)
        "En:" : alternativeTitles.en!
      ,
      if (alternativeTitles.ja != null && alternativeTitles.ja!.isNotEmpty)
        "Ja:" : alternativeTitles.ja!
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: alternatives.entries.map((entry) {
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "${entry.key} ",
                style: widget.contentStyle,
              ),
              TextSpan(
                text: entry.value,
                style: widget.contentStyle.copyWith(color: Colors.grey.shade600),
              ),
            ]
          ),
        );
      }).toList(),
    );
  }

  String _mapRating() {
    return widget.media.rating!.length == 2 ?
      widget.media.rating!.toUpperCase() : widget.media.rating!.split("_")
        .join("-").toUpperCase();
  }


  Widget _studioOrAuthors() {
    String title = "";
    String content = "";
    if (widget.isAnime) {
      if (_checkStudio()) {
        title = "Studio:";
        content = widget.media.studios!.map((studio) {
          return studio.name;
        }).toList().join(", ");
      }
    } else {
      if (_checkAuthor()) {
        title = "Author:";
        content = widget.media.authors!.map((author) {
          return "${author.node.firstName} ${author.node.lastName}";
        }).toList().join(", ");
      }
    }
    return ((_checkAuthor() || _checkStudio()) && _needContent() || _isExpanded) ? _detail(title, content)
      : const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(10))
      ),
      width: widget.width,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_checkGenre()) _detail(
            "Genre:",
            widget.media.genres!.map((genre) {
              return genre.name;
            }).toList().join(", ")
          ),
          if (_checkAlternativeTitle()) _detail(
            "Alternative Titles:", "", custom: _alternativeTitles(context)
          ),
          if (_checkSeason() && widget.isAnime) _detail(
            "Start Season:",
            "${widget.media.startSeason!.season[0].toUpperCase() +
              widget.media.startSeason!.season.substring(1)}, ${widget.media.startSeason!.year}"
          ),
          if ((_needContent() || _isExpanded) && _checkRating() && widget.isAnime) _detail(
            "Rating",
            _mapRating()
          ),
          _studioOrAuthors(),
          if (_isExpandable()) Center(
            child: _RotateableArrow(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              iconSize: 28,
            ),
          ),
        ],
      )
    );
  }
}