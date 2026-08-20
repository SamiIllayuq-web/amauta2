/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : result_with_exam_model.dart
///
/// DESCRIPCIÓN:
/// DTO que combina Result + titulo del examen para ProgressScreen.
/// ===============================================================

import '../database/database_constants.dart';
import '../models/result_model.dart';

class ResultWithExam {

  final int? resultId;
  final int userId;
  final int mockExamId;
  final String examTitle;
  final double finalScore;
  final int correctAnswers;
  final int incorrectAnswers;
  final int elapsedTime;
  final String completedAt;

  const ResultWithExam({

    this.resultId,

    required this.userId,

    required this.mockExamId,

    required this.examTitle,

    required this.finalScore,

    required this.correctAnswers,

    required this.incorrectAnswers,

    required this.elapsedTime,

    required this.completedAt,

  });

  /// Construye ResultWithExam desde un Map con JOIN.
  factory ResultWithExam.fromMap(Map<String, dynamic> map) {

    return ResultWithExam(

      resultId: map[DBConstants.resultId],

      userId: map[DBConstants.userIdFk],

      mockExamId: map[DBConstants.mockExamIdFk],

      examTitle: map[DBConstants.mockExamTitle] ?? 'Examen',

      finalScore: (map[DBConstants.finalScore] as num).toDouble(),

      correctAnswers: map[DBConstants.correctAnswers],

      incorrectAnswers: map[DBConstants.incorrectAnswers],

      elapsedTime: map[DBConstants.elapsedTime],

      completedAt: map[DBConstants.completedAt],

    );

  }

}
