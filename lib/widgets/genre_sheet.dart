import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:logger/logger.dart';

import '../api/jikan/api_helper.dart';
import '../database/database.dart';
import '../database/database_util.dart';
import '../model/jikan/media.dart';
import '../model/jikan/resource.dart';
import 'discovery_page.dart';
import 'genre_page.dart';

final Logger _log = Logger();

class GenreSheet extends StatefulWidget {
  final BuildContext parentContext;
  const GenreSheet({
    super.key,
    required this.parentContext
  });

  @override
  State<GenreSheet> createState() => _GenreSheetState();
}

class _GenreSheetState extends State<GenreSheet> with SingleTickerProviderStateMixin {
  bool _showLoading = false;
  bool _selectionIsAnime = true;
  List<ChipData<Resource>>? _animeGenres;
  List<ChipData<Resource>>? _mangaGenres;
  List<JikanMedia>? _genreSearchResult;
  final List<ChipData<Resource>> _selectedAnimeGenres = [];
  final List<ChipData<Resource>> _selectedMangaGenres = [];
  final List<ChipData<bool>> _selectionData = [];
  late final AnimationController _bottomSheetController;

  List<int> _extractIds(List<ChipData<Resource>> genres) {
    return genres.map((e) =>
    e.data.malId!
    ).toList();
  }

  void _initGenre() async {
    final animeGenres = await AppDatabaseUtil.getAnimeGenres();
    final mangaGenres = await AppDatabaseUtil.getMangaGenres();
    _log.i("anime genres length: ${animeGenres.length}");
    _log.i("manga genres length: ${mangaGenres.length}");
    if (animeGenres.isEmpty) {
      JikanApiHelper.getGenres(true, (genres) {
        setState(() {
          _animeGenres = genres.data?.map((e) =>
              ChipData(text: e.name ?? "", data: e)
          ).toList();
        });
        AppDatabaseUtil.insertIntoAnimeGenre(AnimeGenreData.fromResources(genres.data!));
      },
          onFailure: () => setState(() {
            _animeGenres = [];
          }));
    } else {
      setState(() {
        _animeGenres = ChipData.fromDb(animeGenres);
      });
    }

    if (mangaGenres.isEmpty) {
      JikanApiHelper.getGenres(false, (genres) {
        setState(() {
          _mangaGenres = genres.data?.map((e) =>
              ChipData(text: e.name ?? "", data: e)
          ).toList();
        });
        AppDatabaseUtil.insertIntoMangaGenre(MangaGenreData.fromResources(genres.data!));
      },
          onFailure: () => setState(() {
            _mangaGenres = [];
          }));
    } else {
      setState(() {
        _mangaGenres = ChipData.fromDb(mangaGenres);
      });
    }
  }

