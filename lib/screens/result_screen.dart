// ===============================================================
// PROYECTO : ADMISIÓN AMAUTA
// ARCHIVO  : result_screen.dart
//
// DESCRIPCIÓN:
// Pantalla encargada de mostrar el resultado obtenido
// por el estudiante al finalizar un simulacro.
//
// RESPONSABILIDADES:
//
// - Mostrar el puntaje obtenido.
// - Obtener el usuario autenticado.
// - Registrar el resultado en SQLite.
// - Evitar registros duplicados.
// - Permitir navegar hacia la pantalla de progreso.
//
// FLUJO
//
// ExamScreen
//        |
//        ▼
// score + mockExamId
//        |
//        ▼
// PreferencesService
//        |
//        ▼
// userId
//        |
//        ▼
// ResultRepository
//        |
//        ▼
// SQLite

library;

import 'package:flutter/material.dart';

import '../models/result_model.dart';
import '../models/user_answer_model.dart';

import '../repositories/result_repository.dart';
import '../repositories/user_answer_repository.dart';

import '../services/preferences_service.dart';

import 'ai_review_screen.dart';

class ResultScreen extends StatefulWidget {

  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() =>
      _ResultScreenState();

}

class _ResultScreenState extends State<ResultScreen> {

  final ResultRepository repository = ResultRepository();
  final UserAnswerRepository userAnswerRepository = UserAnswerRepository();

  bool saved = false;
  bool initialized = false;
  Result? result;
  List<UserAnswer> userAnswers = [];
  int correctAnswers = 0;
  int incorrectAnswers = 0;
  int totalQuestions = 0;
  int finalScore = 0;
  int? mockExamId;
  late int resultId;

  /// Tiempo total que el postulante uso para completar
  /// el examen, enviado desde ExamScreen.
  int elapsedTime = 0;

  Future<void> saveResult(int resultId, int elapsedTime) async {
    final userId = await PreferencesService.loadUserId();
    if (userId == null) return;

    // Obtener las respuestas guardadas por el postulante
    // durante el examen. Se filtran por el resultId del
    // examen actual. isCorrect se calcula via JOIN.
    userAnswers = await userAnswerRepository
        .getUserAnswersWithCorrectness(resultId);

    // Contar respuestas correctas e incorrectas.
    // Se calculan desde las respuestas guardadas en la DB,
    // no desde memoria.
    correctAnswers = userAnswers.where((a) => a.isCorrect).length;
    incorrectAnswers = userAnswers.length - correctAnswers;
    totalQuestions = userAnswers.length;

    // Calcular puntaje final: cada respuesta correcta suma 20 puntos.
    finalScore = correctAnswers * 20;

    // Guardar el tiempo transcurrido enviado desde ExamScreen.
    this.elapsedTime = elapsedTime;

    // Obtener el resultado creado por ExamScreen al inicio
    // del examen y actualizarlo con los valores calculados.
    result = await repository.getResultById(resultId);

    if (result != null) {
      final updated = Result(
        resultId: result!.resultId,
        userId: result!.userId,
        mockExamId: result!.mockExamId,
        correctAnswers: correctAnswers,
        incorrectAnswers: incorrectAnswers,
        finalScore: finalScore.toDouble(),
        // Tiempo transcurrido en segundos durante el examen.
        elapsedTime: elapsedTime,
        completedAt: result!.completedAt,
      );
      await repository.updateResult(updated);
      mockExamId = result!.mockExamId;
    }

    if (!mounted) return;
    setState(() => saved = true);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // mockExamId se pasa desde ExamScreen al ResultScreen.
    // Usado para navegar a AIReviewScreen.
    final int? passedMockExamId = arguments["mockExamId"];

    // Guardar para usar en navegación y en saveResult.
    resultId = arguments["resultId"] as int;
    mockExamId = passedMockExamId;

    // Tiempo transcurrido en segundos enviado desde ExamScreen.
    final int elapsedTime = arguments["elapsedTime"] ?? 0;

    if (!initialized) {
      initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => saveResult(resultId, elapsedTime));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Resultado")),
      body: saved
          ? _buildContent()
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Simulacro Finalizado",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Text("Puntaje: $correctAnswers / $totalQuestions",
                style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 15),
            Text("Nota: $finalScore",
                style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 15),
            Text("Correctas: $correctAnswers  |  Incorrectas: $incorrectAnswers",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 15),
            // Mostrar tiempo que el postulante uso para completar el examen.
            Text(
              "Tiempo: "
              "\${(elapsedTime ~/ 60).toString().padLeft(2, '0')}:"
              "\${(elapsedTime % 60).toString().padLeft(2, '0')}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AIReviewScreen(
                        resultId: resultId,
                        mockExamId: mockExamId!,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.auto_awesome),
                label: const Text("Revisar con IA"),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/progress'),
                child: const Text("Ver progreso"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
