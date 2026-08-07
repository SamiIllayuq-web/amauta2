/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : result_screen.dart
///
/// DESCRIPCIÓN:
/// Pantalla encargada de mostrar el resultado obtenido
/// por el estudiante al finalizar un simulacro.
///
/// RESPONSABILIDADES:
///
/// • Mostrar el puntaje obtenido.
/// • Obtener el usuario autenticado.
/// • Registrar el resultado en SQLite.
/// • Evitar registros duplicados.
/// • Permitir navegar hacia la pantalla de progreso.
///
/// FLUJO
///
/// ExamScreen
///        │
///        ▼
/// score + mockExamId
///        │
///        ▼
/// PreferencesService
///        │
///        ▼
/// userId
///        │
///        ▼
/// ResultRepository
///        │
///        ▼
/// SQLite
///
/// ===============================================================

import 'package:flutter/material.dart';

import '../models/result_model.dart';

import '../repositories/result_repository.dart';

import '../services/preferences_service.dart';

class ResultScreen extends StatefulWidget {

  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() =>
      _ResultScreenState();

}

class _ResultScreenState
    extends State<ResultScreen> {

  // ==========================================================
  // Repositorio encargado de guardar resultados.
  // ==========================================================

  final ResultRepository repository =
      ResultRepository();

  // ==========================================================
  // Evita guardar varias veces el mismo resultado.
  // ==========================================================

  bool saved = false;
bool initialized = false;
  // ==========================================================
  // Guarda el resultado del examen.
  // ==========================================================

  Future<void> saveResult({

    required int score,

    required int mockExamId,

  }) async {

    // ==========================================
    // Obtener usuario autenticado.
    // ==========================================

    final int? userId =

        await PreferencesService.loadUserId();

    // ==========================================
    // Si no existe sesión simplemente salir.
    // ==========================================

    if (userId == null) {

      return;

    }

    // ==========================================
    // Crear objeto Result.
    // ==========================================

    final Result result = Result(

      userId: userId,

      mockExamId: mockExamId,

      correctAnswers: score,

      incorrectAnswers: 5 - score,

      finalScore: score * 20,

      elapsedTime: 0,

      completedAt:

          DateTime.now().toIso8601String(),

    );

    // ==========================================
    // Guardar en SQLite.
    // ==========================================

    await repository.createResult(

      result,

    );

  }

  @override
  Widget build(BuildContext context) {

    // ==========================================================
    // Recuperar información enviada desde ExamScreen.
    // ==========================================================

    final Map<String, dynamic> arguments =

        ModalRoute.of(context)!
            .settings
            .arguments as Map<String, dynamic>;

    final int score = arguments["score"];

    final int mockExamId =
        arguments["mockExamId"];

    // ==========================================================
    // Guardar el resultado solamente una vez.
    // ==========================================================

   if (!initialized) {

  initialized = true;

  WidgetsBinding.instance.addPostFrameCallback((_) {

    saveResult(

      score: score,

      mockExamId: mockExamId,

    );

  });

}

    return Scaffold(

      appBar: AppBar(

        title: const Text(

          "Resultado",

        ),

      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Center(

          child: Column(

            mainAxisAlignment:

                MainAxisAlignment.center,

            children: [

              // ======================================
              // Título
              // ======================================

              const Text(

                "Simulacro Finalizado",

                style: TextStyle(

                  fontSize: 26,

                  fontWeight: FontWeight.bold,

                ),

              ),

              const SizedBox(height: 30),

              // ======================================
              // Puntaje obtenido.
              // ======================================

              Text(

                "Puntaje: $score",

                style: const TextStyle(

                  fontSize: 32,

                ),

              ),

              const SizedBox(height: 15),

              // ======================================
              // Nota final.
              // ======================================

              Text(

                "Nota: ${score * 20}",

                style: const TextStyle(

                  fontSize: 22,

                ),

              ),

              const SizedBox(height: 40),

              // ======================================
              // Ir al historial.
              // ======================================

              SizedBox(

                width: double.infinity,

                child: ElevatedButton(

                  onPressed: () {

                    Navigator.pushReplacementNamed(

                      context,

                      '/progress',

                    );

                  },

                  child: const Text(

                    "Ver progreso",

                  ),

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }

}