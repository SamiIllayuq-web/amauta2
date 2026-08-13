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
import '../models/result_model.dart';
import '../models/user_answer_model.dart';

import '../repositories/question_repository.dart';
import '../repositories/alternative_repository.dart';
import '../repositories/result_repository.dart';
import '../repositories/user_answer_repository.dart';

import '../services/preferences_service.dart';

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

  final ResultRepository resultRepository =
      ResultRepository();

  final UserAnswerRepository userAnswerRepository =
      UserAnswerRepository();

  // ==========================================================
  // ID del resultado (se crea al iniciar el examen)
  // ==========================================================

  int? resultId;

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
  // Cronometro del examen
  // ==========================================================

  /// Cronometro que registra el tiempo transcurrido desde
  /// el inicio del examen hasta que el postulante termina.
  /// Cada segundo se actualiza el estado para mostrar el
  /// tiempo en pantalla.
  int elapsedSeconds = 0;

  /// Referencia al timer interno. Se cancela en dispose
  /// para evitar perdidas de memoria.
  dynamic timer;

  /// Bandera que controla el bucle del cronometro.
  /// Se pone en false al destruir el widget para
  /// detener el timer de forma limpia.
  bool timerRunning = true;

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

    if (questions.isEmpty) {
      if (!mounted) return;
      setState(() => isLoading = false);
      return;
    }

    // Crear resultado en la base de datos
    final userId = await PreferencesService.loadUserId();
    if (userId != null) {
      final result = Result(
        userId: userId,
        mockExamId: mockExamId,
        correctAnswers: 0,
        incorrectAnswers: 0,
        finalScore: 0,
        elapsedTime: 0,
        completedAt: DateTime.now().toIso8601String(),
      );
      resultId = await resultRepository.createResult(result);

      // Iniciar el cronometro del examen.
      // El timer se mantiene activo hasta que el postulante
      // responde la ultima pregunta y es redirigido a ResultScreen.
      timerRunning = true;
      Future.doWhile(() async {
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted || !timerRunning) return false;
        setState(() => elapsedSeconds++);
        return true;
      });
    }

    await loadAlternatives();

    if (!mounted) return;

    setState(() => isLoading = false);

  }

  // ==========================================================
  // Cargar alternativas de la pregunta actual
  // ==========================================================

  Future<void> loadAlternatives() async {

    final qId = questions[currentQuestion].questionId!;
    alternatives =
        await alternativeRepository
            .getAlternativesByQuestion(qId);

    // Si no hay alternativas, algo esta mal en los datos seed.
    // Verificar que las preguntas tengan alternativas en la BD.
    assert(alternatives.isNotEmpty,
        'Pregunta $currentQuestion (id=$qId) no tiene alternativas');

  }

  // ==========================================================
  // Procesa la respuesta del usuario
  // ==========================================================

  Future<void> answer(int selectedIndex) async {

    if (selectedIndex < 0 || selectedIndex >= alternatives.length) {
      debugPrint('Indice de alternativa invalido: $selectedIndex');
      return;
    }

    final selectedAlternative = alternatives[selectedIndex];
    final isCorrect = selectedAlternative.isCorrect == 1;

    if (isCorrect) score++;

    // Guardar respuesta del usuario
    if (resultId != null) {
      final userAnswer = UserAnswer(
        resultId: resultId!,
        questionId: questions[currentQuestion].questionId!,
        selectedAlternativeId: selectedAlternative.alternativeId!,
        isCorrect: isCorrect,
      );
      try {
        await userAnswerRepository.createUserAnswer(userAnswer);
      } catch (e) {
        debugPrint('Error al guardar respuesta: $e');
      }
    } else {
      debugPrint('resultId es null - no se guardo la respuesta');
    }

    if (currentQuestion < questions.length - 1) {
      currentQuestion++;
      await loadAlternatives();
      if (!mounted) return;
      setState(() {});
    } else {
      if (!mounted) return;
      Navigator.pushNamed(context, '/result', arguments: {
        "resultId": resultId,
        "elapsedTime": elapsedSeconds,
      });
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

        title: Text(

          // Formato MM:SS para el tiempo transcurrido.
          // Se actualiza cada segundo mientras el examen
          // esta activo.
          "Mock Exam  |  "
          "\${(elapsedSeconds ~/ 60).toString().padLeft(2, '0')}:"
          "\${(elapsedSeconds % 60).toString().padLeft(2, '0')}",

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
    // Detiene el cronometro cuando se destruye el widget,
    // por ejemplo al navegar a otra pantalla o al cerrar
    // el examen. La bandera timerRunning corta el bucle
    // Future.doWhile de forma limpia.
    timerRunning = false;
    super.dispose();
  }
}