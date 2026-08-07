import 'package:flutter/material.dart';

import '../widgets/bottom_nav.dart';
import '../models/result_model.dart';
import '../repositories/result_repository.dart';
import '../services/preferences_service.dart';

class ProgressScreen
    extends StatefulWidget {

  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() =>
      _ProgressScreenState();
}

class _ProgressScreenState
    extends State<ProgressScreen> {

  // ==========================================================
// Resultados del usuario.
// ==========================================================

List<Result> results = [];

// ==========================================================
// Repositorio.
// ==========================================================

final ResultRepository repository =
    ResultRepository();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // ==========================================================
// Cargar resultados del usuario autenticado.
// ==========================================================

Future<void> loadData() async {

  final int? userId =

      await PreferencesService.loadUserId();

  if (userId == null) {

    return;

  }

  final data =

      await repository.getResultsByUser(userId);

  setState(() {

    results = data;

  });

}

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Progreso"),
      ),

      body: ListView.builder(

       itemCount: results.length,

        itemBuilder:
            (context, index) {

          return Card(

  margin: const EdgeInsets.symmetric(

    horizontal: 12,

    vertical: 6,

  ),

  child: ListTile(

    leading: const Icon(

      Icons.school,

    ),

    title: Text(

      "Puntaje: ${results[index].finalScore}",

    ),

    subtitle: Text(

      "Correctas: ${results[index].correctAnswers}"

      "\nIncorrectas: ${results[index].incorrectAnswers}",

    ),

    trailing: Text(

      results[index].completedAt
          .substring(0, 10),

    ),

  ),

);
        },
      ),

      bottomNavigationBar:
          const BottomNav(
        currentIndex: 2,
      ),
    );
  }
}