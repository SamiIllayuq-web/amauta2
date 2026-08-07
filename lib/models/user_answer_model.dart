/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : user_answer_model.dart
///
/// DESCRIPCIÓN:
/// Modelo que representa la respuesta de un usuario para una
/// pregunta específica.
/// ===============================================================

import '../database/database_constants.dart';

class UserAnswer {

  final int? userAnswerId;
  final int resultId;
  final int questionId;
  final int selectedAlternativeId;
  final bool isCorrect;

  const UserAnswer({

    this.userAnswerId,

    required this.resultId,

    required this.questionId,

    required this.selectedAlternativeId,

    required this.isCorrect,

  });

  Map<String, dynamic> toMap() {

    return {

      DBConstants.userAnswerId: userAnswerId,

      DBConstants.resultIdFk: resultId,

      DBConstants.questionIdFk: questionId,

      DBConstants.alternativeIdFk: selectedAlternativeId,

      DBConstants.isCorrect: isCorrect ? 1 : 0,

    };

  }

  factory UserAnswer.fromMap(Map<String, dynamic> map) {

    return UserAnswer(

      userAnswerId: map[DBConstants.userAnswerId],

      resultId: map[DBConstants.resultIdFk],

      questionId: map[DBConstants.questionIdFk],

      selectedAlternativeId: map[DBConstants.alternativeIdFk],

      isCorrect: map[DBConstants.isCorrect] == 1,

    );

  }

  UserAnswer copyWith({

    int? userAnswerId,

    int? resultId,

    int? questionId,

    int? selectedAlternativeId,

    bool? isCorrect,

  }) {

    return UserAnswer(

      userAnswerId: userAnswerId ?? this.userAnswerId,

      resultId: resultId ?? this.resultId,

      questionId: questionId ?? this.questionId,

      selectedAlternativeId: selectedAlternativeId ?? this.selectedAlternativeId,

      isCorrect: isCorrect ?? this.isCorrect,

    );

  }

  @override
  String toString() {

    return '''
UserAnswer(
  userAnswerId: $userAnswerId,
  questionId: $questionId,
  isCorrect: $isCorrect
)
''';

  }

}