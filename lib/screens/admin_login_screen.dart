/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : admin_login_screen.dart
///
/// DESCRIPCIÓN:
/// Pantalla de login para administradores.
/// Usa la misma tabla users, pero solo acepta role='ADMIN'.
/// ===============================================================

import 'package:flutter/material.dart';

import '../database/database_constants.dart';
import '../repositories/user_repository.dart';
import '../services/preferences_service.dart';

class AdminLoginScreen extends StatefulWidget {

  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();

}

class _AdminLoginScreenState extends State<AdminLoginScreen> {

  final TextEditingController correo = TextEditingController();
  final TextEditingController clave = TextEditingController();

  final UserRepository userRepository = UserRepository();

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
        const SnackBar(content: Text("Correo o contraseña incorrectos")),
      );
      return;
    }

    if (user.role != DBConstants.roleAdmin) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Acceso solo para administradores")),
      );
      return;
    }

    await PreferencesService.saveUserId(user.userId!);
    await PreferencesService.saveRole(user.role);

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/admin');

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Admin - ADMISION AMAUTA"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const Icon(Icons.admin_panel_settings, size: 80, color: Colors.indigo),
            const SizedBox(height: 20),
            const Text(
              "Panel de Administración",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: correo,
              decoration: const InputDecoration(labelText: "Correo"),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: clave,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Contraseña"),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: login,
                child: const Text("Ingresar"),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Volver al login"),
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
