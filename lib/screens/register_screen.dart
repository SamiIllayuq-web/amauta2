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

  // ==========================================================
  // Controladores de los campos del formulario
  // ==========================================================

  final TextEditingController firstNameController =
      TextEditingController();

  final TextEditingController lastNameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  // ==========================================================
  // Repositorio de usuarios
  // ==========================================================

  final UserRepository userRepository =
      UserRepository();

  // ==========================================================
  // Registra un nuevo usuario en SQLite
  // ==========================================================

  Future<void> register() async {

    if (

      firstNameController.text.trim().isEmpty ||

      lastNameController.text.trim().isEmpty ||

      emailController.text.trim().isEmpty ||

      passwordController.text.trim().isEmpty

    ) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text(
            "Complete all fields",
          ),

        ),

      );

      return;

    }

    // ============================================
    // Verifica si el correo ya existe
    // ============================================

    final existingUser =
        await userRepository.getUserByEmail(

      emailController.text.trim(),

    );

    if (existingUser != null) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text(
            "Email already registered",
          ),

        ),

      );

      return;

    }

    // ============================================
    // Crea el objeto User
    // ============================================

    final User user = User(

      firstName:
          firstNameController.text.trim(),

      lastName:
          lastNameController.text.trim(),

      email:
          emailController.text.trim(),

      password:
          passwordController.text.trim(),

      createdAt:
          DateTime.now().toIso8601String(),

      role: DBConstants.rolePostulante,

    );

    // ============================================
    // Guarda en SQLite
    // ============================================

    await userRepository.createUser(user);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(

        content: Text(
          "Account created successfully",
        ),

      ),

    );

    Navigator.pop(context);

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Register",
        ),

      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(

              controller: firstNameController,

              decoration: const InputDecoration(

                labelText: "First Name",

              ),

            ),

            const SizedBox(height: 12),

            TextField(

              controller: lastNameController,

              decoration: const InputDecoration(

                labelText: "Last Name",

              ),

            ),

            const SizedBox(height: 12),

            TextField(

              controller: emailController,

              decoration: const InputDecoration(

                labelText: "Email",

              ),

            ),

            const SizedBox(height: 12),

            TextField(

              controller: passwordController,

              obscureText: true,

              decoration: const InputDecoration(

                labelText: "Password",

              ),

            ),

            const SizedBox(height: 30),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                onPressed: register,

                child: const Text(

                  "Create Account",

                ),

              ),

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