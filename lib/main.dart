import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/catalog_screen.dart';

import 'screens/exam_screen.dart';
import 'screens/result_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'theme/app_theme.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      title: 'ADMISION AMAUTA',
      initialRoute: '/',
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/profile': (context) => const ProfileScreen(),         
        '/exam': (context) => const ExamScreen(),
        '/result': (context) => const ResultScreen(),
        '/progress': (context) => const ProgressScreen(),

        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/catalog': (context) => const CatalogScreen(),
      },
    );
  }
}