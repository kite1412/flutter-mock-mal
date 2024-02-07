import 'package:anime_gallery/api/api_helper.dart';
import 'package:anime_gallery/model/media_node.dart';
import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';

import '../model/data.dart';

class RefreshContentUtil with ChangeNotifier {
  final Logger _log = Logger();
  final ScrollController scrollController;
  final void Function(List<MediaNode>) onRefreshed;
  Data data;

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
    required this.data
  }) {
    scrollController.addListener(_autoRefreshListener);
  }

  void _fetchMedia() {
    MalAPIHelper.prevNextPage(
      data.paging.next!,
      (nodes) {
        onRefreshed(nodes);
      },
      (paging) {},
      dataCallback: (data) {
        if (data.paging.next == null) {
          _isRefreshCompleteSetter(true);
        } else {
          this.data = data;
        }
      }
    );
  }

  void _autoRefreshListener() async {
    final below = scrollController.position.extentAfter;
    final maxInside = scrollController.position.extentInside;
    if ((maxInside * 6) >= below) {
      if (!_isRefreshComplete && _ableToRefresh) {
        _ableToRefresh = false;
        _fetchMedia();
        _log.w("---IGNORE---: Refreshing");
        Future.delayed(const Duration(milliseconds: 1000)).whenComplete(() {
          _ableToRefresh = true;
        });
      }
    }
  }
}