/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : mock_exam_model.dart
///
/// DESCRIPCIÓN:
/// Modelo que representa un simulacro.
/// ===============================================================

import '../database/database_constants.dart';

class MockExam {

  final int? mockExamId;
  final int universityId;
  final int areaId;
  final String title;
  final String description;
  final int examYear;
  final int durationMinutes;
  final int totalQuestions;

  const MockExam({

    this.mockExamId,

    required this.universityId,

    required this.areaId,

    required this.title,

    required this.description,

    required this.examYear,

    required this.durationMinutes,

    required this.totalQuestions,

  });

  Map<String, dynamic> toMap() {

    return {

      DBConstants.mockExamId: mockExamId,

      DBConstants.universityIdFk: universityId,

      DBConstants.areaIdFk: areaId,

      DBConstants.mockExamTitle: title,

      DBConstants.mockExamDescription: description,

      DBConstants.examYear: examYear,

      DBConstants.durationMinutes: durationMinutes,

      DBConstants.totalQuestions: totalQuestions,

    };

  }

  factory MockExam.fromMap(Map<String, dynamic> map) {

    return MockExam(

      mockExamId: map[DBConstants.mockExamId],

      universityId: map[DBConstants.universityIdFk],

      areaId: map[DBConstants.areaIdFk],

      title: map[DBConstants.mockExamTitle],

      description: map[DBConstants.mockExamDescription],

      examYear: map[DBConstants.examYear],

      durationMinutes: map[DBConstants.durationMinutes],

      totalQuestions: map[DBConstants.totalQuestions],

    );

  }

  MockExam copyWith({

    int? mockExamId,
    int? universityId,
    int? areaId,
    String? title,
    String? description,
    int? examYear,
    int? durationMinutes,
    int? totalQuestions,

  }) {

    return MockExam(

      mockExamId: mockExamId ?? this.mockExamId,

      universityId: universityId ?? this.universityId,

      areaId: areaId ?? this.areaId,

      title: title ?? this.title,

      description: description ?? this.description,

      examYear: examYear ?? this.examYear,

      durationMinutes: durationMinutes ?? this.durationMinutes,

      totalQuestions: totalQuestions ?? this.totalQuestions,

    );

  }

}