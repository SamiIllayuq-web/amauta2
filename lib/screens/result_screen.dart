import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {

  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final score =
        ModalRoute.of(context)!
        .settings.arguments as int;

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