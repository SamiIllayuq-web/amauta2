/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : user_model.dart
///
/// DESCRIPCIÓN:
/// Modelo que representa un usuario dentro de la aplicación.
/// Cada objeto User corresponde a un registro de la tabla Users
/// en la base de datos SQLite.
/// ===============================================================

import '../database/database_constants.dart';

class User {

  // ==========================================================
  // Atributos
  // ==========================================================

  final int? userId;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String createdAt;
  final String role;

  // ==========================================================
  // Constructor
  // ==========================================================

  const User({

    this.userId,

    required this.firstName,

    required this.lastName,

    required this.email,

    required this.password,

    required this.createdAt,

    required this.role,

  });

  // ==========================================================
  // Convierte un objeto User en un Map.
  // Se utiliza para INSERT y UPDATE en SQLite.
  // ==========================================================

  Map<String, dynamic> toMap() {

    return {

      DBConstants.userId: userId,

      DBConstants.firstName: firstName,

      DBConstants.lastName: lastName,

      DBConstants.email: email,

      DBConstants.password: password,

      DBConstants.createdAt: createdAt,

      DBConstants.role: role,

    };

  }

  // ==========================================================
  // Convierte un Map obtenido desde SQLite en un objeto User.
  // Se utiliza para SELECT.
  // ==========================================================

  factory User.fromMap(Map<String, dynamic> map) {

    return User(

      userId: map[DBConstants.userId],

      firstName: map[DBConstants.firstName],

      lastName: map[DBConstants.lastName],

      email: map[DBConstants.email],

      password: map[DBConstants.password],

      createdAt: map[DBConstants.createdAt],

      role: map[DBConstants.role] ?? DBConstants.rolePostulante,

    );

  }

  // ==========================================================
  // Permite crear una copia del objeto modificando únicamente
  // los atributos necesarios.
  // ==========================================================

  User copyWith({
    int? userId,
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? createdAt,
    String? role,
  }) {
    return User(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
    );
  }

  // ==========================================================
  // Representación del objeto para depuración.
  // ==========================================================

  @override
  String toString() {

    return '''
User(
  userId: $userId,
  firstName: $firstName,
  lastName: $lastName,
  email: $email,
  createdAt: $createdAt
)
''';

  }

}