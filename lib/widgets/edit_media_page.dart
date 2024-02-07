import 'dart:async';

import 'package:anime_gallery/api/api_helper.dart';
import 'package:anime_gallery/model/media_node.dart';
import 'package:anime_gallery/model/user_media_status.dart';
import 'package:anime_gallery/notifier/update_media_notifier.dart';
import 'package:anime_gallery/util/show_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';

import '../other/media_status.dart';

class EditMediaPage extends StatefulWidget {
  final MediaNode media;
  final bool isAnime;
  final void Function(bool) onPopInvoked;
  final VoidCallback onEditUpdated;
  final void Function(bool) onRemoved;
  final bool cardEnableUpdate;

  const EditMediaPage({
    super.key,
    required this.media,
    required this.isAnime,
    required this.onPopInvoked,
    required this.onEditUpdated,
    required this.onRemoved,
    required this.cardEnableUpdate
  });

  @override
  State<EditMediaPage> createState() => _EditMediaPageState();
}

class _EditMediaPageState extends State<EditMediaPage> {
  bool _isStatusChanged = false;
  bool _isScoreChanged = false;
  bool _isProgressChanged = false;
  bool _isShowingLoading = false;
  String _updatedStatus = "";
  int _updatedScore = 0;
  int _updatedProgress = 0;
  final Logger _log = Logger();

  bool _isSelectionsChanged() {
    return _isStatusChanged || _isScoreChanged || _isProgressChanged;
  }

  void _onSelectedStatus(MediaStatus s) {
    if (widget.media.userMediaStatus != null) {
      if (widget.media.userMediaStatus!.status != null) {
        setState(() {
          _validateStatus(s);
        });
      }
    } else {
      setState(() {
        _isStatusChanged = true;
        if (widget.isAnime) {
          if (widget.media.numEpisodes! == _updatedProgress) {
            _updatedStatus = "completed";
          } else {
            _updatedStatus = s.jsonName;
          }
        } else {
          if (widget.media.numChapters! == _updatedProgress) {
            _updatedStatus = "completed";
          } else {
            _updatedStatus = s.jsonName;
          }
        }
      });
    }
    _log.i("updated status: $_updatedStatus");
  }

  void _validateStatus(MediaStatus s) {
    //make sure to make the status complete if updated progress is same as media's total episodes
    if (widget.isAnime) {
      if (widget.media.numEpisodes! == _updatedProgress) {
        _updatedStatus = "completed";
      } else {
        _updatedStatus = s.jsonName;
      }
    } else {
      if (widget.media.numChapters! == _updatedProgress) {
        _updatedStatus = "completed";
      } else {
        _updatedStatus = s.jsonName;
      }
    }
    //user status with selected status
    if (widget.media.userMediaStatus!.status != _updatedStatus) {
      _isStatusChanged = true;
    } else {
      _isStatusChanged = false;
    }
  }

  void _changeProgressOnCompleted(BuildContext context) {
    if (_updatedStatus == "completed") {
      if (widget.isAnime) {
        Provider.of<GlobalNotifier>(context, listen: false).selectedIndex = widget.media.numEpisodes!.toDouble();
        Provider.of<GlobalNotifier>(context, listen: false).status = 1;
        setState(() {
          _updatedProgress = Provider.of<GlobalNotifier>(context, listen: false).selectedIndex.toInt();
        });
      } else {
        Provider.of<GlobalNotifier>(context, listen: false).selectedIndex = widget.media.numChapters!.toDouble();
        Provider.of<GlobalNotifier>(context, listen: false).status = 1;
        setState(() {
          _updatedProgress = Provider.of<GlobalNotifier>(context, listen: false).selectedIndex.toInt();
        });
      }
    }
    _log.i("progress updated to completed: $_updatedProgress");
    _log.i("status updated to completed: $_updatedStatus");
  }

  void _showAlertDialog(BuildContext context) {
    mShowDialog(context, "Discard all changes?", () {
      Provider.of<GlobalNotifier>(context, listen: false).selectedIndex = 0;
      Provider.of<GlobalNotifier>(context, listen: false).status = -1;
      widget.onPopInvoked(false);
    });
  }

  void _onScoreChange(int scoreIndex) {
    if (widget.media.userMediaStatus != null) {
      setState(() {
        if (widget.media.userMediaStatus!.score != _mapScore(scoreIndex)) {
          _isScoreChanged = true;
        } else {
          _isScoreChanged = false;
        }
        _updatedScore = _mapScore(scoreIndex);
      });
    } else {
      if (scoreIndex != 0) {
        setState(() {
          _isScoreChanged = true;
          _updatedScore = _mapScore(scoreIndex);
        });
      } else {
        setState(() {
          _isScoreChanged = false;
          _updatedScore = 0;
        });
      }
    }
    _log.i("score updated to: $_updatedScore");
  }

