/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : admin_dashboard_screen.dart
///
/// DESCRIPCIÓN:
/// Panel principal del administrador.
/// ===============================================================

import 'package:flutter/material.dart';

import '../services/preferences_service.dart';

class AdminDashboardScreen extends StatelessWidget {

  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel Admin"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await PreferencesService.clearUserId();
              await PreferencesService.clearRole();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bienvenido, Admin",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            _buildCard(
              context,
              icon: Icons.people,
              title: "Postulantes",
              subtitle: "Ver y gestionar postulantes",
              color: Colors.blue,
              onTap: () => Navigator.pushNamed(context, '/admin/postulants'),
            ),
            const SizedBox(height: 12),
            _buildCard(
              context,
              icon: Icons.upload_file,
              title: "Ingestar Examen",
              subtitle: "Subir fotos del examen para extraer preguntas",
              color: Colors.green,
              onTap: () => Navigator.pushNamed(context, '/admin/ingest'),
            ),
            const SizedBox(height: 12),
            _buildCard(
              context,
              icon: Icons.quiz,
              title: "Gestionar Examen",
              subtitle: "Revisar y editar preguntas extraídas",
              color: Colors.orange,
              onTap: () => Navigator.pushNamed(context, '/admin/exams'),
            ),
            const SizedBox(height: 12),
            _buildCard(
              context,
              icon: Icons.analytics,
              title: "Monitoreo",
              subtitle: "Ver resultados y estadísticas",
              color: Colors.purple,
              onTap: () => Navigator.pushNamed(context, '/admin/monitoring'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
