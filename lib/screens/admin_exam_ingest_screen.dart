/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : admin_exam_ingest_screen.dart
///
/// DESCRIPCIÓN:
/// Pantalla del administrador para ingestar examenes desde fotos.
/// Usa Gemini Vision para extraer preguntas de imagenes.
///
/// FLUJO (3 pasos con stepper):
///
/// AdminDashboardScreen
///        |
///        v
/// /admin/ingest
///        |
///        v
/// Paso 1: Seleccionar imagen → Gemini OCR
///              |
///              v
/// Paso 2: Revisar extracción → editar texto, marcar correcta
///              |
///              v
/// Paso 3: Enviar a IA → análisis Gemini pregunta por pregunta
///              |
///              v
/// Guardar → SQLite (MockExam + Question + Alternative + AI data)
///
/// ===============================================================

library;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/alternative_model.dart';
import '../models/area_model.dart';
import '../models/mock_exam_model.dart';
import '../models/question_model.dart';
import '../models/university_model.dart';
import '../repositories/alternative_repository.dart';
import '../repositories/area_repository.dart';
import '../repositories/mock_exam_repository.dart';
import '../repositories/question_repository.dart';
import '../repositories/university_repository.dart';
import '../data/exam_seed_data.dart';
import '../services/error_service.dart';
import '../services/connectivity_service.dart';
import '../services/gemini_service.dart';

class AdminExamIngestScreen extends StatefulWidget {

  const AdminExamIngestScreen({super.key});

  @override
  State<AdminExamIngestScreen> createState() => _AdminExamIngestScreenState();

}

class _AdminExamIngestScreenState extends State<AdminExamIngestScreen> {

  final GeminiService _geminiService = GeminiService();
  final ImagePicker _imagePicker = ImagePicker();
  final ConnectivityService _connectivity = ConnectivityService();

  final MockExamRepository _mockExamRepo = MockExamRepository();
  final QuestionRepository _questionRepo = QuestionRepository();
  final AlternativeRepository _alternativeRepo = AlternativeRepository();
  final UniversityRepository _universityRepo = UniversityRepository();
  final AreaRepository _areaRepo = AreaRepository();

  // ============================================================
  // ESTADOS DEL STEPPER
  // 0 = imagen (antes de empezar)
  // 1 = revision (OCR hecho, revisar/editar)
  // 2 = analisis (IA analizando)
  // 3 = guardando
  // ============================================================
  int _paso = 0;

  /// Ruta de la imagen seleccionada.
  String? _imagenPath;

  /// Preguntas extraidas por Gemini (en bruto, editables).
  List<dynamic> _preguntasRaw = [];

  /// Mapa: questionIndex -> letra de la respuesta correcta.
  Map<int, String> _respuestasCorrectas = {};

  /// Preguntas ya analizadas por IA: questionIndex -> (correctLetter, explanation).
  Map<int, GeminiAnalysisResult> _resultadosIA = {};

  /// Indice de pregunta actualmente siendo analizada por IA.
  int _indiceAnalizando = -1;

  /// Titulo del examen devuelto por Gemini.
  String? _geminiExamTitle;

  /// Universidad devuelta por Gemini.
  String? _geminiUniversity;

  /// Año devuelto por Gemini.
  String? _geminiYear;

  /// Universidad seleccionada por el admin.
  University? _universidadSeleccionada;

  /// Nueva universidad a crear.
  final TextEditingController _nuevaUniversidadController =
      TextEditingController();

  bool _crearNuevaUniversidad = false;

  /// Area seleccionada por el admin.
  Area? _areaSeleccionada;

  /// Nueva area a crear.
  final TextEditingController _nuevaAreaController = TextEditingController();

  bool _crearNuevaArea = false;

  /// Duracion del examen en minutos.
  final TextEditingController _duracionController =
      TextEditingController(text: '120');

  /// Lista de universidades y areas disponibles.
  List<University> _universidades = [];
  List<Area> _areas = [];

  /// Mensaje de error.
  String? _error;

  /// Estado de conectividad.
  bool _isOnline = true;

  /// Instancia del diagnóstico de error actual.
  DiagnosedError? _diagnostic;

