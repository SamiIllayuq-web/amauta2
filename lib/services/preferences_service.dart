import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {

  static const String historyKey =
      "exam_history";

  static Future<void> saveHistory(
      List<String> history) async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setStringList(
      historyKey,
      history,
    );
  }

  static Future<List<String>>
      loadHistory() async {
        

    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getStringList(
          historyKey,
        ) ??
        [];
  }

  static Future<int> totalExams() async {

  final history =
      await loadHistory();

  return history.length;
}

static Future<String> lastExam() async {

  final history =
      await loadHistory();

  if (history.isEmpty) {
    return "Sin simulacros";
  }

  return history.last;
}
}