  int _mapScore(int scoreIndex) {
    if (scoreIndex == 0) {
      return 0;
    }
    int score = 0;
    for (var i = scoreIndex; i <= 10; i++) {
      score++;
    }
    return score;
  }

  void _onProgressChange(int index) {
    if (widget.media.userMediaStatus != null) {
      setState(() {
        if (widget.media.userMediaStatus!.numEpisodesWatched != index) {
          _isProgressChanged = true;
        } else {
          _isProgressChanged = false;
        }
        _updatedProgress = index;
      });
    } else {
      if (index != 0) {
        setState(() {
          _isProgressChanged = true;
          _updatedProgress = index;
        });
      } else {
        setState(() {
          _isProgressChanged = false;
          _updatedProgress = 0;
        });
      }
    }
    if (widget.isAnime) {
      if (_updatedProgress != widget.media.numEpisodes) {
        if (_updatedStatus.isEmpty || _updatedStatus == "completed") {
          Provider.of<GlobalNotifier>(context, listen: false).status = 0;
          setState(() {
            _updatedStatus = "watching";
          });
        }
      } else {
        Provider.of<GlobalNotifier>(context, listen: false).status = 1;
        setState(() {
          _updatedStatus = "completed";
        });
      }
    } else {
      if (_updatedProgress != widget.media.numChapters) {
        if (_updatedStatus.isEmpty || _updatedStatus == "completed") {
          Provider.of<GlobalNotifier>(context, listen: false).status = 0;
          setState(() {
            _updatedStatus = "reading";
          });
        }
      } else {
        Provider.of<GlobalNotifier>(context, listen: false).status = 1;
        setState(() {
          _updatedStatus = "completed";
        });
      }
    }
    if (widget.media.userMediaStatus != null) {
      if (_updatedStatus == widget.media.userMediaStatus!.status) {
        setState(() {
          _isStatusChanged = false;
        });
      } else {
        setState(() {
          _isStatusChanged = true;
        });
      }
    } else {
      setState(() {
        _isStatusChanged = true;
      });
    }
    _log.i("status updated after progress: $_updatedStatus");
    _log.i("progress updated to: $_updatedProgress");
  }

  void _updateMedia() {
    setState(() {
      _isShowingLoading = true;
    });
    MalAPIHelper.updateMedia(
      widget.media.id,
      widget.isAnime,
      (updatedMedia) {
        // callback function as preferred way to get the updated data to its dependants
        // by call the MalAPIHelper.fetchMediaById in this method and having a callback
        // for the result's callback, prevent multiple request to update the dependent's state
        // and for more better user experience and consistency.
        // **using this notifier way as it already implemented
        Provider.of<GlobalNotifier>(context, listen: false).updated = true;
        Provider.of<GlobalNotifier>(context, listen: false).status = -1;
        Provider.of<GlobalNotifier>(context, listen: false).selectedIndex = 0;
        if (widget.cardEnableUpdate) {
          Provider.of<GlobalNotifier>(context, listen: false).updatedMediaId = widget.media.id;
        }

        widget.onEditUpdated();
      },
      status: _updatedStatus,
      score: _updatedScore,
      progress: _updatedProgress
    );
  }

  void _updateAfterPop() {
    Provider.of<GlobalNotifier>(context, listen: false).selectedIndex = 0;
    Provider.of<GlobalNotifier>(context, listen: false).status = -1;
    widget.onPopInvoked(false);
  }

  void _removeMedia() {
    mShowDialog(
      context,
      "Remove from your list?",
      () {
        setState(() {
          _isShowingLoading = true;
        });
        MalAPIHelper.removeMedia(
            widget.media.id,
            widget.isAnime,
            (isUpdated) {
              Provider.of<GlobalNotifier>(context, listen: false).updated = true;
              Provider.of<GlobalNotifier>(context, listen: false).status = -1;
              Provider.of<GlobalNotifier>(context, listen: false).selectedIndex = 0;
              if (widget.cardEnableUpdate) {
                Provider.of<GlobalNotifier>(context, listen: false).updatedMediaId = widget.media.id;
              }
              widget.onRemoved(isUpdated);
            }
        );
      }
    );
  }

