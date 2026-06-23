import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  final nombreController =
      TextEditingController();

  final correoController =
      TextEditingController();

  final claveController =
      TextEditingController();

  void registrar() {

    if (
      nombreController.text.isEmpty ||
      correoController.text.isEmpty ||
      claveController.text.isEmpty
    ) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("Complete todos los campos"),
        ),
      );

      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Registro"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            TextField(
              controller: nombreController,
              decoration:
                  const InputDecoration(
                labelText: "Nombre",
              ),
            ),

            TextField(
              controller: correoController,
              decoration:
                  const InputDecoration(
                labelText: "Correo",
              ),
            ),

            TextField(
              controller: claveController,
              obscureText: true,
              decoration:
                  const InputDecoration(
                labelText: "Contraseña",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: registrar,
              child:
                  const Text("Crear cuenta"),
            )
          ],
        ),
      ),
    );
  }
}