  @override
  void initState() {
    super.initState();
    _cargarUniversidadesYAreas();
    _connectivity.startMonitoring((isOnline) {
      if (mounted) {
        setState(() => _isOnline = isOnline);
        if (!isOnline) {
          _mostrarSnackBar('Sin conexión a internet', isError: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _connectivity.stopMonitoring();
    _nuevaUniversidadController.dispose();
    _nuevaAreaController.dispose();
    _duracionController.dispose();
    super.dispose();
  }

  /// Carga universidades y areas desde SQLite para el selector.
  Future<void> _cargarUniversidadesYAreas() async {
    final unis = await _universityRepo.getAllUniversities();
    final areas = await _areaRepo.getAllAreas();
    setState(() {
      _universidades = unis;
      _areas = areas;
    });
  }

  // ============================================================
  // PASO 0 → 1: Seleccionar imagen + OCR
  // ============================================================
  Future<void> _seleccionarImagen() async {
    if (!_isOnline) {
      _mostrarSnackBar('Sin conexión. Conecta a internet para usar Gemini.', isError: true);
      return;
    }

    try {
      setState(() {
        _error = null;
        _diagnostic = null;
      });

      final XFile? imagen = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (imagen == null) return;

      setState(() {
        _imagenPath = imagen.path;
        _error = null;
      });

      final texto = await _geminiService.analyzeImage(imagen.path);
      final json = _geminiService.parseExamJson(texto);

      setState(() {
        _geminiExamTitle = json['exam_title'];
        _geminiUniversity = json['university'];
        _geminiYear = json['year']?.toString();
        _preguntasRaw = json['questions'] as List<dynamic>? ?? [];
        _respuestasCorrectas = {};
        _resultadosIA = {};
        _paso = 1; // Avanzar al paso de revision
      });
    } on Exception catch (e) {
      final diagnosed = ErrorService.diagnose(e);
      ErrorService.log(diagnosed, context: 'OCR');
      setState(() {
        _error = diagnosed.message;
        _diagnostic = diagnosed;
      });
    }
  }

  // ============================================================
  // PASO 1 → 2: Enviar preguntas a IA (analisis secuencial)
  // ============================================================
  Future<void> _enviarAIA() async {
    // Validar que cada pregunta tenga respuesta correcta marcada.
    for (var i = 0; i < _preguntasRaw.length; i++) {
      if (!_respuestasCorrectas.containsKey(i)) {
        _mostrarSnackBar('Marca la respuesta correcta para la pregunta ${i + 1}');
        return;
      }
    }

    setState(() {
      _paso = 2;
      _indiceAnalizando = 0;
    });

    // Analizar pregunta por pregunta secuencialmente.
    for (var i = 0; i < _preguntasRaw.length; i++) {
      if (!mounted) return;
      setState(() => _indiceAnalizando = i);

      final pregunta = _preguntasRaw[i];
      final alternativas = pregunta['alternatives'] as List<dynamic>? ?? [];

      try {
        // Convertir List<dynamic> a Map<String, String> para Gemini.
        final altMap = <String, String>{};
        for (var alt in alternativas) {
          final letra = (alt as Map<String, dynamic>)['letter'] as String? ?? '?';
          final texto = (alt as Map<String, dynamic>)['text'] as String? ?? '';
          altMap[letra] = texto;
        }

        final resultado = await _geminiService.analyzeQuestion(
          pregunta['text'] ?? '',
          altMap,
        );

        setState(() {
          _resultadosIA[i] = resultado;
        });
      } on Exception catch (e) {
        // Si falla, guardar con datos vacios.
        setState(() {
          _resultadosIA[i] = GeminiAnalysisResult(
            correctLetter: _respuestasCorrectas[i] ?? 'A',
            explanation: 'Error al analizar: $e',
          );
        });
      }

      // Actualizar UI entre cada pregunta.
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (!mounted) return;
    setState(() => _indiceAnalizando = -1);
    _mostrarSnackBar('Análisis IA completado');
  }

  // ============================================================
  // PASO 2 → 3: Guardar todo en SQLite
  // ============================================================
  Future<void> _guardar() async {
    if (_areaSeleccionada == null && !_crearNuevaArea) {
      _mostrarSnackBar('Selecciona o crea un area');
      return;
    }

    if (_duracionController.text.isEmpty) {
      _mostrarSnackBar('Ingresa la duracion del examen');
      return;
    }

    final duracion = int.tryParse(_duracionController.text);
    if (duracion == null || duracion <= 0) {
      _mostrarSnackBar('Duracion invalida');
      return;
    }

    setState(() => _paso = 3);

    try {
      // 1. Crear o usar universidad.
      int? universityId;
      if (_crearNuevaUniversidad) {
        if (_nuevaUniversidadController.text.trim().isEmpty) {
          setState(() => _paso = 2);
          _mostrarSnackBar('Ingresa el nombre de la universidad');
          return;
        }
        final nueva = University(
          universityName: _nuevaUniversidadController.text.trim(),
          acronym: '',
        );
        universityId = await _universityRepo.createUniversity(nueva);
      } else if (_universidadSeleccionada != null) {
        universityId = _universidadSeleccionada!.universityId;
      } else {
        final gen = University(universityName: 'Universidad', acronym: '');
        universityId = await _universityRepo.createUniversity(gen);
      }

      // 2. Crear o usar area.
      int? areaId;
      if (_crearNuevaArea) {
        if (_nuevaAreaController.text.trim().isEmpty) {
          setState(() => _paso = 2);
          _mostrarSnackBar('Ingresa el nombre del area');
          return;
        }
        final nueva = Area(
          areaName: _nuevaAreaController.text.trim(),
          areaDescription: '',
        );
        areaId = await _areaRepo.createArea(nueva);
      } else {
        areaId = _areaSeleccionada!.areaId;
      }

      // 3. Crear el MockExam.
      final examen = MockExam(
        universityId: universityId ?? 1,
        areaId: areaId ?? 1,
        title: _geminiExamTitle ?? 'Examen sin titulo',
        description: 'Ingestado desde imagen el '
            '${DateTime.now().toString().substring(0, 10)}',
        examYear: int.tryParse(_geminiYear ?? '2024') ?? 2024,
        durationMinutes: duracion,
        totalQuestions: _preguntasRaw.length,
      );

      final examId = await _mockExamRepo.createMockExam(examen);

      // 4. Crear cada pregunta y sus alternativas.
      for (var i = 0; i < _preguntasRaw.length; i++) {
        final raw = _preguntasRaw[i];
        final iaResult = _resultadosIA[i];

        // La respuesta correcta viene de IA si esta disponible,
        // si no de lo que el admin marcó manualmente.
        final letraCorrecta = iaResult?.correctLetter ?? _respuestasCorrectas[i] ?? 'A';
        final explicacionIA = iaResult?.explanation ?? '';

        final pregunta = Question(
          mockExamId: examId,
          questionText: raw['text'] ?? '',
          explanation: explicacionIA,
          correctAlternativeId: null, // se atualiza abajo
        );

        final preguntaId = await _questionRepo.createQuestion(pregunta);

        // Alternativas.
        final alternativas = raw['alternatives'] as List<dynamic>? ?? [];
        for (var alt in alternativas) {
          final letra = alt['letter'] as String? ?? 'A';
          final esCorrecta = letra == letraCorrecta;

          final alternativa = Alternative(
            questionId: preguntaId,
            alternativeText: alt['text'] ?? '',
            isCorrect: esCorrecta,
          );

          final altId = await _alternativeRepo.createAlternative(alternativa);

          // Si esta alternativa es la correcta, guardar el ID en la pregunta.
          if (esCorrecta) {
            await _questionRepo.updateQuestionAnalysis(
              preguntaId,
              altId,
              explicacionIA,
            );
          }
        }
      }

      if (mounted) {
        _mostrarSnackBar('Examen guardado con ${_preguntasRaw.length} preguntas');
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _error = 'Error al guardar: $e';
        _paso = 2;
      });
    }
  }

  // ============================================================
  // Helpers
  // ============================================================
  void _mostrarSnackBar(String mensaje, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: isError ? Colors.red[700] : null,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  void _reiniciar() {
    setState(() {
      _paso = 0;
      _imagenPath = null;
      _preguntasRaw = [];
      _respuestasCorrectas = {};
      _resultadosIA = {};
      _indiceAnalizando = -1;
      _geminiExamTitle = null;
      _geminiUniversity = null;
      _geminiYear = null;
      _universidadSeleccionada = null;
      _crearNuevaUniversidad = false;
      _areaSeleccionada = null;
      _crearNuevaArea = false;
      _nuevaUniversidadController.clear();
      _nuevaAreaController.clear();
      _duracionController.text = '120';
      _error = null;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingestar Examen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_paso > 0)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reiniciar',
              onPressed: _reiniciar,
            ),
        ],
      ),
      body: Column(
        children: [
          // Banner de conectividad
          _buildConnectivityBanner(),

          // Stepper horizontal: 3 pasos
          _buildStepper(),

          // Contenido del paso actual
          Expanded(
            child: _buildContenidoPaso(),
          ),

          // Error con diagnóstico
          if (_error != null)
            _buildErrorDisplay(),
        ],
      ),
    );
  }

  /// Stepper horizontal: Revisar | IA | Guardar
  Widget _buildStepper() {
    final pasos = ['Revisar', 'IA', 'Guardar'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(pasos.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Separador
            final pasoIdx = index ~/ 2;
            final isActivo = _paso > pasoIdx;
            return Container(
              width: 40,
              height: 2,
              color: isActivo
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[300],
            );
          } else {
            // Circulo de paso
            final pasoIdx = index ~/ 2;
            final isActivo = _paso >= pasoIdx;
            final isActual = _paso == pasoIdx;
            return _buildCirculoPaso(
              numero: pasoIdx + 1,
              label: pasos[pasoIdx],
              isActivo: isActivo,
              isActual: isActual,
            );
          }
        }),
      ),
    );
  }

