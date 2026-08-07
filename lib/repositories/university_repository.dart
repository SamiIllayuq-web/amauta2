/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : university_repository.dart
///
/// DESCRIPCIÓN:
/// CRUD de la tabla Universities.
/// ===============================================================

import '../database/database_constants.dart';
import '../models/university_model.dart';
import 'base_repository.dart';

class UniversityRepository extends BaseRepository {

  // INSERT
  Future<int> createUniversity(University university) async {

    final db = await database;

    return await db.insert(
      DBConstants.universitiesTable,
      university.toMap(),
    );

  }

  // SELECT ALL
  Future<List<University>> getAllUniversities() async {

    final db = await database;

    final maps = await db.query(
      DBConstants.universitiesTable,
      orderBy: DBConstants.universityName,
    );

    return maps
        .map((e) => University.fromMap(e))
        .toList();

  }

  // SELECT BY ID
  Future<University?> getUniversityById(int id) async {

    final db = await database;

    final maps = await db.query(

      DBConstants.universitiesTable,

      where: '${DBConstants.universityId} = ?',

      whereArgs: [id],

      limit: 1,

    );

    if (maps.isEmpty) return null;

    return University.fromMap(maps.first);

  }

  // UPDATE
  Future<int> updateUniversity(
      University university) async {

    final db = await database;

    return await db.update(

      DBConstants.universitiesTable,

      university.toMap(),

      where: '${DBConstants.universityId}=?',

      whereArgs: [

        university.universityId,

      ],

    );

  }

  // DELETE
  Future<int> deleteUniversity(int id) async {

    final db = await database;

    return await db.delete(

      DBConstants.universitiesTable,

      where: '${DBConstants.universityId}=?',

      whereArgs: [id],

    );

  }

}