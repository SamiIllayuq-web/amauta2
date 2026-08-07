/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : alternative_repository.dart
///
/// DESCRIPCIÓN:
/// CRUD de la tabla Alternatives.
/// ===============================================================

import '../database/database_constants.dart';
import '../models/alternative_model.dart';
import 'base_repository.dart';

class AlternativeRepository extends BaseRepository {

  // INSERT
  Future<int> createAlternative(
      Alternative alternative) async {

    final db = await database;

    return await db.insert(

      DBConstants.alternativesTable,

      alternative.toMap(),

    );

  }

  // SELECT ALL
  Future<List<Alternative>> getAllAlternatives() async {

    final db = await database;

    final maps = await db.query(
      DBConstants.alternativesTable,
    );

    return maps

        .map((e) => Alternative.fromMap(e))

        .toList();

  }

  // Alternativas de una pregunta
  Future<List<Alternative>> getAlternativesByQuestion(
      int questionId) async {

    final db = await database;

    final maps = await db.query(

      DBConstants.alternativesTable,

      where: '${DBConstants.questionIdFk}=?',

      whereArgs: [questionId],

    );

    return maps

        .map((e) => Alternative.fromMap(e))

        .toList();

  }

  // UPDATE
  Future<int> updateAlternative(
      Alternative alternative) async {

    final db = await database;

    return await db.update(

      DBConstants.alternativesTable,

      alternative.toMap(),

      where: '${DBConstants.alternativeId}=?',

      whereArgs: [

        alternative.alternativeId,

      ],

    );

  }

  // DELETE
  Future<int> deleteAlternative(int id) async {

    final db = await database;

    return await db.delete(

      DBConstants.alternativesTable,

      where: '${DBConstants.alternativeId}=?',

      whereArgs: [id],

    );

  }

}