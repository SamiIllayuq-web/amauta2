// ===============================================================
// PROYECTO : ADMISIÓN AMAUTA
// ARCHIVO  : admin_exam_manage_screen.dart
//
// DESCRIPCIÓN:
// Pantalla del administrador para gestionar los examenes
// y preguntas en el sistema.
//
// Muestra la lista de examenes con la cantidad de preguntas
// asociadas. Desde aqui se puede navegar a la gestion de
// preguntas de cada examen.
//
// FLUJO
//
// AdminDashboardScreen
//        |
//        ▼
// /admin/exams
//        |
//        ▼
// MockExamRepository.getAllMockExams()
//        |
//        ▼
// QuestionRepository.getQuestionsByMockExam(examId)
//        |
//        ▼
// Lista de examenes con cantidad de preguntas
//
// ===============================================================

library;

import 'package:flutter/material.dart';

import '../models/mock_exam_model.dart';
import '../models/question_model.dart';
import '../repositories/mock_exam_repository.dart';
import '../repositories/question_repository.dart';

// ===============================================================
// Pantalla principal de gestion de examenes.
// ===============================================================

class AdminExamManageScreen extends StatefulWidget {

  const AdminExamManageScreen({super.key});

  @override
  State<AdminExamManageScreen> createState() => _AdminExamManageScreenState();

}

class _AdminExamManageScreenState extends State<AdminExamManageScreen> {

  final MockExamRepository _mockExamRepository = MockExamRepository();
  final QuestionRepository _questionRepository = QuestionRepository();

  // Lista de examenes obtenidos de la base de datos.
  List<MockExam> _exams = [];

  // Cantidad de preguntas por cada examen.
  // La clave es el mockExamId y el valor es el total de preguntas.
  Map<int, int> _questionCounts = {};

  bool _isLoading = true;

  // ===============================================================
  // Carga todos los examenes y para cada uno cuenta
  // sus preguntas asociadas.
  // ===============================================================

  Future<void> _loadExams() async {

    final exams = await _mockExamRepository.getAllMockExams();

    // Contar preguntas por cada examen.
    final questionCounts = <int, int>{};
    for (final exam in exams) {
      if (exam.mockExamId != null) {
        final questions = await _questionRepository.getQuestionsByMockExam(
          exam.mockExamId!,
        );
        questionCounts[exam.mockExamId!] = questions.length;
      }
    }

    if (!mounted) return;

    setState(() {
      _exams = exams;
      _questionCounts = questionCounts;
      _isLoading = false;
    });

  }

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Examenes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _exams.isEmpty
              ? const Center(
                  child: Text(
                    'No hay examenes registrados.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _exams.length,
                  itemBuilder: (context, index) {
                    final exam = _exams[index];
                    final questionCount = _questionCounts[exam.mockExamId] ?? 0;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: const Icon(
                            Icons.quiz,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          exam.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(exam.description ?? ''),
                        trailing: Text(
                          '$questionCount preguntas',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        onTap: () {
                          // Navega a la pantalla de preguntas del examen.
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminExamQuestionsScreen(
                                mockExam: exam,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }

}

// ===============================================================
// Pantalla que lista las preguntas de un examen seleccionado.
// ===============================================================

class AdminExamQuestionsScreen extends StatefulWidget {

  final MockExam mockExam;

  const AdminExamQuestionsScreen({
    super.key,
    required this.mockExam,
  });

  @override
  State<AdminExamQuestionsScreen> createState() =>
      _AdminExamQuestionsScreenState();

}

class _AdminExamQuestionsScreenState
    extends State<AdminExamQuestionsScreen> {

  final QuestionRepository _questionRepository = QuestionRepository();

  List<Question> _questions = [];
  bool _isLoading = true;

  // ===============================================================
  // Carga las preguntas asociadas al examen seleccionado.
  // ===============================================================

  Future<void> _loadQuestions() async {
    final questions = await _questionRepository.getQuestionsByMockExam(
      widget.mockExam.mockExamId!,
    );
    if (!mounted) return;
    setState(() {
      _questions = questions;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mockExam.title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
              ? const Center(
                  child: Text(
                    'Este examen aun no tiene preguntas.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final question = _questions[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Numero de pregunta.
                            Text(
                              'Pregunta ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Texto de la pregunta.
                            Text(
                              question.questionText,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            // Area y tema.
                            // Question no tiene campo areaId ni topicId
                            // en el modelo actual.

                            Text(
                              'Exp: ${question.explanation.isNotEmpty ? question.explanation.substring(0, question.explanation.length > 30 ? 30 : question.explanation.length) : "Sin explicacion"}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

}
