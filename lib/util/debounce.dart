import 'dart:async';

class Debounce {
  Timer? _debounce;
  int durationInMilli;

  Debounce({required this.durationInMilli});

  void call(void Function() callback) {
    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: durationInMilli), callback);
  }

  void dispose() {
    _debounce?.cancel();
  }
}