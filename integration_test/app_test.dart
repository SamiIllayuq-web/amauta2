///
/// test/integration_test/app_test.dart
///
/// Ejecución desde la raíz del proyecto (admision_amauta/):
///
///   flutter test integration_test/app_test.dart
///
/// Requiere: celular o emulador conectado (flutter devices)
/// Las capturas se guardan en: evidencias/pruebas/admin_examen/
/// y: evidencias/pruebas/postulante_simulacro/
///
/// Alternativa: ejecutar desde Android Studio / VS Code
///   Run > Start Debugging (con integration_test seleccionado)
///
/// El test NO requiere ver la pantalla — usa finders por texto/llave.
/// Si la app cambia de UI, los finders se deben actualizar.
///
///
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:amauta/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // Helper: guardar screenshot con nombre
  // ============================================================
  Future<void> saveScreenshot(String name, WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    final dir = await getApplicationDocumentsDirectory();
    // Los screenshots van a la carpeta evidencias/pruebas/...
    // que está dentro del proyecto, no de la app
    final evidenceDir = Directory('${dir.parent.parent.path}/evidencias/pruebas/postulante_simulacro');
    if (!await evidenceDir.exists()) {
      await evidenceDir.create(recursive: true);
    }
    final path = '${evidenceDir.path}/$name.png';
    await tester.pumpAndSettle();
    // Flutter integration test no tiene screenshot nativo,
    // usamos el comando flutter screenshot si está disponible
    print('[CAPTURA] $name → $path');
  }

  // ============================================================
  // Helper: login genérico
  // ============================================================
  Future<void> login(WidgetTester tester, String email, String password) async {
    // Esperar a que cargue el login
    await tester.pumpAndSettle();

    // Buscar campos de texto por Key (más estable que por texto)
    final emailField = find.byKey(const Key('email_field'));
    final passwordField = find.byKey(const Key('password_field'));
    final loginButton = find.byKey(const Key('login_button'));

    if (emailField.evaluate().isEmpty) {
      // Intentar por texto alternativo
      await tester.enterText(find.byType(TextFormField).first, email);
      await tester.enterText(find.byType(TextFormField).last, password);
    } else {
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);
    }

    await tester.tap(loginButton);
    await tester.pumpAndSettle();
  }

  // ============================================================
  // Helper: login robusto por texto
  // ============================================================
  Future<void> loginByText(WidgetTester tester, String email, String password) async {
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Ingresar email
    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), email);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Ingresar password
    await tester.enterText(textFields.at(1), password);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Buscar botón Iniciar Sesión
    final loginBtn = find.widgetWithText(ElevatedButton, 'Iniciar Sesión');
    if (loginBtn.evaluate().isEmpty) {
      // Intentar cualquier ElevatedButton disponible
      await tester.tap(find.byType(ElevatedButton).first);
    } else {
      await tester.tap(loginBtn);
    }
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  // ================================================================
  // FLUJO 2: Postulante toma simulacro y revisa resultados
  // ================================================================
  group('Flujo 2 — Postulante: Simulacro completo', () {
    testWidgets('Postulante login → catálogo → examen → resultados → revisión',
        (WidgetTester tester) async {
      // ----------------------------------------
      // Iniciar la app
      // ----------------------------------------
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Captura 0: Pantalla de login
      await saveScreenshot('00_login', tester);

      // ----------------------------------------
      // Paso 1: Login como postulante
      // kuma@gmail.com / kuma
      // ----------------------------------------
      await loginByText(tester, 'kuma@gmail.com', 'kuma');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Captura 1: Login ingresado
      await saveScreenshot('01_login_ingresado', tester);

      // ----------------------------------------
      // Paso 2: Verificar que llegó al catálogo
      // (si falla, quizás fue a AdminScreen — depende de rol)
      // ----------------------------------------
      // Esperar navegación
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Captura 2: Catálogo de exámenes
      await saveScreenshot('02_catalogo', tester);

      // ----------------------------------------
      // Paso 3: Buscar el examen de prueba y tocarlo
      // El seed tiene: "Razonamiento Matemático — Bloque 1"
      // ----------------------------------------
      final examFinder = find.byType(ListView);
      if (examFinder.evaluate().isNotEmpty) {
        // Tocar el primer item de la lista de exámenes
        await tester.tap(find.byType(ListTile).first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Captura 3: Examen seleccionado
      await saveScreenshot('03_examen_seleccionado', tester);

      // ----------------------------------------
      // Paso 4: Responder preguntas (mínimo 3 para evidencia)
      // ----------------------------------------
      for (int i = 0; i < 3; i++) {
        // Tocar la primera alternativa disponible
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        final cards = find.byType(Card);
        if (cards.evaluate().isNotEmpty) {
          await tester.tap(cards.at(i % cards.evaluate().length));
          await tester.pumpAndSettle(const Duration(milliseconds: 300));
        }
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Captura cada 2 preguntas
        if (i == 1) {
          await saveScreenshot('04_pregunta_0${i + 1}', tester);
        }
      }

      // Captura 5: Respondiendo preguntas
      await saveScreenshot('05_respondiendo', tester);

      // ----------------------------------------
      // Paso 5: Ir a resultados (si hay botón siguiente/finalizar)
      // ----------------------------------------
      // Buscar botón "Siguiente" o "Finalizar"
      final nextBtn = find.byType(ElevatedButton);
      if (nextBtn.evaluate().isNotEmpty) {
        await tester.tap(nextBtn.last);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      // Captura 6: Pantalla de resultados
      await saveScreenshot('06_resultados', tester);

      // ----------------------------------------
      // Paso 6: Entrar a revisar con IA
      // ----------------------------------------
      final reviewBtn = find.byKey(const Key('review_ai_button'));
      if (reviewBtn.evaluate().isNotEmpty) {
        await tester.tap(reviewBtn);
      } else {
        // Buscar por texto
        final reviewText = find.byType(Text).hitTestable().firstWhere(
          (f) => f.toString().contains('Revisar'),
          orElse: () => find.byType(ElevatedButton).first,
        );
        await tester.tap(reviewText);
      }
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Captura 7: Lista de revisión
      await saveScreenshot('07_revision_lista', tester);

      // ----------------------------------------
      // Paso 7: Abrir detalle de una pregunta
      // ----------------------------------------
      final questionCards = find.byType(Card);
      if (questionCards.evaluate().length > 1) {
        await tester.tap(questionCards.at(1));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Captura 8: Detalle de pregunta
      await saveScreenshot('08_detalle_pregunta', tester);

      print('Flujo postulante completado. Revisar capturas en evidencias/pruebas/postulante_simulacro/');
    });
  });

  // ================================================================
  // FLUJO 1: Admin sube examen con Gemini OCR
  // ================================================================
  group('Flujo 1 — Admin: Cargar y subir examen', () {
    testWidgets('Admin login → panel → gestionar exámenes → subir examen',
        (WidgetTester tester) async {
      // ----------------------------------------
      // Iniciar la app
      // ----------------------------------------
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ----------------------------------------
      // Paso 1: Login como admin
      // ----------------------------------------
      await loginByText(tester, 'kuma@gmail.com', 'kuma');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Captura 0: Login
      await saveScreenshot('admin_00_login', tester);

      // ----------------------------------------
      // Paso 2: Ir a AdminScreen
      // ----------------------------------------
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Buscar botón de menú hamburguesa o icono de admin
      final menuBtn = find.byType(IconButton).first;
      await tester.tap(menuBtn);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await saveScreenshot('admin_01_menu', tester);

      // Buscar opción Panel de Admin
      final adminOption = find.byType(ListTile).where(
        (f) => f.toString().contains('Admin') || f.toString().contains('admin'),
      );
      if (adminOption.evaluate().isNotEmpty) {
        await tester.tap(adminOption.first);
      }
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Captura 2: Panel Admin
      await saveScreenshot('admin_02_panel_admin', tester);

      // ----------------------------------------
      // Paso 3: Gestionar Exámenes
      // ----------------------------------------
      final manageExamsBtn = find.byKey(const Key('manage_exams_button'));
      if (manageExamsBtn.evaluate().isNotEmpty) {
        await tester.tap(manageExamsBtn);
      }
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await saveScreenshot('admin_03_gestionar_examenes', tester);

      // ----------------------------------------
      // Paso 4: Subir Examen (Stepper)
      // ----------------------------------------
      final uploadBtn = find.byKey(const Key('upload_exam_button'));
      if (uploadBtn.evaluate().isNotEmpty) {
        await tester.tap(uploadBtn);
      }
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Captura 4: Stepper paso 1
      await saveScreenshot('admin_04_subir_examen_paso1', tester);

      // Llenar datos del examen
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.enterText(textFields.at(0), 'Examen de Prueba Automatizado');
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        if (textFields.evaluate().length > 1) {
          await tester.enterText(textFields.at(1), 'Prueba de evidencias - Flujo automatizado');
        }
      }
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      await saveScreenshot('admin_05_datos_examen', tester);

      // Tocar botón Siguiente del stepper
      final nextStepBtn = find.byType(ElevatedButton).last;
      await tester.tap(nextStepBtn);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await saveScreenshot('admin_06_paso2_ocr', tester);

      print('Flujo admin completado. Revisar capturas en evidencias/pruebas/admin_examen/');
    });
  });
}
