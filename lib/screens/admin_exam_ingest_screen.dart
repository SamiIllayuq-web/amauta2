/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : admin_exam_ingest_screen.dart
///
/// DESCRIPCIÓN:
/// Pantalla del administrador para ingestar examenes desde fotos.
/// Usa Gemini Vision para extraer preguntas de imagenes y las
/// guarda en la base de datos SQLite.
///
/// FLUJO
///
/// AdminDashboardScreen
///        |
///        v
/// /admin/ingest
///        |
///        v
/// 1. Seleccionar imagen (image_picker)
///        |
///        v
/// 2. Gemini Vision extrae preguntas (gemini_service.dart)
///        |
///        v
/// 3. Previsualizar preguntas extraidas
///        |
///        v
/// 4. Admin marca cual alternativa es correcta
///        |
///        v
/// 5. Seleccionar o crear Universidad y Area
///        |
///        v
/// 6. Guardar en SQLite (MockExam + Question + Alternative)
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
import '../services/gemini_service.dart';

class AdminExamIngestScreen extends StatefulWidget {

  const AdminExamIngestScreen({super.key});

  @override
  State<AdminExamIngestScreen> createState() => _AdminExamIngestScreenState();

}

class _AdminExamIngestScreenState extends State<AdminExamIngestScreen> {

  final GeminiService _geminiService = GeminiService();
  final ImagePicker _imagePicker = ImagePicker();

  final MockExamRepository _mockExamRepo = MockExamRepository();
  final QuestionRepository _questionRepo = QuestionRepository();
  final AlternativeRepository _alternativeRepo = AlternativeRepository();
  final UniversityRepository _universityRepo = UniversityRepository();
  final AreaRepository _areaRepo = AreaRepository();

  /// Estados posibles de la pantalla.
  /// imagen: sin imagen seleccionada aun.
  /// procesando: Gemini esta analizando la imagen.
  /// preview: imagen procesada, mostrando preguntas para revision.
  /// guardando: persistiendo en SQLite.
  String _estado = 'imagen';

  /// Ruta de la imagen seleccionada.
  String? _imagenPath;

  /// Preguntas extraidas por Gemini (en bruto).
  List<dynamic> _preguntasRaw = [];

  /// Titulo del examen devuelto por Gemini.
  String? _geminiExamTitle;

  /// Universidad devuelta por Gemini.
  String? _geminiUniversity;

  /// Ano devuelto por Gemini.
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

  /// Mapa: questionIndex -> letra de la respuesta correcta.
  /// Lo llena el admin antes de guardar.
  Map<int, String> _respuestasCorrectas = {};

