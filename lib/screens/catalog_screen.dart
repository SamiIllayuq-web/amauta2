/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : catalog_screen.dart
///
/// DESCRIPCIÓN:
/// Muestra el catálogo de simulacros almacenados en SQLite.
///
/// RESPONSABILIDADES:
/// - Obtener los simulacros desde MockExamRepository.
/// - Mostrar la lista de simulacros.
/// - Enviar el mockExamId al ExamScreen.
/// ===============================================================

import 'package:flutter/material.dart';

import '../models/mock_exam_model.dart';
import '../repositories/mock_exam_repository.dart';
import '../widgets/bottom_nav.dart';

class CatalogScreen extends StatefulWidget {

  const CatalogScreen({
    super.key,
  });

  @override
  State<CatalogScreen> createState() =>
      _CatalogScreenState();

}

class _CatalogScreenState
    extends State<CatalogScreen> {

  // ==========================================================
  // Repositorio encargado de consultar SQLite.
  // ==========================================================

  final MockExamRepository repository =
      MockExamRepository();

  // ==========================================================
  // Lista donde se almacenarán los simulacros obtenidos
  // desde la base de datos.
  // ==========================================================

  List<MockExam> exams = [];

  // ==========================================================
  // Cuando la pantalla se crea por primera vez,
  // cargamos los simulacros desde SQLite.
  // ==========================================================

  @override
  void initState() {

    super.initState();

    loadExams();

  }

  // ==========================================================
  // Obtiene todos los simulacros registrados.
  // ==========================================================

  Future<void> loadExams() async {

    exams = await repository.getAllMockExams();

    setState(() {});

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Catalog",
        ),

      ),

      // ========================================================
      // BottomNavigation reutilizable.
      // ========================================================

      bottomNavigationBar: const BottomNav(

        currentIndex: 1,

      ),

      // ========================================================
      // Si todavía no hay datos mostramos un indicador de carga.
      // ========================================================

      body: exams.isEmpty

          ? const Center(

              child: CircularProgressIndicator(),

            )

          : ListView.builder(

              padding: const EdgeInsets.all(16),

              itemCount: exams.length,

              itemBuilder: (context, index) {

                final MockExam exam = exams[index];

                return Card(

                  elevation: 4,

                  margin: const EdgeInsets.only(
                    bottom: 12,
                  ),

                  child: ListTile(

                    leading: const Icon(
                      Icons.school,
                    ),

                    // ==============================
                    // Título del simulacro.
                    // ==============================

                    title: Text(

                      exam.title,

                    ),

                    // ==============================
                    // Información secundaria.
                    // ==============================

                    subtitle: Text(

                      "${exam.description}\n"
                      "Questions: ${exam.totalQuestions} • "
                      "${exam.durationMinutes} min",

                    ),

                    isThreeLine: true,

                    trailing: const Icon(

                      Icons.arrow_forward_ios,

                    ),

                    // ==============================
                    // Envía el ID del simulacro al
                    // ExamScreen.
                    // ==============================

                    onTap: () {

                      Navigator.pushNamed(

                        context,

                        '/exam',

                        arguments: exam.mockExamId,

                      );

                    },

                  ),

                );

              },

            ),

    );

  }

}