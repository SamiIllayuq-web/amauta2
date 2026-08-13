// ===============================================================
// PROYECTO : ADMISIÓN AMAUTA
// ARCHIVO  : admin_monitoring_screen.dart
//
// DESCRIPCIÓN:
// Pantalla del administrador para visualizar estadisticas
// agregadas de los examenes rendidos por todos los postulantes.
//
// Muestra metricas generales como promedio de puntaje,
// tasa de aprobados, examen mas rendido y ranking de
// postulantes por desempeno.
//
// FLUJO
//
// AdminDashboardScreen
//        |
//        ▼
// /admin/monitoring
//        |
//        ▼
// ResultRepository.getAllResults()
//        |
//        ▼
// Calculos agregados (promedio, maxima, minima)
//        |
//        ▼
// Vista de metricas
//
// ===============================================================

library;

import 'package:flutter/material.dart';

import '../models/result_model.dart';
import '../models/user_model.dart';
import '../repositories/result_repository.dart';
import '../repositories/user_repository.dart';

// ===============================================================
// Pantalla principal de monitoreo.
// ===============================================================

class AdminMonitoringScreen extends StatefulWidget {

  const AdminMonitoringScreen({super.key});

  @override
  State<AdminMonitoringScreen> createState() => _AdminMonitoringScreenState();

}

class _AdminMonitoringScreenState extends State<AdminMonitoringScreen> {

  final ResultRepository _resultRepository = ResultRepository();
  final UserRepository _userRepository = UserRepository();

  // Todos los resultados obtenidos de la base de datos.
  List<Result> _allResults = [];

  // Bandera de carga.
  bool _isLoading = true;

  // ===============================================================
  // Carga todos los resultados y calcula metricas basicas.
  // ===============================================================

  Future<void> _loadData() async {

    final results = await _resultRepository.getAllResults();
    if (!mounted) return;

    setState(() {
      _allResults = results;
      _isLoading = false;
    });

  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoreo'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allResults.isEmpty
              ? const Center(
                  child: Text(
                    'Aun no hay resultados registrados.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ===========================================
                      // Resumen general.
                      // ===========================================

                      _buildSectionTitle('Resumen General'),
                      const SizedBox(height: 12),
                      _buildSummaryCards(),

                      const SizedBox(height: 32),

                      // ===========================================
                      // Ranking de postulantes.
                      // ===========================================

                      _buildSectionTitle('Ranking de Postulantes'),
                      const SizedBox(height: 12),
                      _buildRankingList(),

                    ],
                  ),
                ),
    );
  }

  // ===============================================================
  // Construye las tarjetas de resumen con las metricas.
  // ===============================================================

  Widget _buildSummaryCards() {

    final totalExams = _allResults.length;

    // Promedio de puntaje final entre todos los examenes rendidos.
    final avgScore = totalExams > 0
        ? _allResults.map((r) => r.finalScore).reduce((a, b) => a + b) / totalExams
        : 0.0;

    // Cantidad de examenes con puntaje mayor o igual a 140 (nota de corte).
    final passCount = _allResults.where((r) => r.finalScore >= 140).length;

    // Tiempo promedio de examen en minutos.
    final avgTime = totalExams > 0
        ? _allResults.map((r) => r.elapsedTime).reduce((a, b) => a + b) / totalExams / 60
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Total examenes',
            totalExams.toString(),
            Colors.blue,
            Icons.quiz,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Promedio nota',
            avgScore.toStringAsFixed(1),
            Colors.purple,
            Icons.analytics,
          ),
        ),
      ],
    );

  }

  // ===============================================================
  // Construye una tarjeta de metrica individual.
  // ===============================================================

  Widget _buildMetricCard(String label, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // Construye la lista de ranking de postulantes.
  // Ordena por promedio de puntaje final de mayor a menor.
  // ===============================================================

  Widget _buildRankingList() {

    // Obtener todos los usuarios postulantes.
    // Calcular el promedio de puntaje de cada uno.
    // Ordenar de mayor a menor.

    // Agrupa resultados por userId.
    final resultsByUser = <int, List<Result>>{};
    for (final r in _allResults) {
      resultsByUser.putIfAbsent(r.userId, () => []).add(r);
    }

    // Calcula promedio por usuario.
    final ranking = resultsByUser.entries.map((entry) {
      final avg = entry.value.map((r) => r.finalScore).reduce((a, b) => a + b)
          / entry.value.length;
      return MapEntry(entry.key, avg);
    }).toList();

    // Ordenar de mayor a menor promedio.
    ranking.sort((a, b) => b.value.compareTo(a.value));

    if (ranking.isEmpty) {
      return const Text('No hay datos suficientes.');
    }

    return Column(
      children: ranking.asMap().entries.map((entry) {
        final position = entry.key + 1;
        final userId = entry.value.key;
        final avg = entry.value.value;
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: position == 1
                  ? Colors.amber
                  : position == 2
                      ? Colors.grey
                      : position == 3
                          ? Colors.brown
                          : Colors.blue,
              child: Text(
                '#$position',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text('Postulante $userId'),
            trailing: Text(
              'Promedio: ${avg.toStringAsFixed(1)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );

  }

  // ===============================================================
  // Construye el titulo de una seccion.
  // ===============================================================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

}
