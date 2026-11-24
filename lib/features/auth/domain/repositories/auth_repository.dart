import '../models/researcher.dart';

/// Contrato para el repositorio de autenticación de investigadores
abstract class AuthRepository {
  /// Inicia sesión con número celular, código y preferencia de persistencia de token
  Future<Researcher> loginWithPhone(
    String phone,
    String verificationCode, {
    bool remember = true,
  });

  /// Obtiene el investigador actualmente autenticado si existe sesión
  Future<Researcher?> getCurrentResearcher();

  /// Cierra la sesión activa
  Future<void> logout();
}
