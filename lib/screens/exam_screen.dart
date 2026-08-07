/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : exam_screen.dart
///
/// DESCRIPCIÓN:
/// Pantalla encargada de ejecutar un simulacro.
///
/// FLUJO:
///
/// CatalogScreen
///        │
///        ▼
/// MockExam ID
///        │
///        ▼
/// QuestionRepository
///        │
///        ▼
/// Questions
///        │
///        ▼
/// AlternativeRepository
///        │
///        ▼
/// Alternatives
///        │
///        ▼
/// Usuario responde
///        │
///        ▼
/// Score
///        │
///        ▼
/// ResultScreen
///
/// ===============================================================

import 'package:flutter/material.dart';

import '../models/question_model.dart';
import '../models/alternative_model.dart';

import '../repositories/question_repository.dart';
import '../repositories/alternative_repository.dart';

class ExamScreen extends StatefulWidget {

  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() =>
      _ExamScreenState();

}

class _ExamScreenState extends State<ExamScreen> {

  // ==========================================================
  // Repositorios
  // ==========================================================

  final QuestionRepository questionRepository =
      QuestionRepository();

  final AlternativeRepository alternativeRepository =
      AlternativeRepository();

  // ==========================================================
  // Preguntas obtenidas desde SQLite
  // ==========================================================

  List<Question> questions = [];

  // ==========================================================
  // Alternativas de la pregunta actual
  // ==========================================================

  List<Alternative> alternatives = [];

  // ==========================================================
  // Número de la pregunta actual
  // ==========================================================

  int currentQuestion = 0;

  // ==========================================================
  // Puntaje del usuario
  // ==========================================================

  int score = 0;

  // ==========================================================
  // Controla el indicador de carga
  // ==========================================================

  bool isLoading = true;
  bool initialized = false;

  // ==========================================================
  // ID del simulacro recibido desde CatalogScreen
  // ==========================================================

  late int mockExamId;

  // ==========================================================
  // Cargar preguntas del simulacro
  // ==========================================================

  Future<void> loadQuestions() async {

    questions = await questionRepository
        .getQuestionsByMockExam(mockExamId);

    // Si existen preguntas cargamos las alternativas
    // de la primera.

    if (questions.isNotEmpty) {

      await loadAlternatives();

    }

    if (!mounted) return;

    setState(() {

      isLoading = false;

    });

  }

  // ==========================================================
  // Cargar alternativas de la pregunta actual
  // ==========================================================

  Future<void> loadAlternatives() async {

    alternatives =
        await alternativeRepository
            .getAlternativesByQuestion(

      questions[currentQuestion].questionId!,

    );

  }

  // ==========================================================
  // Procesa la respuesta del usuario
  // ==========================================================

  Future<void> answer(
    int selectedIndex,
  ) async {

    // ==========================================
    // Verificar respuesta correcta
    // ==========================================

    if (

      alternatives[selectedIndex].isCorrect == 1

    ) {

      score++;

    }

    // ==========================================
    // ¿Hay más preguntas?
    // ==========================================

    if (

      currentQuestion < questions.length - 1

    ) {

      currentQuestion++;

      await loadAlternatives();

      if (!mounted) return;

      setState(() {});

    }

    // ==========================================
    // Fin del examen
    // ==========================================

    else {

      if (!mounted) return;

      Navigator.pushNamed(

        context,

        '/result',

       arguments: {
  "score": score,
  "mockExamId": mockExamId,
},

      );

    }

  }

  @override
  Widget build(BuildContext context) {

    // ==========================================================
    // La primera vez obtenemos el ID del simulacro
    // ==========================================================

   if (!initialized) {

  mockExamId =
      ModalRoute.of(context)!
          .settings
          .arguments as int;

  initialized = true;

  loadQuestions();

}

if (isLoading) {

  return const Scaffold(

    body: Center(

      child: CircularProgressIndicator(),

    ),

  );

}

    // ==========================================================
    // Si no existen preguntas
    // ==========================================================

    if (questions.isEmpty) {

      return Scaffold(

        appBar: AppBar(

          title: const Text(

            "Mock Exam",

          ),

        ),

        body: const Center(

          child: Text(

            "No questions available.",

          ),

        ),

      );

    }

    // ==========================================================
    // Pregunta actual
    // ==========================================================

    final Question question =

        questions[currentQuestion];

    return Scaffold(

      appBar: AppBar(

        title: const Text(

          "Mock Exam",

        ),

      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // =====================================
            // Contador de preguntas
            // =====================================

            Text(

              "Question ${currentQuestion + 1} of ${questions.length}",

              style: const TextStyle(

                fontSize: 18,

                fontWeight: FontWeight.bold,

              ),

            ),

            const SizedBox(height: 25),

            // =====================================
            // Pregunta
            // =====================================

            Text(

              question.questionText,

              style: const TextStyle(

                fontSize: 22,

              ),

            ),

            const SizedBox(height: 30),

            // =====================================
            // Alternativas obtenidas desde SQLite
            // =====================================

            ...alternatives.asMap().entries.map(

              (entry) {

                return Padding(

                  padding:

                      const EdgeInsets.only(

                    bottom: 12,

                  ),

                  child: SizedBox(

                    width: double.infinity,

                    child: ElevatedButton(

                      onPressed: () {

                        answer(entry.key);

                      },

                      child: Text(

                        entry.value
                            .alternativeText,

                      ),

                    ),

                  ),

                );

              },

            ),

          ],

        ),

      ),

    );

  }
@override
void dispose() {

  super.dispose();

}
}