/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : ai_review_screen.dart
///
/// DESCRIPCIÓN:
/// Pantalla para que el estudiante revise las respuestas de un
/// simulacro con explicacion de IA.
///
/// Muestra una lista de preguntas del examen realizado. Cada
/// card indica si la respuesta fue correcta o incorrecta.
/// Al hacer tap, abre el detalle con la explicacion.
///
/// FLUJO
///
/// ResultScreen
///        |
///        v
/// resultId + mockExamId
///        |
///        v
/// AIReviewScreen
///        |
///        v
/// Lista de preguntas respondidas
///   Tap pregunta
///        |
///        v
/// Detalle: pregunta + alternativas + explicacion IA
/// ===============================================================

library;

import 'package:flutter/material.dart';

import '../models/alternative_model.dart';
import '../models/question_model.dart';
import '../models/user_answer_model.dart';
import '../repositories/alternative_repository.dart';
import '../repositories/question_repository.dart';
import '../repositories/user_answer_repository.dart';
import '../repositories/mock_exam_repository.dart';
import '../models/mock_exam_model.dart';
import '../services/gemini_service.dart';

class AIReviewScreen extends StatefulWidget {

  final int resultId;
  final int mockExamId;

  const AIReviewScreen({
    super.key,
    required this.resultId,
    required this.mockExamId,
  });

  @override
  State<AIReviewScreen> createState() => _AIReviewScreenState();

}

class _AIReviewScreenState extends State<AIReviewScreen> {

  final UserAnswerRepository _userAnswerRepo = UserAnswerRepository();
  final QuestionRepository _questionRepo = QuestionRepository();
  final AlternativeRepository _alternativeRepo = AlternativeRepository();
  final MockExamRepository _mockExamRepo = MockExamRepository();
  final GeminiService _geminiService = GeminiService();

  bool _loading = true;
  String? _error;

  /// Preguntas con datos de respuesta del estudiante.
  List<_PreguntaConRespuesta> _preguntas = [];

  /// MockExam info.
  MockExam? _exam;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Cargar examen.
      final exam = await _mockExamRepo.getMockExamById(widget.mockExamId);
      if (exam == null) throw Exception('Examen no encontrado');

      // Cargar preguntas del examen.
      final questions =
          await _questionRepo.getQuestionsByMockExam(widget.mockExamId);

      // Cargar respuestas del estudiante.
      final userAnswers = await _userAnswerRepo
          .getUserAnswersWithCorrectness(widget.resultId);

      // Crear mapa de respuestas por questionId.
      final answerMap = <int, UserAnswer>{};
      for (final ua in userAnswers) {
        answerMap[ua.questionId] = ua;
      }

      // Construir lista con datos combinados.
      final List<_PreguntaConRespuesta> preguntas = [];
      for (final q in questions) {
        final answer = answerMap[q.questionId];
        if (answer == null) continue; // pregunta no respondida

        final alternatives = await _alternativeRepo
            .getAlternativesByQuestion(q.questionId!);

        // Obtener la alternativa que el usuario eligio.
        final selectedAlternative = alternatives.firstWhere(
          (a) => a.alternativeId == answer.selectedAlternativeId,
          orElse: () => alternatives.first,
        );

        // Obtener la alternativa correcta (si existe).
        Alternative? correctAlternative;
        if (q.correctAlternativeId != null) {
          correctAlternative = alternatives.firstWhere(
            (a) => a.alternativeId == q.correctAlternativeId,
            orElse: () => alternatives.first,
          );
        } else {
          // No hay analisis de IA: buscar la marcada como is_correct en la BD.
          correctAlternative = alternatives.where((a) => a.isCorrect).firstOrNull;
        }

        preguntas.add(_PreguntaConRespuesta(
          question: q,
          alternatives: alternatives,
          selectedAlternative: selectedAlternative,
          correctAlternative: correctAlternative,
          isCorrect: answer.isCorrect,
        ));
      }

      setState(() {
        _exam = exam;
        _preguntas = preguntas;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar datos: $e';
        _loading = false;
      });
    }
  }

  int get _correctas => _preguntas.where((p) => p.isCorrect).length;
  int get _incorrectas => _preguntas.where((p) => !p.isCorrect).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_exam?.title ?? 'Revision con IA'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Resumen.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Column(
            children: [
              Text(
                '$_correctas / ${_preguntas.length} correctas',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _exam?.title ?? '',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),

        // Leyenda.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _legendItem(Colors.green, 'Correcta'),
              const SizedBox(width: 16),
              _legendItem(Colors.red, 'Incorrecta'),
              const SizedBox(width: 16),
              _legendItem(Colors.grey, 'Sin analizar'),
            ],
          ),
        ),

        const Divider(),

        // Lista de preguntas.
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _preguntas.length,
            itemBuilder: (context, index) {
              return _buildQuestionCard(index, _preguntas[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildQuestionCard(int index, _PreguntaConRespuesta data) {
    final letters = ['A', 'B', 'C', 'D', 'E'];
    final selectedLetter = letters.indexWhere(
      (l) => data.alternatives.indexOf(data.selectedAlternative) == letters.indexOf(l),
    );

    Color statusColor;
    IconData statusIcon;
    if (data.question.correctAlternativeId == null && data.correctAlternative == null) {
      statusColor = Colors.grey;
      statusIcon = Icons.help_outline;
    } else if (data.isCorrect) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _openDetail(data),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Numero de pregunta.
              CircleAvatar(
                radius: 16,
                backgroundColor: statusColor.withValues(alpha: 0.2),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(color: statusColor, fontSize: 12),
                ),
              ),
              const SizedBox(width: 12),

              // Texto de la pregunta.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.question.questionText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.question.correctAlternativeId == null
                          ? 'Sin analizar con IA'
                          : (data.isCorrect
                              ? 'Correcta'
                              : 'Incorrecta'),
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Icono de estado.
              Icon(statusIcon, color: statusColor),

              const SizedBox(width: 8),

              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  /// Abre el detalle de una pregunta.
  Future<void> _openDetail(_PreguntaConRespuesta data) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _QuestionDetailScreen(
          data: data,
          geminiService: _geminiService,
          questionRepo: _questionRepo,
        ),
      ),
    );
  }
}

