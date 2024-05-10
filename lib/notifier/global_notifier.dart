import 'package:flutter/material.dart';

class GlobalNotifier extends ChangeNotifier {
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
  bool _isDismissalDone = false;
  bool _enableMediaToggleChange = true;
  bool _changeMediaTypeReady = false;
  bool _currentSessionAlreadyUpdated = true;
  bool _allPageUpdate = false;
  bool _isOnDetail = false;
  String _statusNeedUpdate = "*";
  String _statusBeforeUpdate = "*";

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
  bool get isDismissalDone => _isDismissalDone;
  bool get enableMediaToggleChange => _enableMediaToggleChange;
  bool get changeMediaTypeReady => _changeMediaTypeReady;
  bool get currentSessionAlreadyUpdated => _currentSessionAlreadyUpdated;
  bool get allPageUpdate => _allPageUpdate;
  bool get isOnDetail => _isOnDetail;
  String get statusNeedUpdate => _statusNeedUpdate;
  String get statusBeforeUpdate => _statusBeforeUpdate;

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

  set isDismissalDone(bool newValue) {
    _isDismissalDone = newValue;
    notifyListeners();
  }

  set enableMediaToggleChange(bool newValue) {
    _enableMediaToggleChange = newValue;
    notifyListeners();
  }

  set changeMediaTypeReady(bool newValue) {
    _changeMediaTypeReady = newValue;
    notifyListeners();
  }

  set currentSessionAlreadyUpdated(bool newValue) {
    _currentSessionAlreadyUpdated = newValue;
    notifyListeners();
  }

  set allPageUpdate(bool newValue) {
    _allPageUpdate = newValue;
    notifyListeners();
  }

  set isOnDetail(bool newValue) {
    _isOnDetail = newValue;
    notifyListeners();
  }

  set statusNeedUpdate(String newValue) {
    _statusNeedUpdate = newValue;
    notifyListeners();
  }

  set statusBeforeUpdate(String newValue) {
    _statusBeforeUpdate = newValue;
    notifyListeners();
  }
}