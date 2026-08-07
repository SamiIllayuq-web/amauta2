/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : base_repository.dart
///
/// DESCRIPCIÓN:
/// Repositorio base del proyecto.
///
/// Centraliza el acceso a la base de datos SQLite para que todos
/// los Repository reutilicen la misma conexión sin duplicar código.
///
/// BENEFICIOS:
/// - Evita repetir código.
/// - Facilita el mantenimiento.
/// - Sigue una arquitectura limpia.
/// ===============================================================

import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';

abstract class BaseRepository {

  /// Obtiene la instancia de la base de datos.
  Future<Database> get database async {
    return await DatabaseHelper.instance.database;
  }

}