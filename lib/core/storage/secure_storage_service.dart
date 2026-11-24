import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manejo de almacenamiento seguro para sesión y tokens
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _keyAuthToken = 'auth_token';
  static const String _keyCurrentPhone = 'current_user_phone';

  /// Guarda el token de sesión
  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyAuthToken, value: token);
  }

  /// Obtiene el token de sesión
  Future<String?> getToken() async {
    return await _storage.read(key: _keyAuthToken);
  }

  /// Guarda el celular del investigador en sesión activa
  Future<void> saveCurrentUserPhone(String phone) async {
    await _storage.write(key: _keyCurrentPhone, value: phone);
  }

  /// Obtiene el celular del investigador activo
  Future<String?> getCurrentUserPhone() async {
    return await _storage.read(key: _keyCurrentPhone);
  }

  /// Guarda un valor personalizado
  Future<void> writeCustom(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Lee un valor personalizado
  Future<String?> readCustom(String key) async {
    return await _storage.read(key: key);
  }

  /// Elimina la sesión actual (cierre de sesión)
  Future<void> clearSession() async {
    await _storage.delete(key: _keyAuthToken);
    await _storage.delete(key: _keyCurrentPhone);
  }
}
