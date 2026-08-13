/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : login_screen.dart
///
/// DESCRIPCIÓN:
/// Pantalla encargada de autenticar al usuario.
///
/// FLUJO:
/// 1. Valida que los campos no estén vacíos.
/// 2. Consulta SQLite mediante UserRepository.
/// 3. Si existe el usuario:
///      - Guarda el ID de sesión en SharedPreferences.
///      - Ingresa al Home.
/// 4. Si no existe:
///      - Muestra un mensaje de error.
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

  // ==========================================================
  // Controladores de los TextField
  // ==========================================================

  final TextEditingController correo =
      TextEditingController();

  final TextEditingController clave =
      TextEditingController();

  // ==========================================================
  // Repositorio encargado del login en SQLite
  // ==========================================================

  final UserRepository userRepository =
      UserRepository();

  // ==========================================================
  // LOGIN
  // ==========================================================

  Future<void> login() async {

    // ========================================================
    // Validar que todos los campos estén completos.
    // ========================================================

    if (

      correo.text.trim().isEmpty ||

      clave.text.trim().isEmpty

    ) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text(
            "Complete todos los campos",
          ),

        ),

      );

      return;

    }

    // ========================================================
    // Buscar usuario en SQLite.
    // ========================================================

    final user = await userRepository.login(

      email: correo.text.trim(),

      password: clave.text.trim(),

    );

    // ========================================================
    // Si el usuario no existe mostramos un mensaje.
    // ========================================================

    if (user == null) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text(
            "Correo o contraseña incorrectos",
          ),

        ),

      );

      return;

    }

    // ========================================================
    // Guardar el usuario que inició sesión.
    //
    // Este ID será utilizado posteriormente por:
    //
    // - ResultScreen
    // - ProgressScreen
    // - ProfileScreen
    //
    // para saber quién está usando la aplicación.
    // ========================================================

    await PreferencesService.saveUserId(

      user.userId!,

    );

    await PreferencesService.saveRole(user.role);

    // ========================================================
    // Verificar que el widget siga montado.
    // ========================================================

    if (!mounted) return;

    // ========================================================
    // Redirigir según rol.
    // ========================================================

    if (user.role == DBConstants.roleAdmin) {
      Navigator.pushReplacementNamed(context, '/admin');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(

          "ADMISION AMAUTA",

        ),

      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            // ==================================================
            // Campo correo.
            // ==================================================

            TextField(

              controller: correo,

              decoration: const InputDecoration(

                labelText: "Correo",

              ),

            ),

            const SizedBox(height: 15),

            // ==================================================
            // Campo contraseña.
            // ==================================================

            TextField(

              controller: clave,

              obscureText: true,

              decoration: const InputDecoration(

                labelText: "Contraseña",

              ),

            ),

            const SizedBox(height: 25),

            // ==================================================
            // Botón Ingresar.
            // ==================================================

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                onPressed: login,

                child: const Text(

                  "Ingresar",

                ),

              ),

            ),

            const SizedBox(height: 10),

            // ==================================================
            // Ir a la pantalla de registro.
            // ==================================================

            TextButton(

              onPressed: () {

                Navigator.pushNamed(

                  context,

                  '/register',

                );

              },

              child: const Text(

                "Crear cuenta",

              ),

            ),

            const SizedBox(height: 5),

            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/admin/login'),
              child: const Text("Acceso Admin", style: TextStyle(color: Colors.indigo)),
            ),

          ],

        ),

      ),

    );

  }

  // ==========================================================
  // Liberar memoria utilizada por los TextEditingController.
  // ==========================================================

  @override
  void dispose() {

    correo.dispose();

    clave.dispose();

    super.dispose();

  }

}