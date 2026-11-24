import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../domain/models/researcher.dart';
import '../domain/repositories/auth_repository.dart';

/// Implementación del repositorio de autenticación con almacenamiento seguro
class AuthRepositoryImpl implements AuthRepository {
  final SecureStorageService _secureStorage;

  AuthRepositoryImpl(this._secureStorage);

  @override
  Future<Researcher> loginWithPhone(
    String phone,
    String verificationCode, {
    bool remember = true,
  }) async {
    // Generación de un token criptográfico para la sesión
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final payload = '$phone:$timestamp:MADD_MULTIVERSE';
    final token = sha256.convert(utf8.encode(payload)).toString();

    if (remember) {
      await _secureStorage.saveToken(token);
      await _secureStorage.saveCurrentUserPhone(phone);
    } else {
      await _secureStorage.clearSession();
    }

    return Researcher(
      phone: phone,
      token: token,
      sessionStartedAt: DateTime.now(),
    );
  }

  @override
  Future<Researcher?> getCurrentResearcher() async {
    final token = await _secureStorage.getToken();
    final phone = await _secureStorage.getCurrentUserPhone();

    if (token != null && phone != null) {
      return Researcher(
        phone: phone,
        token: token,
        sessionStartedAt: DateTime.now(),
      );
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await _secureStorage.clearSession();
  }
}
