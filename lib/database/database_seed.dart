/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : database_seed.dart
///
/// DESCRIPCIÓN:
/// Inserta los datos iniciales del sistema cuando SQLite crea
/// la base de datos por primera vez.
///
/// Este archivo se ejecuta únicamente desde DatabaseHelper
/// después de crear todas las tablas.
///
/// RESPONSABILIDADES:
/// - Insertar universidades.
/// - Insertar áreas.
/// - Insertar simulacros.
/// - Insertar preguntas.
/// - Insertar alternativas.
/// ===============================================================

import 'package:sqflite/sqflite.dart';

import 'database_constants.dart';

class DatabaseSeed {

  /// Constructor privado.
  DatabaseSeed._();

  /// ==========================================================
  /// Método principal.
  /// Ejecuta la inserción de todos los datos iniciales.
  /// ==========================================================

  static Future<void> initialize(Database database) async {

    await _insertUniversities(database);

    await _insertAreas(database);

    await _insertMockExams(database);

    await _insertQuestions(database);

    await _insertAlternatives(database);

  }

// ==========================================================
// Inserta las universidades iniciales del sistema.
//
// NOTA:
// Para el MVP solo utilizaremos dos universidades.
// Más adelante se podrán agregar más registros.
// ==========================================================

static Future<void> _insertUniversities(
  Database database,
) async {


  await database.insert(

    DBConstants.universitiesTable,

    {
      DBConstants.universityName: 'Universidad Nacional de Huancavelica',
      DBConstants.acronym: 'UNH',
    },

  );

  await database.insert(

    DBConstants.universitiesTable,

    {
      DBConstants.universityName: 'Universidad Nacional del Centro del Peru',
      DBConstants.acronym: 'UNCP',
    },

  );

}
// ==========================================================
// Inserta las áreas académicas.
// ==========================================================

static Future<void> _insertAreas(
  Database database,
) async {

  await database.insert(

    DBConstants.areasTable,

    {
      DBConstants.areaName: 'Systems Engineering',
      DBConstants.areaDescription:
          'Engineering and Technology',
    },

  );

  await database.insert(

    DBConstants.areasTable,

    {
      DBConstants.areaName: 'Civil Engineering',
      DBConstants.areaDescription:
          'Engineering and Technology',
    },

  );

}
// ==========================================================
// Inserta los simulacros iniciales.
// ==========================================================

static Future<void> _insertMockExams(
  Database database,
) async {

  // Simulacro UNH

  await database.insert(

    DBConstants.mockExamsTable,

    {

      DBConstants.universityIdFk: 1,

      DBConstants.areaIdFk: 1,

      DBConstants.mockExamTitle:
          'UNH Admission Mock Exam 2025',

      DBConstants.mockExamDescription:
          'General Admission Test',

      DBConstants.examYear: 2025,

      DBConstants.durationMinutes: 90,

      DBConstants.totalQuestions: 5,

    },

  );

  // Simulacro UNCP

  await database.insert(

    DBConstants.mockExamsTable,

    {

      DBConstants.universityIdFk: 2,

      DBConstants.areaIdFk: 1,

      DBConstants.mockExamTitle:
          'UNCP Admission Mock Exam 2025',

      DBConstants.mockExamDescription:
          'General Admission Test',

      DBConstants.examYear: 2025,

      DBConstants.durationMinutes: 90,

      DBConstants.totalQuestions: 5,

    },

  );

}
// ==========================================================
// Inserta las preguntas.
// ==========================================================

static Future<void> _insertQuestions(
  Database database,
) async {

  // ==========================
  // EXAMEN 1 - UNH
  // ==========================

  await database.insert(

    DBConstants.questionsTable,

    {

      DBConstants.mockExamIdFk: 1,

      DBConstants.questionText:
          'What is the capital city of Peru?',

      DBConstants.image: null,

      DBConstants.questionScore: 20,

      DBConstants.explanation:
          'Lima is the capital of Peru.',

    },

  );

  await database.insert(

    DBConstants.questionsTable,

    {

      DBConstants.mockExamIdFk: 1,

      DBConstants.questionText:
          'How many continents are there?',

      DBConstants.image: null,

      DBConstants.questionScore: 20,

      DBConstants.explanation:
          'There are seven continents.',

    },

  );

  await database.insert(

    DBConstants.questionsTable,

    {

      DBConstants.mockExamIdFk: 1,

      DBConstants.questionText:
          '2 + 2 = ?',

      DBConstants.image: null,

      DBConstants.questionScore: 20,

      DBConstants.explanation:
          'Basic arithmetic.',

    },

  );

  await database.insert(

    DBConstants.questionsTable,

    {

      DBConstants.mockExamIdFk: 1,

      DBConstants.questionText:
          'Who wrote Don Quixote?',

      DBConstants.image: null,

      DBConstants.questionScore: 20,

      DBConstants.explanation:
          'Miguel de Cervantes.',

    },

  );

  await database.insert(

    DBConstants.questionsTable,

    {

      DBConstants.mockExamIdFk: 1,

      DBConstants.questionText:
          'Which planet is known as the Red Planet?',

      DBConstants.image: null,

      DBConstants.questionScore: 20,

      DBConstants.explanation:
          'Mars is the Red Planet.',

    },

  );
  // ==========================
// EXAMEN 2 - UNCP
// ==========================

await database.insert(

  DBConstants.questionsTable,

  {

    DBConstants.mockExamIdFk: 2,

    DBConstants.questionText:
        'What is the capital of Peru?',

    DBConstants.image: null,

    DBConstants.questionScore: 20,

    DBConstants.explanation:
        'Lima is the capital city.',

  },

);

await database.insert(

  DBConstants.questionsTable,

  {

    DBConstants.mockExamIdFk: 2,

    DBConstants.questionText:
        'Which color is associated with danger?',

    DBConstants.image: null,

    DBConstants.questionScore: 20,

    DBConstants.explanation:
        'Red usually represents danger.',

  },

);

await database.insert(

  DBConstants.questionsTable,

  {

    DBConstants.mockExamIdFk: 2,

    DBConstants.questionText:
        '3 x 3 = ?',

    DBConstants.image: null,

    DBConstants.questionScore: 20,

    DBConstants.explanation:
        '3 multiplied by 3 equals 9.',

  },

);

await database.insert(

  DBConstants.questionsTable,

  {

    DBConstants.mockExamIdFk: 2,

    DBConstants.questionText:
        'Which is the largest ocean?',

    DBConstants.image: null,

    DBConstants.questionScore: 20,

    DBConstants.explanation:
        'The Pacific Ocean is the largest.',

  },

);

await database.insert(

  DBConstants.questionsTable,

  {

    DBConstants.mockExamIdFk: 2,

    DBConstants.questionText:
        'What gas do humans breathe to survive?',

    DBConstants.image: null,

    DBConstants.questionScore: 20,

    DBConstants.explanation:
        'Humans need oxygen.',

  },

);

}


// ==========================================================
// Inserta las alternativas de todas las preguntas.
// ==========================================================

static Future<void> _insertAlternatives(
  Database database,
) async {

  final alternatives = [

    // ==========================
    // Question 1
    // ==========================

    [1, 'Lima', 1],
    [1, 'Cusco', 0],
    [1, 'Arequipa', 0],
    [1, 'Piura', 0],

    // ==========================
    // Question 2
    // ==========================

    [2, 'Five', 0],
    [2, 'Six', 0],
    [2, 'Seven', 1],
    [2, 'Eight', 0],

    // ==========================
    // Question 3
    // ==========================

    [3, '3', 0],
    [3, '4', 1],
    [3, '5', 0],
    [3, '6', 0],

    // ==========================
    // Question 4
    // ==========================

    [4, 'William Shakespeare', 0],
    [4, 'Miguel de Cervantes', 1],
    [4, 'Mario Vargas Llosa', 0],
    [4, 'Pablo Neruda', 0],

    // ==========================
    // Question 5
    // ==========================

    [5, 'Earth', 0],
    [5, 'Mars', 1],
    [5, 'Jupiter', 0],
    [5, 'Venus', 0],

    // ==========================
    // Question 6
    // ==========================

    [6, 'Lima', 1],
    [6, 'Cusco', 0],
    [6, 'Tacna', 0],
    [6, 'Puno', 0],

    // ==========================
    // Question 7
    // ==========================

    [7, 'Blue', 0],
    [7, 'Green', 0],
    [7, 'Red', 1],
    [7, 'Yellow', 0],

    // ==========================
    // Question 8
    // ==========================

    [8, '8', 0],
    [8, '9', 1],
    [8, '10', 0],
    [8, '11', 0],

    // ==========================
    // Question 9
    // ==========================

    [9, 'Pacific', 1],
    [9, 'Atlantic', 0],
    [9, 'Indian', 0],
    [9, 'Arctic', 0],

    // ==========================
    // Question 10
    // ==========================

    [10, 'Oxygen', 1],
    [10, 'Hydrogen', 0],
    [10, 'Carbon', 0],
    [10, 'Nitrogen', 0],

  ];

  for (final item in alternatives) {

    await database.insert(

      DBConstants.alternativesTable,

      {

        DBConstants.questionIdFk: item[0],

        DBConstants.alternativeText: item[1],

        DBConstants.isCorrect: item[2],

      },

    );

  }

}
}