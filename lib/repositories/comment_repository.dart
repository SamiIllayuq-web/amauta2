/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : comment_repository.dart
///
/// DESCRIPCIÓN:
/// CRUD de la tabla Comments.
/// ===============================================================

import '../database/database_constants.dart';
import '../models/comment_model.dart';
import 'base_repository.dart';

class CommentRepository extends BaseRepository {

  // ==========================================================
  // CREATE
  // ==========================================================

  Future<int> createComment(Comment comment) async {
    final db = await database;
    return await db.insert(
      DBConstants.commentsTable,
      comment.toMap(),
    );
  }

  // ==========================================================
  // READ ALL con join para mostrar nombre de usuario y titulo de examen.
  // Filtra por examId si se especifica.
  // ==========================================================

  Future<List<Comment>> getComments({int? examId}) async {
    final db = await database;

    String sql = '''
      SELECT
        c.${DBConstants.commentId},
        c.${DBConstants.userIdFk},
        c.${DBConstants.mockExamIdFk},
        c.${DBConstants.commentContent},
        c.${DBConstants.createdAt},
        u.${DBConstants.firstName} as first_name,
        u.${DBConstants.lastName} as last_name,
        m.${DBConstants.mockExamTitle} as exam_title
      FROM ${DBConstants.commentsTable} c
      INNER JOIN ${DBConstants.usersTable} u
        ON c.${DBConstants.userIdFk} = u.${DBConstants.userId}
      LEFT JOIN ${DBConstants.mockExamsTable} m
        ON c.${DBConstants.mockExamIdFk} = m.${DBConstants.mockExamId}
    ''';

    if (examId != null) {
      sql += ' WHERE c.${DBConstants.mockExamIdFk} = ?';
      sql += ' ORDER BY c.${DBConstants.createdAt} DESC';
      final maps = await db.rawQuery(sql, [examId]);
      return maps.map((e) => Comment.fromMap(e)).toList();
    } else {
      sql += ' ORDER BY c.${DBConstants.createdAt} DESC';
      final maps = await db.rawQuery(sql);
      return maps.map((e) => Comment.fromMap(e)).toList();
    }
  }

  // ==========================================================
  // DELETE
  // ==========================================================

  Future<int> deleteComment(int id) async {
    final db = await database;
    return await db.delete(
      DBConstants.commentsTable,
      where: '${DBConstants.commentId} = ?',
      whereArgs: [id],
    );
  }

}
