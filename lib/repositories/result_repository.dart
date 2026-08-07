/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : result_repository.dart
///
/// DESCRIPCIÓN:
/// CRUD de la tabla Results.
/// ===============================================================

import '../database/database_constants.dart';
import '../models/result_model.dart';
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

Future<List<Result>> getResultsByUser(
  int userId,
) async {

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


  Future<int> deleteResult(int id) async {

    final db = await database;

    return await db.delete(

      DBConstants.resultsTable,

      where: '${DBConstants.resultId}=?',

      whereArgs: [id],

    );

  }

}