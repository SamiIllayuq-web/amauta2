/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : user_repository.dart
///
/// DESCRIPCIÓN:
/// Repositorio encargado de administrar todas las operaciones
/// CRUD de la tabla Users.
///
/// RESPONSABILIDADES:
/// - Registrar usuarios.
/// - Obtener usuarios.
/// - Buscar usuario por email.
/// - Validar login.
/// - Actualizar usuario.
/// - Eliminar usuario.
/// ===============================================================

import '../database/database_constants.dart';
import '../models/user_model.dart';
import 'base_repository.dart';

class UserRepository extends BaseRepository {

  // ==========================================================
  // INSERT
  // Registra un nuevo usuario.
  // ==========================================================

  Future<int> createUser(User user) async {

    final db = await database;

    return await db.insert(
      DBConstants.usersTable,
      user.toMap(),
    );

  }

  // ==========================================================
  // SELECT
  // Obtiene todos los usuarios.
  // ==========================================================

  Future<List<User>> getAllUsers() async {

    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      DBConstants.usersTable,
      orderBy: DBConstants.userId,
    );

    return maps.map((map) => User.fromMap(map)).toList();

  }

  // ==========================================================
  // SELECT
  // Busca un usuario por email.
  // ==========================================================

  Future<User?> getUserByEmail(String email) async {

    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(

      DBConstants.usersTable,

      where: '${DBConstants.email} = ?',

      whereArgs: [email],

      limit: 1,

    );

    if (maps.isEmpty) {

      return null;

    }

    return User.fromMap(maps.first);

  }

  // ==========================================================
  // LOGIN
  // Verifica email y contraseña.
  // ==========================================================

  Future<User?> login({

    required String email,

    required String password,

  }) async {

    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(

      DBConstants.usersTable,

      where:
          '${DBConstants.email} = ? AND ${DBConstants.password} = ?',

      whereArgs: [

        email,

        password,

      ],

      limit: 1,

    );

    if (maps.isEmpty) {

      return null;

    }

    return User.fromMap(maps.first);

  }

  // ==========================================================
  // UPDATE
  // Actualiza un usuario.
  // ==========================================================

  Future<int> updateUser(User user) async {

    final db = await database;

    return await db.update(

      DBConstants.usersTable,

      user.toMap(),

      where: '${DBConstants.userId} = ?',

      whereArgs: [

        user.userId,

      ],

    );

  }

  // ==========================================================
  // DELETE
  // Elimina un usuario.
  // ==========================================================

  Future<int> deleteUser(int userId) async {

    final db = await database;

    return await db.delete(

      DBConstants.usersTable,

      where: '${DBConstants.userId} = ?',

      whereArgs: [

        userId,

      ],

    );

  }

}