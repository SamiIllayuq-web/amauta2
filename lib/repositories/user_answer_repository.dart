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