  @override
  void initState() {
    super.initState();
    final userMediaStatus = widget.media.userMediaStatus;
    if (userMediaStatus != null) {
      setState(() {
        _updatedStatus = userMediaStatus.status!;
        _updatedScore = userMediaStatus.score;
        if (widget.isAnime) {
          _updatedProgress = userMediaStatus.numEpisodesWatched ?? 0;
        } else {
          _updatedProgress = userMediaStatus.numChaptersRead ?? 0;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (b) {
        _isSelectionsChanged() && !_isShowingLoading ? _showAlertDialog(context) :
          !_isShowingLoading ? _updateAfterPop() : null;
      },
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 80,
          leading: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: IconButton(
                  onPressed: () {
                    _isSelectionsChanged() ? _showAlertDialog(context) : _updateAfterPop();
                  },
                  icon: Icon(
                    _isSelectionsChanged() ? CupertinoIcons.clear : Icons.arrow_back_rounded,
                    color: _isSelectionsChanged() ? const Color.fromARGB(255, 160, 0, 0) : null,
                  ),
                  color: _isSelectionsChanged() ? Colors.red : Colors.grey,
                  iconSize: 32,
                ),
              ),
            ],
          ),
          actions: [
            _isSelectionsChanged() ? Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: _updateMedia,
                icon: Icon(
                  Icons.check_rounded,
                  color: Colors.green.shade700,
                ),
                color: Colors.green,
                iconSize: 32,
              ),
            ) : const SizedBox(),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Status",
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Theme.of(context).brightness == Brightness.dark ?
                              Colors.grey.shade500 : Colors.grey.shade700
                          ),
                        ),
                        _StatusSelection(
                          isAnime: widget.isAnime,
                          status: MediaStatus.status(widget.isAnime),
                          userMediaStatus: widget.media.userMediaStatus,
                          onSelectedStatus: (s) {
                            _onSelectedStatus(s);
                            _changeProgressOnCompleted(context);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24,),
                    // Score
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Score",
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).brightness == Brightness.dark ?
                              Colors.grey.shade500 : Colors.grey.shade700
                          ),
                        ),
                        Center(
                          child: _NumberSelection(
                            length: 0,
                            isScore: true,
                            isAnime: widget.isAnime,
                            userMediaStatus: widget.media.userMediaStatus,
                            onSelectedIndex: _onScoreChange,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 24,),
                    // Progress
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isAnime ? "Episode" : "Chapter",
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark ?
                            Colors.grey.shade500 : Colors.grey.shade700
                          ),
                        ),
                        Center(
                          child: _NumberSelection(
                            length: widget.isAnime ? widget.media.numEpisodes! : widget.media.numChapters!,
                            isScore: false,
                            isAnime: widget.isAnime,
                            userMediaStatus: widget.media.userMediaStatus,
                            onSelectedIndex: _onProgressChange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: _isShowingLoading,
              child: const Scaffold(
                backgroundColor: Colors.black26,
                body: SpinKitCircle(
                  color: Colors.white70,
                ),
              )
            )
          ],
        ),
        floatingActionButton: widget.media.userMediaStatus != null ? FloatingActionButton.extended(
          onPressed: _removeMedia,
          label: Text(
            "Delete from list",
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).brightness == Brightness.light ?
                const Color.fromARGB(255, 200, 0, 0) : const Color.fromARGB(255, 220, 0, 0),
              fontWeight: FontWeight.bold
            ),
          ),
          icon: Icon(
            Icons.delete,
            color: Theme.of(context).brightness == Brightness.light ?
            const Color.fromARGB(255, 200, 0, 0) : const Color.fromARGB(255, 220, 0, 0),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0.5,
        ) : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }
}

class _StatusSelection extends StatefulWidget {
  final bool isAnime;
  final List<MediaStatus> status;
  final UserMediaStatus? userMediaStatus;
  final void Function(MediaStatus) onSelectedStatus;

  const _StatusSelection({
    super.key,
    required this.isAnime,
    required this.status,
    required this.userMediaStatus,
    required this.onSelectedStatus,
  });

  @override
  State<_StatusSelection> createState() => _StatusSelectionState();
}

class _StatusSelectionState extends State<_StatusSelection> {
  int _selectedIndex = -1;

