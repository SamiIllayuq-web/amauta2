import 'package:flutter/material.dart';

import '../models/result_with_exam_model.dart';
import '../repositories/result_repository.dart';
import '../services/preferences_service.dart';
import '../widgets/bottom_nav.dart';
import 'ai_review_screen.dart';

class ProgressScreen extends StatefulWidget {

  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();

}

class _ProgressScreenState extends State<ProgressScreen> {

  // ==========================================================
  // Resultados con titulo del examen.
  // ==========================================================

  List<ResultWithExam> results = [];

  // ==========================================================
  // Repositorio.
  // ==========================================================

  final ResultRepository repository = ResultRepository();

  // ==========================================================
  // Lifecycle.
  // ==========================================================

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // ==========================================================
  // Cargar resultados del usuario autenticado.
  // ==========================================================

  Future<void> loadData() async {

    final int? userId = await PreferencesService.loadUserId();

    if (userId == null) return;

    final data = await repository.getResultsByUserWithExam(userId);

    setState(() {
      results = data;
    });

  }

  // ==========================================================
  // Format elapsed time as MM:SS.
  // ==========================================================

  String _formatTime(int seconds) {

    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

  }

  // ==========================================================
  // Build.
  // ==========================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Progreso"),
      ),

      body: results.isEmpty

          ? const Center(
              child: Text(
                "Sin resultados todavia.",
                style: TextStyle(fontSize: 16),
              ),
            )

          : ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {

                final r = results[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: InkWell(
                    onTap: () {
                      final rid = r.resultId;
                      final mid = r.mockExamId;
                      if (rid == null || mid == null) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AIReviewScreen(
                            resultId: rid,
                            mockExamId: mid,
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: Text(
                          '${r.correctAnswers}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      title: Text(
                        r.examTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Correctas: ${r.correctAnswers}  |  Incorrectas: ${r.incorrectAnswers}\n'
                        'Tiempo: ${_formatTime(r.elapsedTime)}',
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            r.completedAt.substring(0, 10),
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.auto_awesome, size: 16, color: Colors.amber),
                        ],
                      ),
                    ),
                  ),
                );

              },
            ),

      bottomNavigationBar: const BottomNav(
        currentIndex: 2,
      ),

    );

  }

}
