import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class UpdateMediaNotifier extends ChangeNotifier {
  final Logger _log = Logger();
  double _selectedIndex = 0.0;
  int _statusIndex = -1;
  bool _updated = false;
  int _updatedMediaId = -1;
  bool _rankShowingAnime = true;
  bool _isFetchingCategorySuccess = false;
  bool _isRankDone = false;
  bool _isSuggestionsDone = false;
  bool _isOnAiringDone = false;
  bool _userListShowingAnime = true;

  double get selectedIndex => _selectedIndex;
  int get status => _statusIndex;
  bool get updated => _updated;
  int get updatedMediaId => _updatedMediaId;
  bool get rankShowingAnime => _rankShowingAnime;
  bool get isFetchingCategorySuccess => _isFetchingCategorySuccess;
  bool get isRankDone => _isRankDone;
  bool get isSuggestionsDone => _isSuggestionsDone;
  bool get isOnAiringDone => _isOnAiringDone;
  bool get userListShowingAnime => _userListShowingAnime;

  set selectedIndex(double newProgress) {
    _selectedIndex = newProgress;
    notifyListeners();
  }

  set status(int newStatusIndex) {
    _statusIndex = newStatusIndex;
    notifyListeners();
  }

  set updated(bool update) {
    _updated = update;
    notifyListeners();
  }

  set updatedMediaId(int index) {
    _updatedMediaId = index;
    notifyListeners();
  }

  set rankShowingAnime(bool newValue) {
    _rankShowingAnime = newValue;
    notifyListeners();
  }

  set isFetchingCategorySuccess(bool newValue) {
    _isFetchingCategorySuccess = newValue;
    notifyListeners();
  }

  set isRankDone(bool newValue) {
    _isRankDone = newValue;
    notifyListeners();
  }

  set isSuggestionsDone(bool newValue) {
    _isSuggestionsDone = newValue;
    notifyListeners();
  }

  set isOnAiringDone(bool newValue) {
    _isOnAiringDone = newValue;
    notifyListeners();
  }

  set userListShowingAnime(bool newValue) {
    _userListShowingAnime = newValue;
    notifyListeners();
  }
}