/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : connectivity_service.dart
///
/// DESCRIPCIÓN:
/// Detecta el estado de conectividad del dispositivo.
/// Notifica cuando hay cambio de online ↔ offline.
///
/// USO:
///   final connectivity = ConnectivityService();
///   connectivity.startMonitoring((isOnline) {
///     // actualizar UI
///   });
/// ===============================================================

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = true;

  /// Estado actual de conexión.
  bool get isOnline => _isOnline;

  /// Inicia el monitoreo de conectividad.
  /// [onChange] se llama cada vez que el estado cambia.
  void startMonitoring(void Function(bool isOnline) onChange) {
    // Verificar estado inicial
    _checkConnection(onChange);

    // Suscribirse a cambios futuros
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _handleResults(results, onChange);
    });
  }

  /// Detiene el monitoreo.
  void stopMonitoring() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _checkConnection(void Function(bool) onChange) async {
    final results = await _connectivity.checkConnectivity();
    _handleResults(results, onChange);
  }

  void _handleResults(List<ConnectivityResult> results, void Function(bool) onChange) {
    final wasOnline = _isOnline;

    // Online si hay al menos una conexión válida
    _isOnline = results.isNotEmpty &&
        !results.contains(ConnectivityResult.none);

    if (wasOnline != _isOnline) {
      onChange(_isOnline);
    }
  }

  /// Devuelve un texto descriptivo del tipo de conexión.
  static String connectionType(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      return 'Sin conexión';
    }
    if (results.contains(ConnectivityResult.wifi)) return 'WiFi';
    if (results.contains(ConnectivityResult.mobile)) return 'Datos móviles';
    if (results.contains(ConnectivityResult.ethernet)) return 'Ethernet';
    if (results.contains(ConnectivityResult.vpn)) return 'VPN';
    return 'Conectado';
  }
}
