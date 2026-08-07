/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : mock_exam_repository.dart
///
/// DESCRIPCIÓN:
/// CRUD de la tabla Mock Exams.
/// ===============================================================

import '../database/database_constants.dart';
import '../models/mock_exam_model.dart';
import 'base_repository.dart';

class MockExamRepository extends BaseRepository {

  // INSERT
  Future<int> createMockExam(MockExam exam) async {

    final db = await database;

    return await db.insert(
      DBConstants.mockExamsTable,
      exam.toMap(),
    );

  }

  // SELECT ALL
  Future<List<MockExam>> getAllMockExams() async {

    final db = await database;

    final maps = await db.query(
      DBConstants.mockExamsTable,
      orderBy: DBConstants.mockExamTitle,
    );

    return maps
        .map((e) => MockExam.fromMap(e))
        .toList();

  }

  // SELECT BY ID
  Future<MockExam?> getMockExamById(int id) async {

    final db = await database;

    final maps = await db.query(

      DBConstants.mockExamsTable,

      where: '${DBConstants.mockExamId}=?',

      whereArgs: [id],

      limit: 1,

    );

    if (maps.isEmpty) return null;

    return MockExam.fromMap(maps.first);

  }

  // UPDATE
  Future<int> updateMockExam(MockExam exam) async {

    final db = await database;

    return await db.update(

      DBConstants.mockExamsTable,

      exam.toMap(),

      where: '${DBConstants.mockExamId}=?',

      whereArgs: [exam.mockExamId],

    );

  }

  // DELETE
  Future<int> deleteMockExam(int id) async {

    final db = await database;

    return await db.delete(

      DBConstants.mockExamsTable,

      where: '${DBConstants.mockExamId}=?',

      whereArgs: [id],

    );

  }

}