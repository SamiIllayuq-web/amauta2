/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : question_model.dart
///
/// DESCRIPCIÓN:
/// Modelo que representa una pregunta de un simulacro.
/// ===============================================================

import '../database/database_constants.dart';

class Question {

  final int? questionId;
  final int mockExamId;
  final String questionText;
  final String explanation;

  const Question({

    this.questionId,

    required this.mockExamId,

    required this.questionText,

    required this.explanation,

  });

  Map<String, dynamic> toMap() {

    return {

      DBConstants.questionId: questionId,

      DBConstants.mockExamIdFk: mockExamId,

      DBConstants.questionText: questionText,

      DBConstants.explanation: explanation,

    };

  }

  factory Question.fromMap(Map<String, dynamic> map) {

    return Question(

      questionId: map[DBConstants.questionId],

      mockExamId: map[DBConstants.mockExamIdFk],

      questionText: map[DBConstants.questionText],

      explanation: map[DBConstants.explanation],

    );

  }

  Question copyWith({

    int? questionId,

    int? mockExamId,

    String? questionText,

    String? explanation,

  }) {

    return Question(

      questionId: questionId ?? this.questionId,

      mockExamId: mockExamId ?? this.mockExamId,

      questionText: questionText ?? this.questionText,

      explanation: explanation ?? this.explanation,

    );

  }

  @override
  String toString() {

    return '''
Question(
  questionId: $questionId,
  mockExamId: $mockExamId,
  questionText: $questionText
)
''';

  }

}