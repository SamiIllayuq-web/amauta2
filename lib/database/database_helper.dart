/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : database_helper.dart
///
/// DESCRIPCIÓN:
/// Este archivo administra la conexión con la base de datos SQLite.
/// Implementa el patrón Singleton para garantizar que exista una
/// única instancia de la base de datos durante toda la ejecución
/// de la aplicación.
///
/// RESPONSABILIDADES:
/// - Crear la base de datos.
/// - Abrir la conexión.
/// - Inicializar SQLite.
/// - Gestionar futuras migraciones.
/// - Crear las tablas del sistema.
///
/// AUTOR:
/// David Sedano Huamani
///
/// FECHA:
/// Julio 2026
/// ===============================================================

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'database_constants.dart';

class DatabaseHelper {
  // ==========================================================
  // Implementación del patrón Singleton
  // ==========================================================

  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  // ==========================================================
  // Instancia privada de la base de datos
  // ==========================================================

  static Database? _database;

  // ==========================================================
  // Getter público para acceder a la base de datos.
  // Si la base de datos aún no existe, se inicializa.
  // ==========================================================

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initializeDatabase();
    return _database!;
  }

  // ==========================================================
  // Inicializa la base de datos SQLite.
  // ==========================================================

  Future<Database> _initializeDatabase() async {
    final String databasePath = await getDatabasesPath();

    final String path = join(
      databasePath,
      DBConstants.databaseName,
    );

    return await openDatabase(
      path,
      version: DBConstants.databaseVersion,

      onCreate: _onCreate,

      onUpgrade: _onUpgrade,
    );
  }

  // ==========================================================
  // Se ejecuta únicamente la primera vez que la aplicación crea
  // la base de datos.
  // ==========================================================

  // ==========================================================
// Se ejecuta únicamente la primera vez que se crea
// la base de datos.
// ==========================================================

Future<void> _onCreate(
  Database database,
  int version,
) async {

  print('==============================');
  print('Creando Base de Datos SQLite...');
  print('==============================');

  await _createUsersTable(database);
  await _createUniversitiesTable(database);
  await _createAreasTable(database);
  await _createMockExamsTable(database);
  await _createQuestionsTable(database);
  await _createAlternativesTable(database);
  await _createResultsTable(database);
  await _createUserAnswersTable(database);

  print('==============================');
  print('Base de Datos creada correctamente');
  print('8 tablas creadas con éxito');
  print('==============================');

}
  // ==========================================================
  // Se ejecutará cuando aumentemos la versión de la base de datos.
  // Permitirá realizar migraciones sin perder información.
  // ==========================================================

  Future<void> _onUpgrade(
    Database database,
    int oldVersion,
    int newVersion,
  ) async {

    // Aquí implementaremos futuras migraciones.

  }

  // ==========================================================
// Crea la tabla de usuarios.
// ==========================================================

// ==========================================================
// Crea la tabla de usuarios.
// ==========================================================

Future<void> _createUsersTable(Database database) async {

  await database.execute('''

    CREATE TABLE ${DBConstants.usersTable}(

      ${DBConstants.userId} INTEGER PRIMARY KEY AUTOINCREMENT,

      ${DBConstants.firstName} TEXT NOT NULL,

      ${DBConstants.lastName} TEXT NOT NULL,

      ${DBConstants.email} TEXT NOT NULL UNIQUE,

      ${DBConstants.password} TEXT NOT NULL,

      ${DBConstants.createdAt} TEXT NOT NULL

    )

  ''');

}


// ==========================================================
// Crea la tabla de universidades.
// ==========================================================

Future<void> _createUniversitiesTable(Database database) async {

  await database.execute('''

    CREATE TABLE ${DBConstants.universitiesTable}(

      ${DBConstants.universityId} INTEGER PRIMARY KEY AUTOINCREMENT,

      ${DBConstants.universityName} TEXT NOT NULL,

      ${DBConstants.acronym} TEXT NOT NULL

    )

  ''');

}


// ==========================================================
// Crea la tabla de áreas académicas.
// ==========================================================

Future<void> _createAreasTable(Database database) async {

  await database.execute('''

    CREATE TABLE ${DBConstants.areasTable}(

      ${DBConstants.areaId} INTEGER PRIMARY KEY AUTOINCREMENT,

      ${DBConstants.areaName} TEXT NOT NULL,

      ${DBConstants.areaDescription} TEXT

    )

  ''');

}




// ==========================================================
// Crea la tabla de simulacros.
// ==========================================================