  SnackBar _genreEmptySnackBar() {
    return SnackBar(
      content: Text(
        "Choose at least 1 genre",
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Colors.white
        ),
      ),
      duration: const Duration(milliseconds: 1300),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  @override
  void initState() {
    super.initState();
    _bottomSheetController = AnimationController(vsync: this);
    _initGenre();
  }

  @override
  void dispose() {
    super.dispose();
    _bottomSheetController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: !_showLoading,
        onPopInvoked: (b) {
          if (!_showLoading) {
            setState(() {
              _selectedAnimeGenres.clear();
              _selectedMangaGenres.clear();
              _selectionData.clear();
              _selectionIsAnime = true;
            });
          }
        },
        child: Scaffold(
          body: BottomSheet(
              animationController: _bottomSheetController,
              enableDrag: false,
              onClosing: () {},
              builder: (innerContext) => Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: MediaQuery.paddingOf(widget.parentContext).top),
                      padding: const EdgeInsets.all(8),
                      height: double.infinity,
                      width: double.infinity,
                      child: Column(
                        children: [
                          Expanded(
                              child: ListView(
                                children: [
                                  _SelectionChip(
                                    label: "Media Type",
                                    items: const [
                                      ChipData<bool>(text: "Anime", data: true),
                                      ChipData<bool>(text: "Manga", data: false),
                                    ],
                                    isMultiSelect: false,
                                    selectedChips: _selectionData,
                                    minOne: true,
                                    onTap: (data) {
                                      setState(() {
                                        if (data.data) {
                                          _selectionIsAnime = true;
                                          _selectionData.removeLast();
                                          _selectionData.add(data);
                                          _selectedMangaGenres.clear();
                                        } else {
                                          _selectionIsAnime = false;
                                          _selectionData.removeLast();
                                          _selectionData.add(data);
                                          _selectedAnimeGenres.clear();
                                        }
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 12,),
                                  _selectionIsAnime ? _animeGenres == null ? SpinKitCircle(
                                    color: MediaQuery.platformBrightnessOf(context) == Brightness.light ?
                                    Colors.black : Colors.white,
                                  ) : _animeGenres!.isNotEmpty ? _SelectionChip<Resource>(
                                    label: "Genres",
                                    items: _animeGenres!,
                                    isMultiSelect: true,
                                    selectedChips: _selectedAnimeGenres,
                                  ) : const Center(
                                    child: Text("No genres found due to server unavailability"),
                                  ) : _mangaGenres == null ? SpinKitCircle(
                                    color: MediaQuery.platformBrightnessOf(context) == Brightness.light ?
                                    Colors.black : Colors.white,
                                  ) : _mangaGenres!.isNotEmpty ? _SelectionChip<Resource>(
                                    label: "Genres",
                                    items: _mangaGenres!,
                                    isMultiSelect: true,
                                    selectedChips: _selectedMangaGenres,
                                  ) : const Center(
                                    child: Text("No genres found due to server unavailability"),
                                  )
                                ],
                              )
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: const ButtonStyle(
                                        overlayColor: MaterialStatePropertyAll(Color.fromARGB(10, 255, 0, 0))
                                    ),
                                    child: Text(
                                      "Cancel",
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                          color: Colors.red
                                      ),
                                    )
                                ),
                                TextButton(
                                    onPressed: () {
                                      if (_selectedAnimeGenres.isNotEmpty || _selectedMangaGenres.isNotEmpty) {
                                        setState(() {
                                          _showLoading = true;
                                        });
                                        JikanApiHelper.getMediaByGenres(
                                            _selectionIsAnime,
                                            _selectionIsAnime ? _extractIds(_selectedAnimeGenres) :
                                            _extractIds(_selectedMangaGenres),
                                                (data) {
                                              setState(() {
                                                _showLoading = false;
                                              });
                                              Navigator.push(context, MaterialPageRoute(
                                                  builder: (context) => GenrePage(
                                                    media: data.data ?? [],
                                                    isAnime: _selectionIsAnime,
                                                    initialData: data,
                                                    genres: _selectionIsAnime ? _selectedAnimeGenres.map((e) =>
                                                      e.data.malId!
                                                    ).toList() : _selectedMangaGenres.map((e) =>
                                                      e.data.malId!
                                                    ).toList(),
                                                  )
                                              ));
                                            }
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(_genreEmptySnackBar());
                                      }
                                    },
                                    style: const ButtonStyle(
                                        overlayColor: MaterialStatePropertyAll(Color.fromARGB(10, 0, 255, 0))
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          "Search",
                                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                              color: Colors.green
                                          ),
                                        ),
                                        Transform.rotate(
                                          angle: pi / 2.5,
                                          child: const Icon(
                                            CupertinoIcons.search,
                                            color: Colors.green,
                                            size: 16,
                                          ),
                                        )
                                      ],
                                    )
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                  ),
                  if (_showLoading) Container(
                    color: Colors.black45,
                    child: SpinKitCircle(
                      color: MediaQuery.platformBrightnessOf(context) == Brightness.light ?
                      Colors.black : Colors.white,
                    ),
                  )
                ],
              )
          ),
        )
    );
  }
}


class ChipData<T> {
  final String text;
  final T data;

  static List<ChipData<Resource>> fromDb<T extends GenreData>(List<T> data) {
    return data.map((e) =>
        ChipData(
            text: e.genreName,
            data: Resource()
              ..malId = e.malId
              ..name = e.genreName
        )
    ).toList();
  }

  const ChipData({required this.text, required this.data});
}

class _SelectionChip<T> extends StatefulWidget {
  final List<ChipData<T>> items;
  final String label;
  final bool isMultiSelect;
  bool? minOne;
  List<ChipData<T>> selectedChips = [];
  void Function(ChipData<T>)? onTap;

  _SelectionChip({
    required this.label,
    required this.items,
    required this.isMultiSelect,
    required this.selectedChips,
    this.minOne,
    this.onTap
  }) {
    minOne ??= false;
  }

  @override
  State<_SelectionChip<T>> createState() => _SelectionChipState<T>();
}

class _SelectionChipState<T> extends State<_SelectionChip<T>> {

  @override
  void initState() {
    super.initState();
    if (widget.minOne!) {
      if (widget.selectedChips.isEmpty) {
        widget.selectedChips.add(widget.items[0]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 8,),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: widget.items.map((e) =>
              _MChip(
                  data: e,
                  selected: widget.selectedChips.contains(e),
                  onTap: (data) {
                    setState(() {
                      if (widget.isMultiSelect) {
                        if (!widget.selectedChips.contains(e)) {
                          widget.selectedChips.add(e);
                        } else {
                          widget.selectedChips.remove(e);
                        }
                      } else {
                        widget.selectedChips = [];
                        widget.selectedChips.add(e);
                      }
                      _log.i("added: ${data.text}:${data.data}");
                      widget.onTap?.call(e);
                    });
                  }
              )
          ).toList(),
        )
      ],
    );
  }
}

class _MChip<T> extends StatelessWidget {
  final ChipData<T> data;
  final bool selected;
  final void Function(ChipData<T>) onTap;

  const _MChip({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(data),
      child: AnimatedContainer(
        decoration: BoxDecoration(
          color: selected ? Colors.grey.shade700 : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
              color: selected ? Colors.transparent :
              MediaQuery.platformBrightnessOf(context) == Brightness.light ?
              Colors.black : Colors.white
          ),
        ),
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(6),
        child: Text(
          data.text,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: selected ? Colors.white :
              MediaQuery.platformBrightnessOf(context) == Brightness.light ?
              Colors.black : Colors.white
          ),
        ),
      ),
    );
  }
}
