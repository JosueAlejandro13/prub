import 'package:connectivity_plus/connectivity_plus.dart';

/// Servicio para verificar el estado de conexión a internet
class NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo(this._connectivity);

  /// Retorna true si hay conexión a internet activa
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  /// Flujo continuo de cambios en la conectividad
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((results) {
      return !results.contains(ConnectivityResult.none);
    });
  }
}
