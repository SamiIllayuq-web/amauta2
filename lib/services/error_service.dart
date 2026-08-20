/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : error_service.dart
///
/// DESCRIPCIÓN:
/// Servicio centralizado de diagnóstico de errores.
/// Detecta y clasifica errores HTTP, de red y del sistema.
///
/// USO:
///   try {
///     await algo();
///   } on Exception catch (e) {
///     final diagnosed = ErrorService.diagnose(e);
///     print(diagnosed.message); // mensaje legible
///     print(diagnosed.code);    // código corto
///     print(diagnosed.severity); // error / warning / info
///   }
/// ===============================================================

/// Causa raíz del error.
enum ErrorCause {
  /// Sin conexión a internet.
  noInternet,

  /// Red demasiado lenta o timeout.
  timeout,

  /// API key inválida o expirada.
  authError,

  /// Solicitud mal formada (bad request).
  badRequest,

  /// Recurso no encontrado (404).
  notFound,

  /// Rate limit excedido (429).
  rateLimited,

  /// Error interno del servidor (500).
  serverError,

  /// Error interno de la app (null safety, parse, etc).
  internalError,

  /// Error desconocido.
  unknown,
}

/// Nivel de severidad del error.
enum ErrorSeverity {
  /// El sistema puede continuar, warn del usuario.
  info,

  /// Algo falló pero el usuario puede reintentar.
  warning,

  /// Fallo crítico, acción requerida.
  error,
}

/// Resultado del diagnóstico de un error.
class DiagnosedError {
  /// Código corto del error, útil para logging.
  final String code;

  /// Mensaje detallado para mostrar al usuario.
  final String message;

  /// Causa raíz identificada.
  final ErrorCause cause;

  /// Severidad del error.
  final ErrorSeverity severity;

  /// Sugerencia de acción para el usuario.
  final String suggestion;

  const DiagnosedError({
    required this.code,
    required this.message,
    required this.cause,
    required this.severity,
    required this.suggestion,
  });

  @override
  String toString() => '[$code] $message';
}

class ErrorService {
  ErrorService._();

  // ==========================================================
  // DIAGNÓSTICO PRINCIPAL
  // ==========================================================

  /// Recibe cualquier Exception y devuelve un DiagnosedError
  /// con mensaje legible, código y sugerencia.
  static DiagnosedError diagnose(Exception error) {
    final msg = error.toString().toLowerCase();
    final originalMsg = error.toString();

    // --- ERRORES HTTP ---

    if (msg.contains('statuscode') || msg.contains('http') || msg.contains('status')) {
      return _diagnoseHttpError(originalMsg, msg);
    }

    // --- TIMEOUT / RED ---

    if (msg.contains('timeout') ||
        msg.contains('connection refused') ||
        msg.contains('socketexception') ||
        msg.contains('handshake') ||
        msg.contains('connection reset') ||
        msg.contains('network is unreachable') ||
        msg.contains('no internet') ||
        msg.contains('network_error') ||
        msg.contains('connectivity')) {
      return DiagnosedError(
        code: 'NET_001',
        message: 'No se pudo conectar al servidor.',
        cause: ErrorCause.noInternet,
        severity: ErrorSeverity.error,
        suggestion:
            'Verifica tu conexión a internet (WiFi o datos móviles). '
                'Si estás en una red restringida, prueba con tus datos personales.',
      );
    }

    // --- AUTENTICACIÓN / API KEY ---

    if (msg.contains('api key') ||
        msg.contains('unauthorized') ||
        msg.contains('401') ||
        msg.contains('403') ||
        msg.contains('invalid') ||
        msg.contains('apikey')) {
      return DiagnosedError(
        code: 'AUTH_001',
        message: 'Error de autenticación con el servicio de IA.',
        cause: ErrorCause.authError,
        severity: ErrorSeverity.error,
        suggestion:
            'La clave API puede haber expirado o ser inválida. '
                'Contacta al administrador del sistema.',
      );
    }

    // --- RATE LIMIT ---

    if (msg.contains('429') ||
        msg.contains('rate limit') ||
        msg.contains('too many') ||
        msg.contains('quota')) {
      return DiagnosedError(
        code: 'RATE_001',
        message: 'Demasiadas solicitudes. Se alcanzó el límite de uso.',
        cause: ErrorCause.rateLimited,
        severity: ErrorSeverity.warning,
        suggestion:
            'Espera unos segundos e intenta de nuevo. '
                'El servicio de IA tiene un límite de solicitudes por minuto.',
      );
    }

    // --- 404 ---

    if (msg.contains('404') || msg.contains('not found')) {
      return DiagnosedError(
        code: 'HTTP_404',
        message: 'Recurso no encontrado.',
        cause: ErrorCause.notFound,
        severity: ErrorSeverity.error,
        suggestion: 'El servicio de IA no está respondiendo correctamente.',
      );
    }

    // --- 500 ---

    if (msg.contains('500') || msg.contains('internal server') || msg.contains('server error')) {
      return DiagnosedError(
        code: 'HTTP_500',
        message: 'El servidor de IA tuvo un error interno.',
        cause: ErrorCause.serverError,
        severity: ErrorSeverity.error,
        suggestion:
            'El servicio de Gemini está teniendo problemas. '
                'Espera un momento e intenta de nuevo.',
      );
    }

    // --- ERRORES INTERNOS DE FLUTTER / DART ---

    if (msg.contains('null') ||
        msg.contains('no such method') ||
        msg.contains('format') ||
        msg.contains('parse') ||
        msg.contains('invalid argument') ||
        msg.contains('rangeerror') ||
        msg.contains('typeerror')) {
      return DiagnosedError(
        code: 'INT_001',
        message: 'Error interno de la aplicación.',
        cause: ErrorCause.internalError,
        severity: ErrorSeverity.error,
        suggestion:
            'Ocurrió un error inesperado. Cierra y vuelve a abrir la aplicación. '
                'Si persiste, contacta al administrador.',
      );
    }

    // --- DESCONOCIDO ---

    return DiagnosedError(
      code: 'UNK_001',
      message: 'Error desconocido: ${_truncate(originalMsg, 100)}',
      cause: ErrorCause.unknown,
      severity: ErrorSeverity.error,
      suggestion: 'Si el problema persiste, contacta al administrador.',
    );
  }

