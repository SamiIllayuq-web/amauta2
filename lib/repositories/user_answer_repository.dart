/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : user_answer_repository.dart
///
/// DESCRIPCIÓN:
/// CRUD de la tabla User Answers.
/// ===============================================================

import '../database/database_constants.dart';
import '../models/user_answer_model.dart';
import 'base_repository.dart';

class UserAnswerRepository extends BaseRepository {

  Future<int> createUserAnswer(
      UserAnswer answer) async {

    final db = await database;

    return await db.insert(

      DBConstants.userAnswersTable,

      answer.toMap(),

    );

  }

  // Respuestas del usuario con calculo de isCorrect desde alternatives.
  // El campo isCorrect en user_answers no existe en la tabla,
  // se determina aqui via JOIN.
  Future<List<UserAnswer>> getUserAnswersWithCorrectness(
      int resultId) async {

    final db = await database;

    final maps = await db.rawQuery('''
      SELECT ua.*, a.is_correct
      FROM ${DBConstants.userAnswersTable} ua
      JOIN ${DBConstants.alternativesTable} a
        ON ua.alternative_id = a.alternative_id
      WHERE ua.result_id = ?
    ''', [resultId]);

    return maps.map((e) {
      return UserAnswer(
        userAnswerId: e['user_answer_id'] as int?,
        resultId: e['result_id'] as int,
        questionId: e['question_id'] as int,
        selectedAlternativeId: e['alternative_id'] as int,
        isCorrect: (e['is_correct'] as int) == 1,
      );
    }).toList();

  }

  Future<List<UserAnswer>> getAllUserAnswers() async {

    final db = await database;

    final maps = await db.query(
      DBConstants.userAnswersTable,
    );

    return maps

        .map((e) => UserAnswer.fromMap(e))

        .toList();

  }

  Future<int> deleteUserAnswer(int id) async {

    final db = await database;

    return await db.delete(

      DBConstants.userAnswersTable,

      where: '${DBConstants.userAnswerId}=?',

      whereArgs: [id],

    );

  }

}