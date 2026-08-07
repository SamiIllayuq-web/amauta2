/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : alternative_model.dart
///
/// DESCRIPCIÓN:
/// Modelo que representa una alternativa de una pregunta.
/// ===============================================================

import '../database/database_constants.dart';

class Alternative {

  final int? alternativeId;
  final int questionId;
  final String alternativeText;
  final bool isCorrect;

  const Alternative({

    this.alternativeId,

    required this.questionId,

    required this.alternativeText,

    required this.isCorrect,

  });

  Map<String, dynamic> toMap() {

    return {

      DBConstants.alternativeId: alternativeId,

      DBConstants.questionIdFk: questionId,

      DBConstants.alternativeText: alternativeText,

      DBConstants.isCorrect: isCorrect ? 1 : 0,

    };

  }

  factory Alternative.fromMap(Map<String, dynamic> map) {

    return Alternative(

      alternativeId: map[DBConstants.alternativeId],

      questionId: map[DBConstants.questionIdFk],

      alternativeText: map[DBConstants.alternativeText],

      isCorrect: map[DBConstants.isCorrect] == 1,

    );

  }

  Alternative copyWith({

    int? alternativeId,

    int? questionId,

    String? alternativeText,

    bool? isCorrect,

  }) {

    return Alternative(

      alternativeId: alternativeId ?? this.alternativeId,

      questionId: questionId ?? this.questionId,

      alternativeText: alternativeText ?? this.alternativeText,

      isCorrect: isCorrect ?? this.isCorrect,

    );

  }

  @override
  String toString() {

    return '''
Alternative(
  alternativeId: $alternativeId,
  questionId: $questionId,
  isCorrect: $isCorrect
)
''';

  }

}