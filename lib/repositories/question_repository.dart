/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : question_repository.dart
///
/// DESCRIPCIÓN:
/// CRUD de la tabla Questions.
/// ===============================================================

import '../database/database_constants.dart';
import '../models/question_model.dart';
import 'base_repository.dart';

class QuestionRepository extends BaseRepository {

  // INSERT
  Future<int> createQuestion(Question question) async {

    final db = await database;

    return await db.insert(
      DBConstants.questionsTable,
      question.toMap(),
    );

  }

  // SELECT ALL
  Future<List<Question>> getAllQuestions() async {

    final db = await database;

    final maps = await db.query(DBConstants.questionsTable);

    return maps
        .map((e) => Question.fromMap(e))
        .toList();

  }

  // Preguntas por simulacro
  Future<List<Question>> getQuestionsByMockExam(
      int mockExamId) async {

    final db = await database;

    final maps = await db.query(

      DBConstants.questionsTable,

      where: '${DBConstants.mockExamIdFk}=?',

      whereArgs: [mockExamId],

    );

    return maps

        .map((e) => Question.fromMap(e))

        .toList();

  }

  // Preguntas que aun no han sido analizadas con IA.
  // Retorna solo las que no tienen correct_alternative_id.
  Future<List<Question>> getQuestionsWithoutAnalysis() async {

    final db = await database;

    final maps = await db.query(

      DBConstants.questionsTable,

      where: '${DBConstants.correctAlternativeId} IS NULL',

    );

    return maps

        .map((e) => Question.fromMap(e))

        .toList();

  }

  // Actualiza una pregunta con el resultado del analisis de IA.
  Future<int> updateQuestionAnalysis(
      int questionId,
      int correctAlternativeId,
      String aiExplanation,
      ) async {

    final db = await database;

    return await db.update(

      DBConstants.questionsTable,

      {

        DBConstants.correctAlternativeId: correctAlternativeId,

        DBConstants.aiExplanation: aiExplanation,

      },

      where: '${DBConstants.questionId}=?',

      whereArgs: [questionId],

    );

  }
  Future<int> updateQuestion(
      Question question) async {

    final db = await database;

    return await db.update(

      DBConstants.questionsTable,

      question.toMap(),

      where: '${DBConstants.questionId}=?',

      whereArgs: [question.questionId],

    );

  }

  // DELETE
  Future<int> deleteQuestion(int id) async {

    final db = await database;

    return await db.delete(

      DBConstants.questionsTable,

      where: '${DBConstants.questionId}=?',

      whereArgs: [id],

    );

  }

}