/// ===============================================================
/// Datos combinados de pregunta + respuesta del estudiante.
// ===============================================================

class _PreguntaConRespuesta {
  final Question question;
  final List<Alternative> alternatives;
  final Alternative selectedAlternative;
  final Alternative? correctAlternative;
  final bool isCorrect;

  _PreguntaConRespuesta({
    required this.question,
    required this.alternatives,
    required this.selectedAlternative,
    required this.correctAlternative,
    required this.isCorrect,
  });
}

/// ===============================================================
/// Pantalla detalle de una pregunta con explicacion de IA.
// ===============================================================

class _QuestionDetailScreen extends StatefulWidget {

  final _PreguntaConRespuesta data;
  final GeminiService geminiService;
  final QuestionRepository questionRepo;

  const _QuestionDetailScreen({
    required this.data,
    required this.geminiService,
    required this.questionRepo,
  });

  @override
  State<_QuestionDetailScreen> createState() => _QuestionDetailScreenState();

}

class _QuestionDetailScreenState extends State<_QuestionDetailScreen> {

  bool _analyzing = false;
  String? _aiExplanation;
  String? _error;
  bool _hasLocalAnalysis = false;

  @override
  void initState() {
    super.initState();
    _aiExplanation = widget.data.question.aiExplanation;
    _hasLocalAnalysis = widget.data.question.aiExplanation != null;

    // Si no hay explicacion y no hay correctAlternativeId,
    // intentamos analisar con Gemini en el momento.
    if (_aiExplanation == null && widget.data.correctAlternative == null) {
      _analyzeOnTheFly();
    }
  }

  Future<void> _analyzeOnTheFly() async {
    setState(() => _analyzing = true);

    try {
      final letters = ['A', 'B', 'C', 'D', 'E'];
      final Map<String, String> altMap = {};
      for (var i = 0; i < widget.data.alternatives.length; i++) {
        altMap[letters[i]] = widget.data.alternatives[i].alternativeText;
      }

      final result = await widget.geminiService.analyzeQuestion(
        widget.data.question.questionText,
        altMap,
      );

      // Guardar el resultado en la pregunta para futuras consultas.
      final correctIndex = letters.indexOf(result.correctLetter);
      final correctAlternativeId = widget.data.alternatives
          .elementAt(correctIndex.clamp(0, widget.data.alternatives.length - 1))
          .alternativeId;

      await widget.questionRepo.updateQuestionAnalysis(
        widget.data.question.questionId!,
        correctAlternativeId!,
        result.explanation,
      );

      setState(() {
        _aiExplanation = result.explanation;
        _analyzing = false;
        _hasLocalAnalysis = true;
      });
    } catch (e) {
      setState(() {
        _error = 'No se pudo analizar: $e';
        _analyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final letters = ['A', 'B', 'C', 'D', 'E'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Pregunta'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Pregunta.
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  widget.data.question.questionText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Alternativas.
            const Text(
              'Alternativas:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),

            ...List.generate(widget.data.alternatives.length, (i) {
              final alt = widget.data.alternatives[i];
              final letter = letters[i];
              final isSelected =
                  alt.alternativeId == widget.data.selectedAlternative.alternativeId;
              final isCorrect =
                  alt.alternativeId == widget.data.correctAlternative?.alternativeId;

              Color? bgColor;
              Color? borderColor;
              if (isCorrect) {
                bgColor = Colors.green[50];
                borderColor = Colors.green;
              } else if (isSelected && !isCorrect) {
                bgColor = Colors.red[50];
                borderColor = Colors.red;
              }

              return Card(
                color: bgColor,
                shape: borderColor != null
                    ? Border.all(color: borderColor, width: 2)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Text(
                        '$letter)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCorrect
                              ? Colors.green
                              : (isSelected ? Colors.red : null),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(alt.alternativeText)),
                      if (isCorrect)
                        const Icon(Icons.check, color: Colors.green, size: 20),
                      if (isSelected && !isCorrect)
                        const Icon(Icons.close, color: Colors.red, size: 20),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Explicacion de IA.
            if (_analyzing) ...[
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Analizando con IA...'),
                  ],
                ),
              ),
            ] else if (_aiExplanation != null) ...[
              Card(
                color: Colors.purple[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome,
                              color: Colors.purple[700], size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Explicacion de IA',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(_aiExplanation!),
                    ],
                  ),
                ),
              ),
            ] else if (_error != null) ...[
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(_error!,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _analyzeOnTheFly,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
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
