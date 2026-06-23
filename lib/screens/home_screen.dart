import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Inicio"),
      ),

      body: Center(

        child: ElevatedButton(

          onPressed: (){
            Navigator.pushNamed(
              context,
              '/catalog',
            );
          },

          child: const Text(
            "Ver Simulacros",
          ),
        ),
      ),
    );
  }
}