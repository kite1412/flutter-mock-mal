import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'global_constant.dart';

class History {
  final Logger _log = Logger();

  void saveSearchHistory(String search) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    List<String>? history = sp.getStringList(GlobalConstant.spSearchHistory);
    if (history != null) {
      if (!history.contains(search)) {
        history.add(search);
        sp.setStringList(GlobalConstant.spSearchHistory, history);
        _log.i("new history added: $search");
      } else {
        history.remove(search);
        history.add(search);
        sp.setStringList(GlobalConstant.spSearchHistory, history);
      }
    } else {
      sp.setStringList(GlobalConstant.spSearchHistory, [search]);
    }
  }

  Future<List<String>> getSearchHistory() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getStringList(GlobalConstant.spSearchHistory)?.reversed.toList() ?? [];
  }

  void delete(String search) async {
    final sp = await SharedPreferences.getInstance();
    final List<String> history = sp.getStringList(GlobalConstant.spSearchHistory)!
      ..remove(search);
    sp.setStringList(GlobalConstant.spSearchHistory, history);
    _log.i("history deleted: $search");
  }

  void deleteAll() async {
    final sp = await SharedPreferences.getInstance();
    sp.setStringList(GlobalConstant.spSearchHistory, []);
  }
}