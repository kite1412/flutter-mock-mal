import 'package:anime_gallery/api/jikan/api_helper.dart';
import 'package:anime_gallery/api/mal/api_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';


class RefreshContentUtil with ChangeNotifier {
  final Logger _log = Logger();
  final ScrollController scrollController;
  final void Function(List<dynamic>) onRefreshed;
  bool? enabled;
  dynamic data;

  // to prevent indefinite request.
  bool _ableToRefresh = true;
  bool _isRefreshComplete = false;
  bool get isRefreshComplete => _isRefreshComplete;
  void _isRefreshCompleteSetter(bool newValue) {
    _isRefreshComplete = newValue;
    notifyListeners();
  }

  RefreshContentUtil({
    required this.scrollController,
    required this.onRefreshed,
    required this.data,
    this.enabled
  }) {
    attachListener();
  }

  void attachListener() {
    scrollController.addListener(_autoRefreshListener);
  }

  void detachListener() {
    scrollController.removeListener(_autoRefreshListener);
  }

  void _fetchMedia() {
    MalAPIHelper.prevNextPage(
      data.paging.next ?? "",
      (nodes) {
        onRefreshed(nodes);
      },
      (paging) {},
      dataCallback: (data) {
        if (data.paging.next == null) {
          _isRefreshCompleteSetter(true);
        } else {
          this.data = data;
          _log.w("---IGNORE---: Refreshing SUCCESS! Nodes length: ${data.mediaNodes.length}");
        }
        _ableToRefresh = true;
      }
    );
  }

  void _autoRefreshListener() async {
    if (enabled != null) {
      if (enabled!) {
        _refresh();
      }
    } else {
      _refresh();
    }
  }

  void _refresh() {
    final below = scrollController.position.extentAfter;
    final maxInside = scrollController.position.extentInside;
    if ((maxInside * 6) >= below) {
      if (!_isRefreshComplete && _ableToRefresh) {
        _ableToRefresh = false;
        _fetchMedia();
        _log.w("---IGNORE---: Refreshing");
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.removeListener(_autoRefreshListener);
  }
}

class RefreshRankedContentUtil extends RefreshContentUtil {
  RefreshRankedContentUtil({
    required super.scrollController,
    required super.onRefreshed,
    required super.data
  });

  @override
  void _fetchMedia() {
    MalAPIHelper.rankedNextPage(
      data.paging.next ?? "",
      dataCallback: (newData) {
        if (newData.paging.next != null) {
          data = newData;
        } else {
          _isRefreshCompleteSetter(true);
        }
        _ableToRefresh = true;
      },
      nodesCallback: onRefreshed
    );
  }
}

class RefreshJikanContentUtil extends RefreshContentUtil {
  final bool isAnime;
  Map<String, dynamic>? queries;

  RefreshJikanContentUtil({
    required super.scrollController,
    required super.onRefreshed,
    required super.data,
    required this.isAnime,
    this.queries
  });

  @override
  void _fetchMedia() {
    JikanApiHelper.loadNextPage(
      data,
      isAnime,
      (data) {
        this.data = data;
        onRefreshed(data.data!);
        _ableToRefresh = true;
      },
      queries: queries,
      onComplete: () => _isRefreshCompleteSetter(true)
    );
  }
}