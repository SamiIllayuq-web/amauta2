/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : gemini_service.dart
///
/// DESCRIPCION:
/// Servicio para comunicarse con la API de Gemini Vision.
//// Transforma imagenes de examen en preguntas estructuradas
/// usando el modelo gemini-3.5-flash.
///
/// METODOS:
/// - imageToBase64: convierte una imagen local a base64
/// - analyzeImage: envia imagen a Gemini Vision y devuelve JSON
/// - analyzeQuestion: determina correcta + explicacion de una pregunta
/// ===============================================================

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Resultado del analisis de una pregunta por IA.
class GeminiAnalysisResult {
  final String correctLetter;
  final String explanation;

  GeminiAnalysisResult({required this.correctLetter, required this.explanation});
}

class GeminiService {

  /// Token API de Gemini. Carga desde .env via flutter_dotenv.
  static String get _apiToken {
    final key = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (key.isEmpty) {
      throw Exception(
          'GEMINI_API_KEY no encontrada en .env. Agrega tu key en el archivo .env');
    }
    return key;
  }

  /// Modelo validado que funciona con este token.
  static const String _model = 'gemini-3.5-flash';

  /// Endpoint base de la API Gemini.
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  /// Prompt del sistema para OCR de examenes.
  static const String _ocrPrompt = '''
Eres un sistema de OCR inteligente. De la imagen de examen proporcionada,
extrae TODAS las preguntas con sus alternativas en formato JSON estructurado.

Responde SOLO con JSON valido, sin markdown, sin explication:

{
  "exam_title": "titulo del examen si se ve, si no null",
  "university": "nombre de universidad si se ve, si no null",
  "year": "ano del examen si se ve, si no null",
  "questions": [
    {
      "number": 1,
      "text": "texto completo de la pregunta",
      "alternatives": [
        {"letter": "A", "text": "texto alternativa A"},
        {"letter": "B", "text": "texto alternativa B"},
        {"letter": "C", "text": "texto alternativa C"},
        {"letter": "D", "text": "texto alternativa D"}
      ]
    }
  ]
}
''';

  /// Convierte una imagen local a string base64.
  Future<String> imageToBase64(String path) async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  /// Determina el mimeType de una imagen segun su extension.
  String _mimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/png';
    }
  }

  /// Envia una imagen a Gemini Vision y devuelve el texto
  /// con las preguntas extraidas.
  Future<String> analyzeImage(String imagePath) async {
    final base64Image = await imageToBase64(imagePath);
    final mimeType = _mimeType(imagePath);

    final body = {
      'contents': [
        {
          'parts': [
            {'text': _ocrPrompt},
            {
              'inlineData': {
                'mimeType': mimeType,
                'data': base64Image,
              }
            }
          ]
        }
      ]
    };

    final uri = Uri.parse('$_baseUrl?key=$_apiToken');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gemini API error: ${response.statusCode} - ${response.body}',
      );
    }

    final data = jsonDecode(response.body);

    final candidates = data['candidates'];
    if (candidates == null || candidates.isEmpty) {
      throw Exception('Gemini no devolvio candidatos');
    }

    final text = candidates[0]['content']['parts'][0]['text'];
    return text as String;
  }

  /// Parsea el JSON devuelto por Gemini.
  Map<String, dynamic> parseExamJson(String jsonText) {
    var cleaned = jsonText.trim();

    if (cleaned.contains('```')) {
      final start = cleaned.indexOf('{');
      final end = cleaned.lastIndexOf('}');
      if (start != -1 && end != -1) {
        cleaned = cleaned.substring(start, end + 1);
      }
    }

    cleaned = cleaned.trim();

    return jsonDecode(cleaned) as Map<String, dynamic>;
  }

  /// Prompt para analisis de preguntas.
  static const String _analysisPrompt = '''
Eres un profesor experto. Se te presenta una pregunta de examen
con 4 alternativas (A, B, C, D). Tu tarea:

1. Determina cual alternativa es la CORRECTA.
2. Da una breve explicacion (2-3 oraciones) de por que esa respuesta
   es correcta y por que las demas son incorrectas.

Responde SOLO con JSON valido, sin markdown:

{
  "correctLetter": "A",
  "explanation": "La respuesta correcta es A porque..."
}
''';

  /// Envia una pregunta con sus alternativas a Gemini para analisis.
  /// Retorna [GeminiAnalysisResult] con la letra correcta y explicacion.
  Future<GeminiAnalysisResult> analyzeQuestion(
      String questionText, Map<String, String> alternatives) async {
    final alternativesText = alternatives.entries
        .map((e) => '${e.key}) ${e.value}')
        .join('\n');

    final body = {
      'contents': [
        {
          'parts': [
            {'text': '$_analysisPrompt\n\nPregunta: $questionText\nAlternativas:\n$alternativesText'},
          ]
        }
      ]
    };

    final uri = Uri.parse('$_baseUrl?key=$_apiToken');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gemini API error: ${response.statusCode} - ${response.body}',
      );
    }

    final data = jsonDecode(response.body);

    final candidates = data['candidates'];
    if (candidates == null || candidates.isEmpty) {
      throw Exception('Gemini no devolvio candidatos');
    }

    final text = candidates[0]['content']['parts'][0]['text'] as String;
    return _parseAnalysisResult(text);
  }

  /// Parsea la respuesta JSON del analisis.
  GeminiAnalysisResult _parseAnalysisResult(String jsonText) {
    var cleaned = jsonText.trim();

    if (cleaned.contains('```')) {
      final start = cleaned.indexOf('{');
      final end = cleaned.lastIndexOf('}');
      if (start != -1 && end != -1) {
        cleaned = cleaned.substring(start, end + 1);
      }
    }

    cleaned = cleaned.trim();

    final map = jsonDecode(cleaned) as Map<String, dynamic>;
    return GeminiAnalysisResult(
      correctLetter: (map['correctLetter'] as String).toUpperCase(),
      explanation: map['explanation'] as String,
    );
  }
}
