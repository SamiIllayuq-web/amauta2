import 'package:flutter/material.dart';
import '../models/result.dart';
import '../services/storage_service.dart';
import '../services/preferences_service.dart';

class ResultScreen extends StatelessWidget {


  Future<void> saveResult(
  int score,
) async {

  final history =
      await PreferencesService
          .loadHistory();

  history.add(
    "Puntaje: $score - ${DateTime.now()}",
  );

  await PreferencesService
      .saveHistory(history);
}

  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final score =
        ModalRoute.of(context)!
        .settings.arguments as int;

        saveResult(score);

        
    return Scaffold(

      appBar: AppBar(
        title: const Text("Resultado"),
      ),

      body: Center(

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Text(
              "Puntaje: $score",
              style: const TextStyle(
                fontSize: 30,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(

              onPressed: () {

                Navigator.pushNamed(
                  context,
                  '/progress',
                );
              },

              child: const Text(
                "Ver progreso",
              ),
            )
          ],
        ),
      ),
    );
  }
}