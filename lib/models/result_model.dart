/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : result_model.dart
///
/// DESCRIPCIÓN:
/// Modelo que representa el resultado obtenido por un usuario
/// al finalizar un simulacro.
/// ===============================================================

import '../database/database_constants.dart';

class Result {

  final int? resultId;

  final int userId;

  final int mockExamId;

  final double finalScore;

  final int correctAnswers;

  final int incorrectAnswers;

  final int elapsedTime;

  final String completedAt;

  const Result({

    this.resultId,

    required this.userId,

    required this.mockExamId,

    required this.finalScore,

    required this.correctAnswers,

    required this.incorrectAnswers,

    required this.elapsedTime,

    required this.completedAt,

  });

  // ==========================================================
  // Convierte el objeto Result a un Map para SQLite.
  // ==========================================================

  Map<String, dynamic> toMap() {

    return {

      DBConstants.resultId: resultId,

      DBConstants.userIdFk: userId,

      DBConstants.mockExamIdFk: mockExamId,

      DBConstants.finalScore: finalScore,

      DBConstants.correctAnswers: correctAnswers,

      DBConstants.incorrectAnswers: incorrectAnswers,

      DBConstants.elapsedTime: elapsedTime,

      DBConstants.completedAt: completedAt,

    };

  }

  // ==========================================================
  // Convierte un Map proveniente de SQLite en un objeto Result.
  // ==========================================================

  factory Result.fromMap(Map<String, dynamic> map) {

    return Result(

      resultId: map[DBConstants.resultId],

      userId: map[DBConstants.userIdFk],

      mockExamId: map[DBConstants.mockExamIdFk],

      finalScore: (map[DBConstants.finalScore] as num).toDouble(),

      correctAnswers: map[DBConstants.correctAnswers],

      incorrectAnswers: map[DBConstants.incorrectAnswers],

      elapsedTime: map[DBConstants.elapsedTime],

      completedAt: map[DBConstants.completedAt],

    );

  }

  // ==========================================================
  // Permite crear una copia modificando únicamente algunos campos.
  // ==========================================================

  Result copyWith({

    int? resultId,

    int? userId,

    int? mockExamId,

    double? finalScore,

    int? correctAnswers,

    int? incorrectAnswers,

    int? elapsedTime,

    String? completedAt,

  }) {

    return Result(

      resultId: resultId ?? this.resultId,

      userId: userId ?? this.userId,

      mockExamId: mockExamId ?? this.mockExamId,

      finalScore: finalScore ?? this.finalScore,

      correctAnswers: correctAnswers ?? this.correctAnswers,

      incorrectAnswers: incorrectAnswers ?? this.incorrectAnswers,

      elapsedTime: elapsedTime ?? this.elapsedTime,

      completedAt: completedAt ?? this.completedAt,

    );

  }

  @override
  String toString() {

    return '''
Result(
  resultId: $resultId,
  userId: $userId,
  mockExamId: $mockExamId,
  finalScore: $finalScore,
  correctAnswers: $correctAnswers,
  incorrectAnswers: $incorrectAnswers,
  elapsedTime: $elapsedTime,
  completedAt: $completedAt
)
''';

  }

}