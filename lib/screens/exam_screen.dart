import 'package:flutter/material.dart';

import '../data/fake_data.dart';

class ExamScreen extends StatefulWidget {

  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {

  int currentQuestion = 0;
  int score = 0;

  void answer(int selectedIndex) {

    if(
      selectedIndex ==
      questions[currentQuestion].correctIndex
    ){
      score++;
    }

    if(
      currentQuestion <
      questions.length - 1
    ){
      setState(() {
        currentQuestion++;
      });
    } else {

      Navigator.pushNamed(
        context,
        '/result',
        arguments: score,
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final question =
        questions[currentQuestion];

    return Scaffold(

      appBar: AppBar(
        title: const Text("Simulacro"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            Text(
              question.question,
              style: const TextStyle(
                fontSize: 22,
              ),
            ),

            const SizedBox(height: 20),

            ...question.options.asMap().entries.map(

              (option) {

                return ElevatedButton(

                  onPressed: () {
                    answer(option.key);
                  },

                  child: Text(
                    option.value,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}