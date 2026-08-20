import 'package:flutter/material.dart';

import '../database/database_constants.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final UserRepository userRepository = UserRepository();

  // ==========================================================
  // Registro manual.
  // ==========================================================

  Future<void> register() async {

    if (
      firstNameController.text.trim().isEmpty ||
      lastNameController.text.trim().isEmpty ||
      emailController.text.trim().isEmpty ||
      passwordController.text.trim().isEmpty
    ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complete todos los campos")),
      );
      return;
    }

    // Check email duplicado (case-insensitive).
    final existingByEmail = await userRepository.getUserByEmail(
      emailController.text.trim(),
    );

    if (existingByEmail != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El email ya esta registrado")),
      );
      return;
    }

    // Check nombre+apellido duplicado (case-insensitive).
    final existingByName = await userRepository.getUserByFullName(
      firstNameController.text.trim(),
      lastNameController.text.trim(),
    );

    if (existingByName != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Este nombre y apellido ya estan registrados")),
      );
      return;
    }

    final User user = User(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      email: emailController.text.trim().toLowerCase(),
      password: passwordController.text.trim(),
      createdAt: DateTime.now().toIso8601String(),
      role: DBConstants.rolePostulante,
    );

    await userRepository.createUser(user);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cuenta creada exitosamente")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear cuenta")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: "Nombres"),
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 14),

            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: "Apellidos"),
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 14),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Correo"),
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 14),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Contrasena"),
            ),

            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: register,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("Crear cuenta", style: TextStyle(fontSize: 16)),
            ),

          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
