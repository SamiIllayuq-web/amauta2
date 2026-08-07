
import '../widgets/bottom_nav.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {

  const ProfileScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

   return Scaffold(

  appBar: AppBar(
    title: const Text("Profile"),
  ),

  body: Padding(

    padding: const EdgeInsets.all(20),

    child: Column(

      crossAxisAlignment: CrossAxisAlignment.stretch,

      children: [

        const Icon(
          Icons.person,
          size: 100,
        ),

        const SizedBox(height: 20),

        const Text(
          "User Profile",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 40),

        ElevatedButton.icon(

          icon: const Icon(Icons.logout),

          label: const Text("Logout"),

          onPressed: () {

            Navigator.pushNamedAndRemoveUntil(

              context,

              '/',

              (route) => false,

            );

          },

        ),

      ],

    ),

  ),

  bottomNavigationBar: const BottomNav(

    currentIndex: 3,

  ),

);

  }

}