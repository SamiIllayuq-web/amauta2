/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : result_repository.dart
///
/// DESCRIPCIÓN:
/// CRUD de la tabla Results.
/// ===============================================================

import '../database/database_constants.dart';
import '../models/result_model.dart';
import '../models/result_with_exam_model.dart';
import 'base_repository.dart';

class ResultRepository extends BaseRepository {

  Future<int> createResult(Result result) async {
    final db = await database;
    return await db.insert(
      DBConstants.resultsTable,
      result.toMap(),
    );
  }

  Future<List<Result>> getAllResults() async {
    final db = await database;
    final maps = await db.query(DBConstants.resultsTable);
    return maps
        .map((e) => Result.fromMap(e))
        .toList();
  }

  // ==========================================================
  // Obtiene todos los resultados de un usuario.
  // ==========================================================

  Future<List<Result>> getResultsByUser(int userId) async {
    final db = await database;
    final maps = await db.query(
      DBConstants.resultsTable,
      where: '${DBConstants.userIdFk} = ?',
      whereArgs: [userId],
      orderBy: '${DBConstants.completedAt} DESC',
    );
    return maps
        .map((e) => Result.fromMap(e))
        .toList();
  }

  // ==========================================================
  // Obtiene resultados de un usuario con el título del examen (JOIN).
  // ==========================================================

  Future<List<ResultWithExam>> getResultsByUserWithExam(int userId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT
        r.${DBConstants.resultId},
        r.${DBConstants.userIdFk},
        r.${DBConstants.mockExamIdFk},
        m.${DBConstants.mockExamTitle},
        r.${DBConstants.finalScore},
        r.${DBConstants.correctAnswers},
        r.${DBConstants.incorrectAnswers},
        r.${DBConstants.elapsedTime},
        r.${DBConstants.completedAt}
      FROM ${DBConstants.resultsTable} r
      INNER JOIN ${DBConstants.mockExamsTable} m
        ON r.${DBConstants.mockExamIdFk} = m.${DBConstants.mockExamId}
      WHERE r.${DBConstants.userIdFk} = ?
      ORDER BY r.${DBConstants.completedAt} DESC
    ''', [userId]);

    return maps.map((e) => ResultWithExam.fromMap(e)).toList();
  }

  Future<int> deleteResult(int id) async {
    final db = await database;
    return await db.delete(
      DBConstants.resultsTable,
      where: '${DBConstants.resultId} = ?',
      whereArgs: [id],
    );
  }

  // ==========================================================
  // Obtiene un resultado por su ID.
  // ==========================================================

  Future<Result?> getResultById(int id) async {
    final db = await database;
    final maps = await db.query(
      DBConstants.resultsTable,
      where: '${DBConstants.resultId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Result.fromMap(maps.first);
  }

  // ==========================================================
  // UPDATE
  // Actualiza un resultado existente (score final + elapsed time).
  // ==========================================================

  Future<int> updateResult(Result result) async {
    final db = await database;
    return await db.update(
      DBConstants.resultsTable,
      result.toMap(),
      where: '${DBConstants.resultId} = ?',
      whereArgs: [result.resultId],
    );
  }

}
