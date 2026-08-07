/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : preferences_service.dart
///
/// DESCRIPCIÓN:
/// Servicio encargado de almacenar información sencilla utilizando
/// SharedPreferences.
///
/// RESPONSABILIDADES:
/// - Mantener la sesión del usuario.
/// - Guardar información temporal.
/// - (Temporalmente) mantener el historial mientras migramos todo
///   hacia SQLite.
/// ===============================================================

import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {

  // ==========================================================
  // CLAVES UTILIZADAS EN SHARED PREFERENCES
  // ==========================================================

  static const String historyKey = "exam_history";

  // Usuario que inició sesión
  static const String userIdKey = "current_user_id";

  // ==========================================================
  // HISTORIAL (Temporal)
  // ==========================================================

  static Future<void> saveHistory(
    List<String> history,
  ) async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setStringList(
      historyKey,
      history,
    );

  }

  static Future<List<String>> loadHistory() async {

    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getStringList(historyKey) ?? [];

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

  // ==========================================================
  // SESIÓN DEL USUARIO
  // ==========================================================

  /// Guarda el ID del usuario que inició sesión.

  static Future<void> saveUserId(
    int userId,
  ) async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setInt(
      userIdKey,
      userId,
    );

  }

  // ==========================================================
  // Obtiene el ID del usuario actual.
  // Devuelve NULL si no existe sesión.
  // ==========================================================

  static Future<int?> loadUserId() async {

    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getInt(
      userIdKey,
    );

  }

  // ==========================================================
  // Cierra la sesión eliminando el usuario almacenado.
  // ==========================================================

  static Future<void> clearUserId() async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(
      userIdKey,
    );

  }

}