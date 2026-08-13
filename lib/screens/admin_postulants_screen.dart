// ===============================================================
// PROYECTO : ADMISIÓN AMAUTA
// ARCHIVO  : admin_postulants_screen.dart
//
// DESCRIPCIÓN:
// Pantalla del administrador para visualizar la lista de
// postulantes registrados en el sistema.
//
// Cada fila muestra el nombre, email y cantidad de examenes
// rendidos. Al tocar un postulante se abre su detalle con
// los resultados de cada simulacro.
//
// FLUJO
//
// AdminDashboardScreen
//        |
//        ▼
// /admin/postulants
//        |
//        ▼
// UserRepository.getAllUsers()  (filtra solo POSTULANTE)
//        |
//        ▼
// Lista de postulantes
//        |
//        ▼
// Tap → AdminPostulantDetailScreen (resultados del postulante)
//
// ===============================================================

library;

import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../models/result_model.dart';
import '../repositories/user_repository.dart';
import '../repositories/result_repository.dart';
import '../database/database_constants.dart';

// ===============================================================
// Pantalla principal de postulantes.
// ===============================================================

class AdminPostulantsScreen extends StatefulWidget {

  const AdminPostulantsScreen({super.key});

  @override
  State<AdminPostulantsScreen> createState() => _AdminPostulantsScreenState();

}

class _AdminPostulantsScreenState extends State<AdminPostulantsScreen> {

  // Repositorio para obtener los usuarios postulantes.
  final UserRepository _userRepository = UserRepository();

  // Repositorio para obtener los resultados de un postulante.
  final ResultRepository _resultRepository = ResultRepository();

  // Lista de postulantes traidos de la base de datos.
  List<User> _postulants = [];

  // Contador de examenes rendidos por cada postulante.
  // La clave es el userId y el valor es la cantidad de resultados.
  Map<int, int> _examCounts = {};

  // Bandera que indica si se estan cargando los datos.
  bool _isLoading = true;

  // ===============================================================
  // Carga la lista de postulantes desde la base de datos.
  // Solo se muestran usuarios con rol POSTULANTE.
  // ===============================================================

  Future<void> _loadPostulants() async {

    // Obtener todos los usuarios.
    final users = await _userRepository.getAllUsers();

    // Filtrar solo los que tienen rol de postulante.
    final postulants = users
        .where((u) => u.role == DBConstants.rolePostulante)
        .toList();

    // Para cada postulante, contar quantos examenes ha rendido.
    final examCounts = <int, int>{};
    for (final p in postulants) {
      if (p.userId != null) {
        final results = await _resultRepository.getResultsByUser(p.userId!);
        examCounts[p.userId!] = results.length;
      }
    }

    if (!mounted) return;

    setState(() {
      _postulants = postulants;
      _examCounts = examCounts;
      _isLoading = false;
    });

  }

  @override
  void initState() {
    super.initState();
    _loadPostulants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Postulantes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _postulants.isEmpty
              ? const Center(
                  child: Text(
                    'No hay postulantes registrados.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _postulants.length,
                  itemBuilder: (context, index) {
                    final postulant = _postulants[index];
                    final examCount = _examCounts[postulant.userId] ?? 0;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            postulant.firstName.isNotEmpty
                                ? postulant.firstName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          postulant.firstName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(postulant.email),
                        trailing: Text(
                          '$examCount examenes',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        onTap: () {
                          // Navegar al detalle del postulante con sus resultados.
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminPostulantDetailScreen(
                                user: postulant,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }

}

// ===============================================================
// Pantalla de detalle de un postulante.
// Muestra sus datos y la lista de resultados de examenes.
// ===============================================================

class AdminPostulantDetailScreen extends StatefulWidget {

  // Usuario seleccionado.
  final User user;

  const AdminPostulantDetailScreen({
    super.key,
    required this.user,
  });

  @override
  State<AdminPostulantDetailScreen> createState() =>
      _AdminPostulantDetailScreenState();

}

class _AdminPostulantDetailScreenState
    extends State<AdminPostulantDetailScreen> {

  final ResultRepository _resultRepository = ResultRepository();

  List<Result> _results = [];
  bool _isLoading = true;

  // ===============================================================
  // Carga los resultados del postulante seleccionado.
  // ===============================================================

  Future<void> _loadResults() async {
    final results = await _resultRepository.getResultsByUser(widget.user.userId!);
    if (!mounted) return;
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.user.firstName} ${widget.user.lastName}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? const Center(
                  child: Text(
                    'Este postulante aun no ha rendido examenes.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Informacion del postulante.
                      Text(
                        'Email: ${widget.user.email}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Registrado: ${widget.user.createdAt ?? "Desconocido"}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Historial de examenes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final result = _results[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getScoreColor(result.finalScore),
                                  child: Text(
                                    result.finalScore.toInt().toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text('Examen ${result.mockExamId}'),
                                subtitle: Text(
                                  'Correctas: ${result.correctAnswers}  |  '
                                  'Incorrectas: ${result.incorrectAnswers}',
                                ),
                                trailing: Text(
                                  _formatTime(result.elapsedTime),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  // ===============================================================
  // Devuelve un color segun el puntaje final.
  // Verde = aprobado (>= 140), naranja = en riesgo (>= 100),
  // rojo = bajo (< 100).
  // ===============================================================

  Color _getScoreColor(double score) {
    if (score >= 140) return Colors.green;
    if (score >= 100) return Colors.orange;
    return Colors.red;
  }

  // ===============================================================
  // Formatea los segundos transcurridos a formato MM:SS.
  // ===============================================================

  String _formatTime(int seconds) {
    return '${(seconds ~/ 60).toString().padLeft(2, '0')}:'
        '${(seconds % 60).toString().padLeft(2, '0')}';
  }

}