  /// Mensaje de error.
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarUniversidadesYAreas();
  }

  @override
  void dispose() {
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

  /// Selecciona una imagen de la galeria y la envia a Gemini.
  Future<void> _seleccionarImagen() async {
    try {
      final XFile? imagen = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (imagen == null) return;

      setState(() {
        _imagenPath = imagen.path;
        _estado = 'procesando';
        _error = null;
      });

      final texto = await _geminiService.analyzeImage(imagen.path);
      final json = _geminiService.parseExamJson(texto);

      setState(() {
        _geminiExamTitle = json['exam_title'];
        _geminiUniversity = json['university'];
        _geminiYear = json['year']?.toString();
        _preguntasRaw = json['questions'] as List<dynamic>? ?? [];
        _estado = 'preview';
      });
    } catch (e) {
      setState(() {
        _error = 'Error al procesar imagen: $e';
        _estado = 'imagen';
      });
    }
  }

  /// Vuelve al estado inicial para seleccionar otra imagen.
  void _nuevaImagen() {
    setState(() {
      _imagenPath = null;
      _preguntasRaw = [];
      _geminiExamTitle = null;
      _geminiUniversity = null;
      _geminiYear = null;
      _estado = 'imagen';
      _error = null;
      _respuestasCorrectas = {};
      _universidadSeleccionada = null;
      _areaSeleccionada = null;
      _crearNuevaUniversidad = false;
      _crearNuevaArea = false;
      _nuevaUniversidadController.clear();
      _nuevaAreaController.clear();
      _duracionController.text = '120';
    });
  }

  /// Carga los datos seed directamente en la BD SQLite.
  /// Esto permite probar sin depender de Gemini Vision.
  Future<void> _cargarSeedData() async {
    setState(() => _estado = 'guardando');

    try {
      // Asegurar que existe area y universidad.
      int? universityId;
      int? areaId;

      // Crear universidad seed.
      final uni = University(
        universityName: examSeedData['university'] as String? ?? 'UNH',
        acronym: 'UNH',
      );
      universityId = await _universityRepo.createUniversity(uni);

      // Crear area seed.
      final area = Area(
        areaName: 'Comunicacion y Lenguaje',
        areaDescription: 'Area de comunicacion y lenguaje',
      );
      areaId = await _areaRepo.createArea(area);

      // Crear el examen.
      final examData = examSeedData;
      final exam = MockExam(
        universityId: universityId,
        areaId: areaId,
        title: examData['exam_title'] as String? ?? 'Examen Seed',
        description:
            'Examen seed cargado el ${DateTime.now().toString().substring(0, 10)}',
        examYear:
            int.tryParse(examData['year'] as String? ?? '2023') ?? 2023,
        durationMinutes: 120,
        totalQuestions: (examData['questions'] as List).length,
      );

      final examId = await _mockExamRepo.createMockExam(exam);

      // Crear preguntas y alternativas.
      final questions = examData['questions'] as List<dynamic>;
      for (var i = 0; i < questions.length; i++) {
        final q = questions[i] as Map<String, dynamic>;
        final pregunta = Question(
          mockExamId: examId,
          questionText: q['text'] as String? ?? '',
          explanation: '',
          questionScore: 1.0,
        );

        final preguntaId =
            await _questionRepo.createQuestion(pregunta);

        final alternativas = q['alternatives'] as List<dynamic>? ?? [];
        final correcta = q['correct'] as String? ?? 'A';

        for (var alt in alternativas) {
          final altMap = alt as Map<String, dynamic>;
          final letra = altMap['letter'] as String? ?? 'A';

          final alternativa = Alternative(
            questionId: preguntaId,
            alternativeText: altMap['text'] as String? ?? '',
            isCorrect: letra == correcta,
          );

          await _alternativeRepo.createAlternative(alternativa);
        }
      }

      if (mounted) {
        _mostrarSnackBar(
          'Examen seed guardado: ${questions.length} preguntas',
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _error = 'Error al cargar seed: $e';
        _estado = 'imagen';
      });
    }
  }

  /// Persiste el examen completo en SQLite.
  Future<void> _guardarExamen() async {
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

    // Validar que cada pregunta tenga respuesta correcta.
    for (var i = 0; i < _preguntasRaw.length; i++) {
      if (!_respuestasCorrectas.containsKey(i)) {
        _mostrarSnackBar('Marca la respuesta correcta para la pregunta ${i + 1}');
        return;
      }
    }

    setState(() => _estado = 'guardando');

    try {
      // 1. Crear o usar universidad.
      int? universityId;
      if (_crearNuevaUniversidad) {
        if (_nuevaUniversidadController.text.trim().isEmpty) {
          _mostrarSnackBar('Ingresa el nombre de la universidad');
          setState(() => _estado = 'preview');
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
        // Sin universidad: crear una generica.
        final gen = University(universityName: 'Universidad', acronym: '');
        universityId = await _universityRepo.createUniversity(gen);
      }

      // 2. Crear o usar area.
      int? areaId;
      if (_crearNuevaArea) {
        if (_nuevaAreaController.text.trim().isEmpty) {
          _mostrarSnackBar('Ingresa el nombre del area');
          setState(() => _estado = 'preview');
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
        final pregunta = Question(
          mockExamId: examId,
          questionText: raw['text'] ?? '',
          explanation: '',
        );

        final preguntaId =
            await _questionRepo.createQuestion(pregunta);

        // Alternativas.
        final alternativas = raw['alternatives'] as List<dynamic>? ?? [];
        for (var alt in alternativas) {
          final letra = alt['letter'] as String? ?? 'A';
          final correcta = _respuestasCorrectas[i] == letra;

          final alternativa = Alternative(
            questionId: preguntaId,
            alternativeText: alt['text'] ?? '',
            isCorrect: correcta,
          );

          await _alternativeRepo.createAlternative(alternativa);
        }
      }

      if (mounted) {
        _mostrarSnackBar(
          'Examen guardado con ${_preguntasRaw.length} preguntas',
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _error = 'Error al guardar: $e';
        _estado = 'preview';
      });
    }
  }

  void _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  // ============================================================
  // BUILD: estados de la pantalla
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingestar Examen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_estado == 'preview')
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Nueva imagen',
              onPressed: _nuevaImagen,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_estado) {
      case 'imagen':
        return _buildEstadoImagen();
      case 'procesando':
        return _buildEstadoProcesando();
      case 'preview':
        return _buildEstadoPreview();
      case 'guardando':
        return const Center(child: CircularProgressIndicator());
      default:
        return const Center(child: Text('Estado desconocido'));
    }
  }

  /// Estado inicial: boton para seleccionar imagen.
  Widget _buildEstadoImagen() {
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
            const Text(
              'Gemini Vision extraera las preguntas y alternativas',
              style: TextStyle(color: Colors.grey),
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
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Modo debug: cargar examenes de prueba',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _cargarSeedData,
              icon: const Icon(Icons.download),
              label: const Text('Cargar examenes seed (26 preguntas)'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
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

  /// Estado: esperando respuesta de Gemini.
  Widget _buildEstadoProcesando() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          const Text(
            'Analizando imagen con Gemini Vision...',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            _imagenPath ?? '',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Estado: previsualizar preguntas y configurar examen.
  Widget _buildEstadoPreview() {
    if (_preguntasRaw.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            const Text('No se detectaron preguntas en la imagen'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _nuevaImagen,
              child: const Text('Intentar otra imagen'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Preview de la imagen.
        if (_imagenPath != null)
          SizedBox(
            height: 120,
            width: double.infinity,
            child: Image.file(
              File(_imagenPath!),
              fit: BoxFit.cover,
            ),
          ),

        // Informacion del examen.
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_geminiExamTitle != null)
                Text(
                  'Titulo: $_geminiExamTitle',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              if (_geminiUniversity != null)
                Text('Universidad: $_geminiUniversity'),
              if (_geminiYear != null) Text('Ano: $_geminiYear'),
              Text('Preguntas encontradas: ${_preguntasRaw.length}'),
            ],
          ),
        ),

        const Divider(),

        // Configuracion del examen.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              // Universidad.
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<bool>(
                      value: _crearNuevaUniversidad,
                      isExpanded: true,
                      hint: const Text('Universidad'),
                      items: [
                        const DropdownMenuItem(
                          value: false,
                          child: Text('Seleccionar existente'),
                        ),
                        const DropdownMenuItem(
                          value: true,
                          child: Text('Crear nueva'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _crearNuevaUniversidad = value!);
                      },
                    ),
                  ),
                ],
              ),
              if (_crearNuevaUniversidad)
                TextField(
                  controller: _nuevaUniversidadController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la universidad',
                    border: OutlineInputBorder(),
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

              // Area.
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<bool>(
                      value: _crearNuevaArea,
                      isExpanded: true,
                      hint: const Text('Area'),
                      items: [
                        const DropdownMenuItem(
                          value: false,
                          child: Text('Seleccionar existente'),
                        ),
                        const DropdownMenuItem(
                          value: true,
                          child: Text('Crear nueva'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _crearNuevaArea = value!);
                      },
                    ),
                  ),
                ],
              ),
              if (_crearNuevaArea)
                TextField(
                  controller: _nuevaAreaController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del area',
                    border: OutlineInputBorder(),
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

              // Duracion.
              TextField(
                controller: _duracionController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duracion (minutos)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),

        const Divider(),

        // Lista de preguntas con selector de respuesta correcta.
        Expanded(
          child: ListView.builder(
            itemCount: _preguntasRaw.length,
            itemBuilder: (context, index) {
              return _buildPreguntaPreview(index, _preguntasRaw[index]);
            },
          ),
        ),

        // Boton guardar.
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _guardarExamen,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('GUARDAR EXAMEN'),
            ),
          ),
        ),

        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  /// Previsualiza una pregunta individual con el selector
  /// de respuesta correcta.
  Widget _buildPreguntaPreview(int index, dynamic preguntaRaw) {
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
            // Numero y texto de la pregunta.
            Text(
              '${index + 1}. $preguntaTexto',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Alternativas con radio buttons.
            ...alternativas.map<Widget>((alt) {
              final letra = alt['letter'] as String? ?? '?';
              final textoAlt = alt['text'] as String? ?? '';

              return RadioListTile<String>(
                dense: true,
                visualDensity: VisualDensity.compact,
                title: Text('$letra) $textoAlt'),
                value: letra,
                groupValue: _respuestasCorrectas[index],
                onChanged: (value) {
                  setState(() {
                    _respuestasCorrectas[index] = value!;
                  });
                },
              );
            }).toList(),

            // Indicador si ya se marco respuesta.
            if (!_respuestasCorrectas.containsKey(index))
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Marca la respuesta correcta',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
