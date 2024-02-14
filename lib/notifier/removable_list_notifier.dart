import 'package:anime_gallery/model/mal/media_node.dart';
import 'package:flutter/cupertino.dart';

class RemovableListNotifier extends ChangeNotifier {
  int _currentIndex = -1;
  String _statusPage = "*";
  bool _deleteInAllPage = false;
  bool _removeCurrentItem = false;
  MediaNode _currentMedia = MediaNode.empty();

  int get currentIndex => _currentIndex;
  String get statusPage => _statusPage;
  bool get removeCurrentItem => _removeCurrentItem;
  bool get deleteInAllPage => _deleteInAllPage;
  MediaNode get currentMedia => _currentMedia;

  set currentIndex(int newIndex) {
    _currentIndex = newIndex;
    notifyListeners();
  }

  set statusPage(String newValue) {
    _statusPage = newValue;
    notifyListeners();
  }

  set removeCurrentItem(bool newValue) {
    _removeCurrentItem = newValue;
    notifyListeners();
  }

  set deleteInAllPage(bool newValue) {
    _deleteInAllPage = newValue;
    notifyListeners();
  }

  set currentMedia(MediaNode newValue) {
    _currentMedia = newValue;
    notifyListeners();
  }
}