Future<void> _createMockExamsTable(Database database) async {

  await database.execute('''

    CREATE TABLE ${DBConstants.mockExamsTable}(

      ${DBConstants.mockExamId} INTEGER PRIMARY KEY AUTOINCREMENT,

      ${DBConstants.universityIdFk} INTEGER NOT NULL,

      ${DBConstants.areaIdFk} INTEGER NOT NULL,

      ${DBConstants.mockExamTitle} TEXT NOT NULL,

      ${DBConstants.mockExamDescription} TEXT,

      ${DBConstants.examYear} INTEGER NOT NULL,

      ${DBConstants.durationMinutes} INTEGER NOT NULL,

      ${DBConstants.totalQuestions} INTEGER NOT NULL,

      FOREIGN KEY (${DBConstants.universityIdFk})
        REFERENCES ${DBConstants.universitiesTable}(${DBConstants.universityId}),

      FOREIGN KEY (${DBConstants.areaIdFk})
        REFERENCES ${DBConstants.areasTable}(${DBConstants.areaId})

    )

  ''');

}



// ==========================================================
// Crea la tabla de preguntas.
// ==========================================================

Future<void> _createQuestionsTable(Database database) async {

  await database.execute('''

    CREATE TABLE ${DBConstants.questionsTable}(

      ${DBConstants.questionId} INTEGER PRIMARY KEY AUTOINCREMENT,

      ${DBConstants.mockExamIdFk} INTEGER NOT NULL,

      ${DBConstants.questionText} TEXT NOT NULL,

      ${DBConstants.image} TEXT,

      ${DBConstants.questionScore} REAL NOT NULL,

      FOREIGN KEY (${DBConstants.mockExamIdFk})
        REFERENCES ${DBConstants.mockExamsTable}(${DBConstants.mockExamId})

    )

  ''');

}

// ==========================================================
// Crea la tabla de alternativas.
// ==========================================================

Future<void> _createAlternativesTable(Database database) async {

  await database.execute('''

    CREATE TABLE ${DBConstants.alternativesTable}(

      ${DBConstants.alternativeId} INTEGER PRIMARY KEY AUTOINCREMENT,

      ${DBConstants.questionIdFk} INTEGER NOT NULL,

      ${DBConstants.alternativeText} TEXT NOT NULL,

      ${DBConstants.isCorrect} INTEGER NOT NULL,

      FOREIGN KEY (${DBConstants.questionIdFk})
        REFERENCES ${DBConstants.questionsTable}(${DBConstants.questionId})

    )

  ''');

}



// ==========================================================
// Crea la tabla de resultados.
// ==========================================================

Future<void> _createResultsTable(Database database) async {

  await database.execute('''

    CREATE TABLE ${DBConstants.resultsTable}(

      ${DBConstants.resultId} INTEGER PRIMARY KEY AUTOINCREMENT,

      ${DBConstants.userIdFk} INTEGER NOT NULL,

      ${DBConstants.mockExamIdResultFk} INTEGER NOT NULL,

      ${DBConstants.correctAnswers} INTEGER NOT NULL,

      ${DBConstants.incorrectAnswers} INTEGER NOT NULL,

      ${DBConstants.finalScore} REAL NOT NULL,

      ${DBConstants.elapsedTime} INTEGER NOT NULL,

      ${DBConstants.completedAt} TEXT NOT NULL,

      FOREIGN KEY (${DBConstants.userIdFk})
        REFERENCES ${DBConstants.usersTable}(${DBConstants.userId}),

      FOREIGN KEY (${DBConstants.mockExamIdResultFk})
        REFERENCES ${DBConstants.mockExamsTable}(${DBConstants.mockExamId})

    )

  ''');

}



// ==========================================================
// Crea la tabla de respuestas del usuario.
// ==========================================================

Future<void> _createUserAnswersTable(Database database) async {

  await database.execute('''

    CREATE TABLE ${DBConstants.userAnswersTable}(

      ${DBConstants.userAnswerId} INTEGER PRIMARY KEY AUTOINCREMENT,

      ${DBConstants.resultIdFk} INTEGER NOT NULL,

      ${DBConstants.questionIdResultFk} INTEGER NOT NULL,

      ${DBConstants.alternativeIdFk} INTEGER NOT NULL,

      FOREIGN KEY (${DBConstants.resultIdFk})
        REFERENCES ${DBConstants.resultsTable}(${DBConstants.resultId}),

      FOREIGN KEY (${DBConstants.questionIdResultFk})
        REFERENCES ${DBConstants.questionsTable}(${DBConstants.questionId}),

      FOREIGN KEY (${DBConstants.alternativeIdFk})
        REFERENCES ${DBConstants.alternativesTable}(${DBConstants.alternativeId})

    )

  ''');

}












}