  /// Diagnostica errores HTTP específicos (400, 401, 403, 404, 429, 500, etc).
  static DiagnosedError _diagnoseHttpError(String original, String lower) {
    if (lower.contains('400') || lower.contains('bad request')) {
      return DiagnosedError(
        code: 'HTTP_400',
        message: 'Solicitud inválida al servicio de IA.',
        cause: ErrorCause.badRequest,
        severity: ErrorSeverity.error,
        suggestion:
            'Los datos enviados son incompatibles con el servicio. '
                'Contacta al administrador.',
      );
    }

    if (lower.contains('401') || lower.contains('unauthorized') || lower.contains('api key')) {
      return DiagnosedError(
        code: 'AUTH_001',
        message: 'Clave API inválida o expirada.',
        cause: ErrorCause.authError,
        severity: ErrorSeverity.error,
        suggestion: 'Contacta al administrador para actualizar la clave API.',
      );
    }

    if (lower.contains('403') || lower.contains('forbidden')) {
      return DiagnosedError(
        code: 'HTTP_403',
        message: 'Acceso denegado al servicio de IA.',
        cause: ErrorCause.authError,
        severity: ErrorSeverity.error,
        suggestion:
            'La cuenta de API no tiene permisos suficientes. '
                'Contacta al administrador.',
      );
    }

    if (lower.contains('404') || lower.contains('not found')) {
      return DiagnosedError(
        code: 'HTTP_404',
        message: 'Modelo de IA no encontrado.',
        cause: ErrorCause.notFound,
        severity: ErrorSeverity.error,
        suggestion: 'El modelo de Gemini no está disponible. Contacta al administrador.',
      );
    }

    if (lower.contains('429') || lower.contains('rate limit') || lower.contains('quota')) {
      return DiagnosedError(
        code: 'RATE_001',
        message: 'Límite de solicitudes excedido.',
        cause: ErrorCause.rateLimited,
        severity: ErrorSeverity.warning,
        suggestion:
            'Espera 30-60 segundos e intenta de nuevo. '
                'El servicio gratuito de Gemini tiene límites de uso.',
      );
    }

    if (lower.contains('500') || lower.contains('internal server error')) {
      return DiagnosedError(
        code: 'HTTP_500',
        message: 'Error interno del servidor de Gemini.',
        cause: ErrorCause.serverError,
        severity: ErrorSeverity.error,
        suggestion:
            'El servidor de Google tuvo un error. '
                'Espera unos minutos e intenta de nuevo.',
      );
    }

    if (lower.contains('503') || lower.contains('service unavailable')) {
      return DiagnosedError(
        code: 'HTTP_503',
        message: 'Servicio de IA temporalmente no disponible.',
        cause: ErrorCause.serverError,
        severity: ErrorSeverity.warning,
        suggestion: 'El servicio está en mantenimiento. Espera e intenta más tarde.',
      );
    }

    // Error HTTP genérico con código
    final statusMatch = RegExp(r'status[cC]ode[:\s=]+(\d{3})').firstMatch(original);
    if (statusMatch != null) {
      final code = statusMatch.group(1)!;
      return DiagnosedError(
        code: 'HTTP_$code',
        message: 'Error HTTP $code.',
        cause: ErrorCause.serverError,
        severity: ErrorSeverity.error,
        suggestion: 'Contacta al administrador si el problema persiste.',
      );
    }

    return DiagnosedError(
      code: 'HTTP_GEN',
      message: 'Error de comunicación con el servicio de IA.',
      cause: ErrorCause.serverError,
      severity: ErrorSeverity.error,
      suggestion: 'Verifica tu conexión a internet e intenta de nuevo.',
    );
  }

  // ==========================================================
  // HELPERS
  // ==========================================================

  static String _truncate(String s, int maxLen) {
    if (s.length <= maxLen) return s;
    return '${s.substring(0, maxLen)}...';
  }

  // ==========================================================
  // LOGGING
  // ==========================================================

  /// Registra un error diagnóstico en la consola.
  /// Útil para debugging.
  static void log(DiagnosedError error, {String? context}) {
    final prefix = context != null ? '[$context] ' : '';
    print('${prefix}ERROR ${error.code}: ${error.message}');
    print('  → Cause: ${error.cause}');
    print('  → Suggestion: ${error.suggestion}');
  }
}
