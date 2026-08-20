/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : admin_question_analysis_screen.dart
///
/// DESCRIPCIÓN:
/// Pantalla del administrador para analizar preguntas guardadas
/// usando Gemini AI. Determina la alternativa correcta y guarda
/// la explicación oficial.
///
/// FLUJO
///
/// AdminDashboardScreen
///        |
///        v
/// /admin/analyze
///        |
///        v
/// 1. Lista preguntas sin analizar (correctAlternativeId == null)
///        |
///        v
/// 2. Admin selecciona una pregunta
///        |
///        v
/// 3. Muestra alternativas de esa pregunta
///        |
///        v
/// 4. Boton "Analizar con IA" → Gemini determina correcta + explicacion
///        |
///        v
/// 5. Admin confirma o edita manualmente
///        |
///        v
/// 6. Guardar → update question con correctAlternativeId + aiExplanation
///        |
///        v
/// 7. Volver a lista (pregunta desaparece de pendientes)
///
/// ===============================================================

library;

import 'package:flutter/material.dart';

import '../models/alternative_model.dart';
import '../models/question_model.dart';
import '../repositories/alternative_repository.dart';
import '../repositories/question_repository.dart';
import '../services/gemini_service.dart';

class AdminQuestionAnalysisScreen extends StatefulWidget {

  /// Si se proporciona, filtra por este examen.
  final int? mockExamId;

  const AdminQuestionAnalysisScreen({super.key, this.mockExamId});

  @override
  State<AdminQuestionAnalysisScreen> createState() =>
      _AdminQuestionAnalysisScreenState();

}

class _AdminQuestionAnalysisScreenState
    extends State<AdminQuestionAnalysisScreen> {

  final QuestionRepository _questionRepo = QuestionRepository();
  final AlternativeRepository _alternativeRepo = AlternativeRepository();
  final GeminiService _geminiService = GeminiService();

  /// Lista de preguntas sin analizar.
  List<Question> _pendingQuestions = [];

  /// Lista de preguntas ya analizadas.
  List<Question> _analyzedQuestions = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _loading = true);

    final all = await _questionRepo.getAllQuestions();

    // Filtrar por examen si se pasó como argumento.
    final filtered = widget.mockExamId != null
        ? all.where((q) => q.mockExamId == widget.mockExamId).toList()
        : all;

    final pending = filtered.where((q) => q.correctAlternativeId == null).toList();
    final analyzed =
        filtered.where((q) => q.correctAlternativeId != null).toList();

    setState(() {
      _pendingQuestions = pending;
      _analyzedQuestions = analyzed;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analizar Preguntas con IA'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_pendingQuestions.isEmpty && _analyzedQuestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No hay preguntas en la base de datos',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Primero ingesta examenes desde imagenes',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            tabs: [
              Tab(text: 'Sin analizar (${_pendingQuestions.length})'),
              Tab(text: 'Ya analizadas (${_analyzedQuestions.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildPendingList(),
                _buildAnalyzedList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Lista de preguntas pendientes de analisis.
  Widget _buildPendingList() {
    if (_pendingQuestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green[300]),
            const SizedBox(height: 16),
            const Text(
              'Todas las preguntas fueron analizadas',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _pendingQuestions.length,
      itemBuilder: (context, index) {
        final question = _pendingQuestions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange[100],
              child: Text(
                '${index + 1}',
                style: TextStyle(color: Colors.orange[800]),
              ),
            ),
            title: Text(
              question.questionText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              question.aiExplanation ?? 'Sin explicacion aun',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openAnalysis(question),
          ),
        );
      },
    );
  }

  /// Lista de preguntas ya analizadas (para re-analizar si es necesario).
  Widget _buildAnalyzedList() {
    if (_analyzedQuestions.isEmpty) {
      return const Center(
        child: Text('Sin preguntas analizadas aun'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _analyzedQuestions.length,
      itemBuilder: (context, index) {
        final question = _analyzedQuestions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green[100],
              child: Icon(Icons.check, color: Colors.green[800]),
            ),
            title: Text(
              question.questionText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              question.aiExplanation ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Re-analizar con IA',
              onPressed: () => _openAnalysis(question, isReanalysis: true),
            ),
            onTap: () => _openAnalysis(question, isReanalysis: true),
          ),
        );
      },
    );
  }

  /// Abre la pantalla de analisis para una pregunta.
  Future<void> _openAnalysis(Question question,
      {bool isReanalysis = false}) async {
    final alternatives =
        await _alternativeRepo.getAlternativesByQuestion(question.questionId!);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _QuestionAnalysisDetailScreen(
          question: question,
          alternatives: alternatives,
          geminiService: _geminiService,
          questionRepository: _questionRepo,
          onSaved: () {
            _loadQuestions();
          },
          isReanalysis: isReanalysis,
        ),
      ),
    );
  }
}

/// ===============================================================
/// Pantalla detalle para analizar una pregunta con IA.
// ===============================================================

class _QuestionAnalysisDetailScreen extends StatefulWidget {

