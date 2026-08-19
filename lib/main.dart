/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : main.dart
///
/// DESCRIPCIÓN:
/// Punto de entrada principal de la aplicación.
/// Inicializa Flutter, la base de datos SQLite y ejecuta
/// la aplicación.
/// ===============================================================

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'database/database_helper.dart';

import 'screens/login_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_postulants_screen.dart';
import 'screens/admin_exam_manage_screen.dart';
import 'screens/admin_monitoring_screen.dart';
import 'screens/admin_exam_ingest_screen.dart';
import 'screens/admin_question_analysis_screen.dart';
import 'screens/ai_review_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/exam_screen.dart';
import 'screens/result_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/comments_screen.dart';

import 'theme/app_theme.dart';

// ==========================================================
// Punto de entrada de la aplicación.
// ==========================================================

Future<void> main() async {
  // Carga variables de entorno desde .env (API keys, etc.)
  await dotenv.load(fileName: ".env");

  // Permite ejecutar codigo asincrono antes de iniciar Flutter.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa la base de datos SQLite.
  print("[MAIN] PASO 1 - DatabaseHelper...");
  try {
    final db = await DatabaseHelper.instance.database;
    print("[MAIN] Database OK: ${db.path}");
  } catch (e) {
    print("[MAIN] Database ERROR: $e");
    rethrow;
  }

  print("[MAIN] PASO 2 - runApp...");
  runApp(const MyApp());

}

// ==========================================================
// Widget principal de la aplicación.
// ==========================================================

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: 'ADMISIÓN AMAUTA',

      theme: AppTheme.lightTheme(),

      initialRoute: '/',

      routes: {

        '/': (context) => const LoginScreen(),

        '/admin/login': (context) => const AdminLoginScreen(),

        '/register': (context) => const RegisterScreen(),

        '/home': (context) => const HomeScreen(),

        '/admin': (context) => const AdminDashboardScreen(),

        '/admin/postulants': (context) => const AdminPostulantsScreen(),

        '/admin/exams': (context) => const AdminExamManageScreen(),

        '/admin/monitoring': (context) => const AdminMonitoringScreen(),

        '/admin/ingest': (context) => const AdminExamIngestScreen(),

        '/admin/analyze': (context) => const AdminQuestionAnalysisScreen(),

        '/catalog': (context) => const CatalogScreen(),

        '/exam': (context) => const ExamScreen(),

        '/result': (context) => const ResultScreen(),

        '/ai-review': (context) => const AIReviewScreen(resultId: 0, mockExamId: 0),

        '/progress': (context) => const ProgressScreen(),

        '/profile': (context) => const ProfileScreen(),

        '/comments': (context) => const CommentsScreen(),

      },

    );

  }

}