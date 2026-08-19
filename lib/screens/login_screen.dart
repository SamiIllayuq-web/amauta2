/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : login_screen.dart
///
/// DESCRIPCIÓN:
/// Pantalla encargada de autenticar al usuario.
/// ===============================================================

import 'package:flutter/material.dart';

import '../database/database_constants.dart';
import '../repositories/user_repository.dart';
import '../services/preferences_service.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController correo = TextEditingController();
  final TextEditingController clave = TextEditingController();

  final UserRepository userRepository = UserRepository();

  // ==========================================================
  // LOGIN MANUAL
  // ==========================================================

  Future<void> login() async {

    if (correo.text.trim().isEmpty || clave.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complete todos los campos")),
      );
      return;
    }

    final user = await userRepository.login(
      email: correo.text.trim(),
      password: clave.text.trim(),
    );

    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Correo o contrasena incorrectos")),
      );
      return;
    }

    await PreferencesService.saveUserId(user.userId!);
    await PreferencesService.saveRole(user.role);

    if (!mounted) return;

    if (user.role == DBConstants.roleAdmin) {
      Navigator.pushReplacementNamed(context, '/admin');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("ADMISION AMAUTA")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            const SizedBox(height: 40),

            // ==============================================
            // Formulario de login.
            // ==============================================

            TextField(
              controller: correo,
              decoration: const InputDecoration(labelText: "Correo"),
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 14),

            TextField(
              controller: clave,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Contrasena"),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: login,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("Ingresar", style: TextStyle(fontSize: 16)),
            ),

            const SizedBox(height: 16),

            // ==============================================
            // Links inferiores.
            // ==============================================

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text("Crear cuenta"),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/admin/login'),
                  child: const Text("Acceso Admin", style: TextStyle(color: Colors.indigo)),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    correo.dispose();
    clave.dispose();
    super.dispose();
  }
}