  void _initSelection() {
    if (widget.userMediaStatus != null) {
      for(var i in MediaStatus.status(widget.isAnime)) {
        if (widget.userMediaStatus!.status != null) {
          if (widget.userMediaStatus!.status == i.jsonName) {
            setState(() {
              _selectedIndex = i.index;
            });
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initSelection();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final status = Provider.of<GlobalNotifier>(context).status;
    if (status != -1) {
      setState(() {
        _selectedIndex = status;
      });
    }
  }

  Widget _statusBar(MediaStatus status, void Function(MediaStatus) onTap) {
    return GestureDetector(
      onTap: () => onTap(status),
      child: AnimatedContainer(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.fromBorderSide(
            BorderSide(
              color: _selectedIndex == status.index ? status.statusColor :
                Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade400,
              width: 1.4
            ),
          ),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          color: _selectedIndex == status.index ? status.statusColor : Colors.transparent,
        ),
        duration: const Duration(milliseconds: 130),
        child: Text(
          status.name,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: _selectedIndex == status.index ? Colors.white :
              Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : Colors.grey.shade600,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: widget.status.map((e) {
        return _statusBar(e, (status) {
          setState(() {
            _selectedIndex = status.index;
          });
          widget.onSelectedStatus(status);
        });
      }).toList(),
    );
  }
}

class _NumberSelection extends StatefulWidget {
  final int length;
  final bool isScore;
  final bool isAnime;
  /// TODO user from [media] instead
  final UserMediaStatus? userMediaStatus;
  final void Function(int) onSelectedIndex;

  const _NumberSelection({
    super.key,
    required this.length,
    required this.isScore,
    required this.isAnime,
    required this.userMediaStatus,
    required this.onSelectedIndex,
  });

  @override
  State<_NumberSelection> createState() => _NumberSelectionState();
}

class _NumberSelectionState extends State<_NumberSelection> {
  int _selectedIndex = 0;
  List<String> scoreLabel = [
    "Not Scored",
    "Masterpiece",
    "Great",
    "Very Good",
    "Good",
    "Fine",
    "Average",
    "Bad",
    "Very Bad",
    "Horrible",
    "What is this thing?",
  ];
  late final GlobalKey<ScrollSnapListState> _sslKey;

  void _initSelection() {
    if (widget.isScore) {
      if (widget.userMediaStatus != null) {
        if (widget.userMediaStatus!.score != 0) {
          setState(() {
            _selectedIndex = 11 - widget.userMediaStatus!.score;
          });
        }
      }
    } else {
      if (widget.userMediaStatus != null) {
        setState(() {
          if (widget.isAnime) {
            _selectedIndex = widget.userMediaStatus!.numEpisodesWatched!;
          } else {
            _selectedIndex = widget.userMediaStatus!.numChaptersRead!;
          }
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initSelection();
    _sslKey = GlobalKey<ScrollSnapListState>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    double selectedIndexFromNotifier = Provider.of<GlobalNotifier>(context).selectedIndex;
    if (!widget.isScore) {
      if (selectedIndexFromNotifier != 0) {
        setState(() {
          _selectedIndex = selectedIndexFromNotifier.toInt();
        });
        Future.delayed(const Duration(milliseconds: 100)).whenComplete(() {
          _sslKey.currentState?.focusToItem(selectedIndexFromNotifier.toInt());
          Provider.of<GlobalNotifier>(context, listen: false).selectedIndex = 0;
        });
      }
    }
    print("from didchange: $selectedIndexFromNotifier");
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return SizedBox(
          height: 70,
          width: constraint.maxWidth / 1.2,
          child: ScrollSnapList(
            key: _sslKey,
            initialIndex: _selectedIndex.toDouble(),
            selectedItemAnchor: SelectedItemAnchor.MIDDLE,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    widget.isScore ? Text(
                      index == 0 ? "-" : (10 - (index - 1)).toString(),
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                          color: index == _selectedIndex ? const Color.fromARGB(255, 46, 110, 160)
                              : null,
                          fontWeight: FontWeight.bold
                      ),
                    ) : Text(
                      index.toString(),
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        color: index == _selectedIndex ? const Color.fromARGB(255, 46, 110, 160)
                          : null,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    widget.isScore ? Visibility(
                      visible: index == _selectedIndex,
                      child: Text(
                        scoreLabel[index],
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: index == _selectedIndex ? const Color.fromARGB(255, 46, 110, 160)
                                : Theme.of(context).textTheme.displaySmall!.color,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ) : const SizedBox(),
                  ],
                )
              );
            },
            itemCount: widget.isScore ? 11 : widget.length == 0 ? 5000 : widget.length + 1,
            itemSize: 100,
            onItemFocus: (currentIndex) {
              setState(() {
                _selectedIndex = currentIndex;
              });
              widget.onSelectedIndex(currentIndex);
            }
          )
        );
      }
    );
  }
}