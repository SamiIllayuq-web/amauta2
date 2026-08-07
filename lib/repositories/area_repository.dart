/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : area_repository.dart
///
/// DESCRIPCIÓN:
/// CRUD de la tabla Areas.
/// ===============================================================

import '../database/database_constants.dart';
import '../models/area_model.dart';
import 'base_repository.dart';

class AreaRepository extends BaseRepository {

  // INSERT
  Future<int> createArea(Area area) async {

    final db = await database;

    return await db.insert(

      DBConstants.areasTable,

      area.toMap(),

    );

  }

  // SELECT ALL
  Future<List<Area>> getAllAreas() async {

    final db = await database;

    final maps = await db.query(

      DBConstants.areasTable,

      orderBy: DBConstants.areaName,

    );

    return maps

        .map((e) => Area.fromMap(e))

        .toList();

  }

  // SELECT BY ID
  Future<Area?> getAreaById(int id) async {

    final db = await database;

    final maps = await db.query(

      DBConstants.areasTable,

      where: '${DBConstants.areaId}=?',

      whereArgs: [id],

      limit: 1,

    );

    if (maps.isEmpty) return null;

    return Area.fromMap(maps.first);

  }

  // UPDATE
  Future<int> updateArea(Area area) async {

    final db = await database;

    return await db.update(

      DBConstants.areasTable,

      area.toMap(),

      where: '${DBConstants.areaId}=?',

      whereArgs: [

        area.areaId,

      ],

    );

  }

  // DELETE
  Future<int> deleteArea(int id) async {

    final db = await database;

    return await db.delete(

      DBConstants.areasTable,

      where: '${DBConstants.areaId}=?',

      whereArgs: [

        id,

      ],

    );

  }

}