  final Question question;
  final List<Alternative> alternatives;
  final GeminiService geminiService;
  final QuestionRepository questionRepository;
  final VoidCallback onSaved;
  final bool isReanalysis;

  const _QuestionAnalysisDetailScreen({
    required this.question,
    required this.alternatives,
    required this.geminiService,
    required this.questionRepository,
    required this.onSaved,
    this.isReanalysis = false,
  });

  @override
  State<_QuestionAnalysisDetailScreen> createState() =>
      _QuestionAnalysisDetailScreenState();

}

class _QuestionAnalysisDetailScreenState
    extends State<_QuestionAnalysisDetailScreen> {

  bool _analyzing = false;
  bool _saving = false;

  /// Respuesta correcta seleccionada por el admin (letra A/B/C/D).
  String? _selectedCorrectLetter;

  /// Explicacion ingresada/editada por el admin.
  final TextEditingController _explanationController =
      TextEditingController();

  /// Error de Gemini.
  String? _error;

  @override
  void initState() {
    super.initState();
    // Si la pregunta ya fue analizada, pre-llenar datos.
    if (widget.question.correctAlternativeId != null) {
      final correctAlt = widget.alternatives.firstWhere(
        (a) => a.alternativeId == widget.question.correctAlternativeId,
        orElse: () => widget.alternatives.first,
      );
      // Las alternativas no tienen letra (A/B/C/D) guardada, solo texto.
      // Tomamos la primera letra disponible.
      _selectedCorrectLetter = 'A';
      _explanationController.text = widget.question.aiExplanation ?? '';
    }
  }

  @override
  void dispose() {
    _explanationController.dispose();
    super.dispose();
  }

  ///Llama a Gemini para analizar la pregunta.
  Future<void> _analyzeWithGemini() async {
    if (_selectedCorrectLetter == null) {
      setState(() => _error = 'Selecciona la respuesta correcta primero');
      return;
    }

    setState(() {
      _analyzing = true;
      _error = null;
    });

    try {
      // Construir mapa de alternativas para Gemini.
      final letters = ['A', 'B', 'C', 'D'];
      final Map<String, String> altMap = {};
      for (var i = 0; i < widget.alternatives.length; i++) {
        altMap[letters[i]] = widget.alternatives[i].alternativeText;
      }

      final result = await widget.geminiService.analyzeQuestion(
        widget.question.questionText,
        altMap,
      );

      // Mapear letra de Gemini (A/B/C/D) a alternativeId real.
      final correctIndex = letters.indexOf(result.correctLetter);
      final correctAlternativeId =
          widget.alternatives[correctIndex.clamp(0, widget.alternatives.length - 1)]
              .alternativeId!;

      setState(() {
        _selectedCorrectLetter = result.correctLetter;
        _explanationController.text = result.explanation;
        _analyzing = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error Gemini: $e';
        _analyzing = false;
      });
    }
  }

  /// Guarda el analisis en la base de datos.
  Future<void> _saveAnalysis() async {
    if (_selectedCorrectLetter == null) {
      setState(() => _error = 'Selecciona la respuesta correcta');
      return;
    }

    if (_explanationController.text.trim().isEmpty) {
      setState(() => _error = 'Ingresa una explicacion');
      return;
    }

    setState(() => _saving = true);

    try {
      final letters = ['A', 'B', 'C', 'D'];
      final correctIndex = letters.indexOf(_selectedCorrectLetter!);
      final correctAlternativeId =
          widget.alternatives[correctIndex.clamp(0, widget.alternatives.length - 1)]
              .alternativeId!;

      await widget.questionRepository.updateQuestionAnalysis(
        widget.question.questionId!,
        correctAlternativeId,
        _explanationController.text.trim(),
      );

      widget.onSaved();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Analisis guardado correctamente')),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Error al guardar: $e';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final letters = ['A', 'B', 'C', 'D'];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isReanalysis ? 'Re-analizar Pregunta' : 'Analizar Pregunta'),
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
                  widget.question.questionText,
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

            ...List.generate(widget.alternatives.length, (i) {
              final alt = widget.alternatives[i];
              final letter = i < letters.length ? letters[i] : '?';
              final isSelected = _selectedCorrectLetter == letter;

              return Card(
                color: isSelected ? Colors.green[50] : null,
                child: RadioListTile<String>(
                  title: Text('$letter) ${alt.alternativeText}'),
                  value: letter,
                  groupValue: _selectedCorrectLetter,
                  activeColor: Colors.green,
                  onChanged: (value) {
                    setState(() => _selectedCorrectLetter = value);
                  },
                ),
              );
            }),

            const SizedBox(height: 16),

            // Boton analizar con IA.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _analyzing ? null : _analyzeWithGemini,
                icon: _analyzing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_analyzing ? 'Analizando...' : 'Analizar con IA'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Explicacion.
            const Text(
              'Explicacion (editada por admin):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _explanationController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Escribe o edita la explicacion aqui...',
                border: OutlineInputBorder(),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],

            const SizedBox(height: 16),

            // Boton guardar.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveAnalysis,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(_saving ? 'Guardando...' : 'GUARDAR ANALISIS'),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
