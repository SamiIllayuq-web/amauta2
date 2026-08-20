import 'package:flutter/material.dart';

import '../models/comment_model.dart';
import '../models/mock_exam_model.dart';
import '../repositories/comment_repository.dart';
import '../repositories/mock_exam_repository.dart';
import '../repositories/user_repository.dart';
import '../services/preferences_service.dart';

class CommentsScreen extends StatefulWidget {

  const CommentsScreen({super.key});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();

}

class _CommentsScreenState extends State<CommentsScreen> {

  final CommentRepository _commentRepo = CommentRepository();
  final MockExamRepository _examRepo = MockExamRepository();

  List<Comment> _comments = [];
  List<MockExam> _exams = [];
  int? _selectedExamId;
  bool _loading = true;
  bool _posting = false;

  final _commentController = TextEditingController();
  final _scrollController = ScrollController();

  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ==========================================================
  // Cargar examenes y comentarios.
  // ==========================================================

  Future<void> _loadInitial() async {

    final userId = await PreferencesService.loadUserId();
    final exams = await _examRepo.getAllMockExams();
    final comments = await _commentRepo.getComments(examId: _selectedExamId);

    setState(() {
      _currentUserId = userId;
      _exams = exams;
      _comments = comments;
      _loading = false;
    });

  }

  // ==========================================================
  // Filtrar por examen.
  // ==========================================================

  Future<void> _filterByExam(int? examId) async {
    setState(() {
      _selectedExamId = examId;
      _loading = true;
    });
    final comments = await _commentRepo.getComments(examId: examId);
    setState(() {
      _comments = comments;
      _loading = false;
    });
  }

  // ==========================================================
  // Publicar comentario.
  // ==========================================================

  Future<void> _postComment() async {

    final text = _commentController.text.trim();
    if (text.isEmpty || _currentUserId == null) return;

    setState(() => _posting = true);

    final comment = Comment(
      userId: _currentUserId!,
      mockExamId: _selectedExamId,
      content: text,
      createdAt: DateTime.now().toIso8601String(),
    );

    await _commentRepo.createComment(comment);
    _commentController.clear();

    final comments = await _commentRepo.getComments(examId: _selectedExamId);
    setState(() {
      _comments = comments;
      _posting = false;
    });

    // Scroll al inicio
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

  }

  // ==========================================================
  // Eliminar comentario propio.
  // ==========================================================

  Future<void> _deleteComment(Comment comment) async {

    if (comment.userId != _currentUserId) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar comentario'),
        content: const Text('Estas seguro de eliminar este comentario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _commentRepo.deleteComment(comment.commentId!);

    setState(() {
      _comments = _comments.where((c) => c.commentId != comment.commentId).toList();
    });

  }

  // ==========================================================
  // Build.
  // ==========================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentarios'),
      ),

      body: Column(
        children: [

          // Filtro por examen
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade100,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Todos',
                    selected: _selectedExamId == null,
                    onSelected: () => _filterByExam(null),
                  ),
                  const SizedBox(width: 8),
                  ..._exams.map((exam) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: exam.title,
                      selected: _selectedExamId == exam.mockExamId,
                      onSelected: () => _filterByExam(exam.mockExamId),
                    ),
                  )),
                ],
              ),
            ),
          ),

          // Lista de comentarios
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'Sin comentarios todavia.',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: _comments.length,
                        itemBuilder: (ctx, index) {
                          final c = _comments[index];
                          final isOwn = c.userId == _currentUserId;
                          return _CommentCard(
                            comment: c,
                            isOwn: isOwn,
                            onDelete: isOwn ? () => _deleteComment(c) : null,
                          );
                        },
                      ),
          ),

          // Campo para nuevo comentario
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: _selectedExamId != null
                          ? 'Comenta sobre este examen...'
                          : 'Escribe un comentario general...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _posting ? null : _postComment,
                  icon: _posting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),

        ],
      ),

    );
  }

}

// ===============================================================
// Chip de filtro.
// ===============================================================

class _FilterChip extends StatelessWidget {

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue,
    );
  }

}

// ===============================================================
// Tarjeta de comentario.
// ===============================================================

class _CommentCard extends StatelessWidget {

  final Comment comment;
  final bool isOwn;
  final VoidCallback? onDelete;

  const _CommentCard({
    required this.comment,
    required this.isOwn,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Header: avatar + nombre + fecha
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue,
                  child: Text(
                    '${comment.userFirstName?[0] ?? '?'}${comment.userLastName?[0] ?? ''}'.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${comment.userFirstName} ${comment.userLastName}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      if (comment.examTitle != null)
                        Text(
                          comment.examTitle!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isOwn && onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: Colors.red.shade400,
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Contenido
            Text(comment.content),

            const SizedBox(height: 4),

            // Fecha
            Text(
              _formatDate(comment.createdAt),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),

          ],
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso.substring(0, 10);
    }
  }

}