  Widget _buildCirculoPaso({
    required int numero,
    required String label,
    required bool isActivo,
    required bool isActual,
  }) {
    final color = isActivo
        ? Theme.of(context).colorScheme.primary
        : Colors.grey[400]!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActivo ? color : Colors.grey[200],
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: isActivo && !isActual
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '$numero',
                    style: TextStyle(
                      color: isActivo ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActivo ? color : Colors.grey,
            fontWeight: isActual ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  /// Contenido segun el paso actual.
  Widget _buildContenidoPaso() {
    switch (_paso) {
      case 0:
        return _buildPaso0Imagen();
      case 1:
        return _buildPaso1Revision();
      case 2:
        return _buildPaso2IA();
      case 3:
        return const Center(child: CircularProgressIndicator());
      default:
        return const Center(child: Text('Error de estado'));
    }
  }

  // ============================================================
  // BANNER DE CONECTIVIDAD
  // ============================================================

  Widget _buildConnectivityBanner() {
    if (_isOnline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.red[700],
      child: const Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Modo offline — Sin conexión a internet',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PANTALLA DE ERROR DIAGNOSTICADO
  // ============================================================

  Widget _buildErrorDisplay() {
    final diag = _diagnostic;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.red[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              if (diag != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    diag.code,
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (diag != null && diag.suggestion.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.orange[700], size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    diag.suggestion,
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // PASO 0: Seleccionar imagen
  // ============================================================
  Widget _buildPaso0Imagen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Selecciona una foto del examen',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Paso 1 de 3: Gemini Vision extraera las preguntas',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _seleccionarImagen,
              icon: const Icon(Icons.photo_library),
              label: const Text('Elegir imagen'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PASO 1: Revisar extraccion OCR
  // ============================================================
  Widget _buildPaso1Revision() {
    return Column(
      children: [
        // Info del examen extraido
        if (_geminiExamTitle != null || _geminiUniversity != null)
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blue[50],
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_geminiExamTitle != null)
                        Text('Título: $_geminiExamTitle',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (_geminiUniversity != null)
                        Text('Universidad: $_geminiUniversity'),
                      if (_geminiYear != null) Text('Año: $_geminiYear'),
                      Text('Preguntas: ${_preguntasRaw.length}'),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Configuracion del examen
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              // Universidad
              DropdownButton<bool>(
                value: _crearNuevaUniversidad,
                isExpanded: true,
                hint: const Text('Universidad'),
                items: const [
                  DropdownMenuItem(value: false, child: Text('Seleccionar existente')),
                  DropdownMenuItem(value: true, child: Text('Crear nueva')),
                ],
                onChanged: (value) {
                  setState(() => _crearNuevaUniversidad = value!);
                },
              ),
              if (_crearNuevaUniversidad)
                TextField(
                  controller: _nuevaUniversidadController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la universidad',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                )
              else
                DropdownButton<int>(
                  value: _universidadSeleccionada?.universityId,
                  isExpanded: true,
                  hint: const Text('Seleccionar universidad'),
                  items: _universidades.map((u) {
                    return DropdownMenuItem(
                      value: u.universityId,
                      child: Text(u.universityName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _universidadSeleccionada = _universidades.firstWhere(
                        (u) => u.universityId == value,
                      );
                    });
                  },
                ),

              const SizedBox(height: 8),

              // Area
              DropdownButton<bool>(
                value: _crearNuevaArea,
                isExpanded: true,
                hint: const Text('Area'),
                items: const [
                  DropdownMenuItem(value: false, child: Text('Seleccionar existente')),
                  DropdownMenuItem(value: true, child: Text('Crear nueva')),
                ],
                onChanged: (value) {
                  setState(() => _crearNuevaArea = value!);
                },
              ),
              if (_crearNuevaArea)
                TextField(
                  controller: _nuevaAreaController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del area',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                )
              else
                DropdownButton<int>(
                  value: _areaSeleccionada?.areaId,
                  isExpanded: true,
                  hint: const Text('Seleccionar area'),
                  items: _areas.map((a) {
                    return DropdownMenuItem(
                      value: a.areaId,
                      child: Text(a.areaName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _areaSeleccionada = _areas.firstWhere(
                        (a) => a.areaId == value,
                      );
                    });
                  },
                ),

              const SizedBox(height: 8),

              // Duracion
              TextField(
                controller: _duracionController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duracion (minutos)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
          ),
        ),

        const Divider(),

        // Instruccion
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(Icons.edit_note, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Revisa cada pregunta y marca la respuesta correcta',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // Lista de preguntas
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 8),
            itemCount: _preguntasRaw.length,
            itemBuilder: (context, index) {
              return _buildPreguntaRevision(index, _preguntasRaw[index]);
            },
          ),
        ),

        // Boton enviar a IA
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _enviarAIA,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('ENVIAR A IA'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Pregunta individual en el paso de revision.
  Widget _buildPreguntaRevision(int index, dynamic preguntaRaw) {
    final alternativas =
        preguntaRaw['alternatives'] as List<dynamic>? ?? [];
    final preguntaTexto = preguntaRaw['text'] ?? 'Sin texto';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.blue,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    preguntaTexto,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Alternativas con radio.
            ...alternativas.map<Widget>((alt) {
              final letra = alt['letter'] as String? ?? '?';
              final textoAlt = alt['text'] as String? ?? '';

              return RadioListTile<String>(
                dense: true,
                visualDensity: VisualDensity.compact,
                title: Text(
                  '$letra) $textoAlt',
                  style: const TextStyle(fontSize: 14),
                ),
                value: letra,
                groupValue: _respuestasCorrectas[index],
                onChanged: (value) {
                  setState(() {
                    _respuestasCorrectas[index] = value!;
                  });
                },
              );
            }).toList(),

            // Indicador si falta marcar.
            if (!_respuestasCorrectas.containsKey(index))
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  '⚠ Marca la respuesta correcta',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PASO 2: IA analizando
  // ============================================================
  Widget _buildPaso2IA() {
    final total = _preguntasRaw.length;
    final actual = _indiceAnalizando >= 0 ? _indiceAnalizando + 1 : total;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_indiceAnalizando >= 0) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Analizando pregunta $actual de $total',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_indiceAnalizando >= 0 && _indiceAnalizando < _preguntasRaw.length)
                Text(
                  _preguntasRaw[_indiceAnalizando]['text'] ?? '',
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 24),
              LinearProgressIndicator(
                value: _indiceAnalizando / total,
              ),
              const SizedBox(height: 8),
              Text(
                '${((_indiceAnalizando / total) * 100).toInt()}%',
                style: const TextStyle(color: Colors.grey),
              ),
            ] else ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Análisis completado',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '$total preguntas analizadas',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Resumen de lo analizado
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Listo para guardar',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cada pregunta tiene respuesta correcta y explicación de IA.',
                      style: TextStyle(color: Colors.green[700], fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Boton guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _guardar,
                  icon: const Icon(Icons.save),
                  label: const Text('GUARDAR EXAMEN'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
