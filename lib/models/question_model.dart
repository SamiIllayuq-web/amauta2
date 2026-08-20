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

  final double questionScore;

  final String? image;

  /// ID de la alternativa correcta. Null significa que aun no
  /// ha sido analizada con IA.
  final int? correctAlternativeId;

  /// Breve explicacion de la respuesta correcta, generada por IA.
  final String? aiExplanation;

  const Question({

    this.questionId,

    required this.mockExamId,

    required this.questionText,

    required this.explanation,

    this.questionScore = 1.0,

    this.image,

    this.correctAlternativeId,

    this.aiExplanation,

  });

  Map<String, dynamic> toMap() {

    return {

      DBConstants.questionId: questionId,

      DBConstants.mockExamIdFk: mockExamId,

      DBConstants.questionText: questionText,

      DBConstants.explanation: explanation,

      DBConstants.questionScore: questionScore,

      DBConstants.image: image,

      DBConstants.correctAlternativeId: correctAlternativeId,

      DBConstants.aiExplanation: aiExplanation,

    };

  }

  factory Question.fromMap(Map<String, dynamic> map) {

    return Question(

      questionId: map[DBConstants.questionId],

      mockExamId: map[DBConstants.mockExamIdFk],

      questionText: map[DBConstants.questionText],

      explanation: map[DBConstants.explanation] ?? '',

      questionScore: (map[DBConstants.questionScore] ?? 1.0).toDouble(),

      image: map[DBConstants.image],

      correctAlternativeId: map[DBConstants.correctAlternativeId],

      aiExplanation: map[DBConstants.aiExplanation],

    );

  }

  Question copyWith({

    int? questionId,

    int? mockExamId,

    String? questionText,

    String? explanation,

    double? questionScore,

    String? image,

    int? correctAlternativeId,

    String? aiExplanation,

  }) {

    return Question(

      questionId: questionId ?? this.questionId,

      mockExamId: mockExamId ?? this.mockExamId,

      questionText: questionText ?? this.questionText,

      explanation: explanation ?? this.explanation,

      questionScore: questionScore ?? this.questionScore,

      image: image ?? this.image,

      correctAlternativeId: correctAlternativeId ?? this.correctAlternativeId,

      aiExplanation: aiExplanation ?? this.aiExplanation,

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