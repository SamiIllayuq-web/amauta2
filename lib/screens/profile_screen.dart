import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      bottomNavigationBar:
    const BottomNav(
      currentIndex: 3,
),

      appBar: AppBar(
        title: const Text("Perfil"),
      ),

      body: const Padding(
        padding: EdgeInsets.all(20),

        child: Column(

          children: [

            CircleAvatar(
              radius: 50,
              child: Icon(
                Icons.person,
                size: 50,
              ),
            ),

            SizedBox(height: 20),

            Text(
              "David Sedano",
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            Text(
              "Postulante",
            ),
          ],
        ),
      ),
    );
  }
}