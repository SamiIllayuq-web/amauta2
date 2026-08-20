/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : comment_model.dart
///
/// DESCRIPCIÓN:
/// Modelo que representa un comentario en la comunidad.
/// ===============================================================

import '../database/database_constants.dart';

class Comment {

  final int? commentId;
  final int userId;
  final int? mockExamId;
  final String content;
  final String createdAt;

  // Para mostrar en la UI (join)
  final String? userFirstName;
  final String? userLastName;
  final String? examTitle;

  const Comment({
    this.commentId,
    required this.userId,
    this.mockExamId,
    required this.content,
    required this.createdAt,
    this.userFirstName,
    this.userLastName,
    this.examTitle,
  });

  Map<String, dynamic> toMap() {
    return {
      DBConstants.commentId: commentId,
      DBConstants.userIdFk: userId,
      DBConstants.mockExamIdFk: mockExamId,
      DBConstants.commentContent: content,
      DBConstants.createdAt: createdAt,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      commentId: map[DBConstants.commentId],
      userId: map[DBConstants.userIdFk],
      mockExamId: map[DBConstants.mockExamIdFk],
      content: map[DBConstants.commentContent],
      createdAt: map[DBConstants.createdAt],
      userFirstName: map['first_name'],
      userLastName: map['last_name'],
      examTitle: map['exam_title'],
    );
  }

  Comment copyWith({
    int? commentId,
    int? userId,
    int? mockExamId,
    String? content,
    String? createdAt,
    String? userFirstName,
    String? userLastName,
    String? examTitle,
  }) {
    return Comment(
      commentId: commentId ?? this.commentId,
      userId: userId ?? this.userId,
      mockExamId: mockExamId ?? this.mockExamId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      userFirstName: userFirstName ?? this.userFirstName,
      userLastName: userLastName ?? this.userLastName,
      examTitle: examTitle ?? this.examTitle,
    );
  }

}
