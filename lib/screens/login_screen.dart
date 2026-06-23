import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final correo = TextEditingController();
  final clave = TextEditingController();

  void login() {

    if(correo.text.isEmpty || clave.text.isEmpty){

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Complete todos los campos"),
        ),
      );

      return;
    }

    Navigator.pushNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("ADMISION AMAUTA"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller: correo,
              decoration: const InputDecoration(
                labelText: "Correo",
              ),
            ),

            TextField(
              controller: clave,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Contraseña",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: login,
              child: const Text("Ingresar"),
            ),
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
          ],
          
        ),
      ),
    );
  }
}