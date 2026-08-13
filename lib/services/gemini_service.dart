/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : gemini_service.dart
///
/// DESCRIPCION:
/// Servicio para comunicarse con la API de Gemini Vision.
/// Transforma imagenes de examen en preguntas estructuradas
/// usando el modelo gemini-3.5-flash.
///
/// METODO:
/// - imageToBase64: convierte una imagen local a base64
/// - extractExamFromImage: envia la imagen a Gemini Vision
///   y devuelve las preguntas en JSON estructurado
/// ===============================================================

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class GeminiService {

  /// Token API de Gemini. Obtener de google-ai-studio.
  /// Mantener en secreto - NO hacer commit con el token real.
  /// Reemplazar por variable de entorno en produccion.
  static const String _apiToken = 'YOUR_GEMINI_API_KEY';

  /// Modelo validado que funciona con este token.
  static const String _model = 'gemini-3.5-flash';

  /// Endpoint base de la API Gemini.
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  /// Prompt del sistema para OCR de examenes.
  /// Pide a Gemini que extraiga preguntas y alternativas
  /// en formato JSON estricto.
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
  ///
  /// [path] ruta absoluta o relativa al archivo de imagen.
  /// Retorna el string base64 de la imagen.
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
  ///
  /// [imagePath] ruta al archivo de imagen.
  /// Retorna el texto de la respuesta de Gemini.
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

  /// Parsea el JSON devuelto por Gemini y lo transforma en
  /// una estructura de Dart util.
  ///
  /// [jsonText] texto JSON plano devuelto por Gemini.
  /// Retorna un mapa con exam_title, university, year y questions.
  Map<String, dynamic> parseExamJson(String jsonText) {
    // Gemini a veces devuelve el JSON dentro de un bloque markdown.
    // Limpiamos esos casos.
    var cleaned = jsonText.trim();

    // Eliminar bloques markdown ```json ... ```
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
}
