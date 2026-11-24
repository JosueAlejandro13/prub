import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/auth_repository_impl.dart';
import '../../domain/models/researcher.dart';
import '../../domain/repositories/auth_repository.dart';

/// Provider del servicio de almacenamiento seguro
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// Provider del repositorio de autenticación
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthRepositoryImpl(secureStorage);
});

/// Estado de la autenticación del investigador
class AuthState {
  final Researcher? researcher;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.researcher,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => researcher != null;

  AuthState copyWith({
    Researcher? researcher,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      researcher: researcher ?? this.researcher,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Gestor de estado de la sesión activa
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Verificación inicial de sesión asíncrona
    Future.microtask(() => checkCurrentSession());
    return const AuthState(isLoading: true);
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  /// Verifica si ya existe una sesión guardada en el dispositivo
  Future<void> checkCurrentSession() async {
    state = state.copyWith(isLoading: true);
    try {
      final researcher = await _repository.getCurrentResearcher();
      state = AuthState(researcher: researcher, isLoading: false);
    } catch (e) {
      state = AuthState(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Inicia sesión con número celular y persistencia de token
  Future<bool> login(String phone, String code, {bool remember = true}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final researcher = await _repository.loginWithPhone(phone, code, remember: remember);
      state = AuthState(researcher: researcher, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al iniciar sesión: $e',
      );
      return false;
    }
  }

  /// Cierra la sesión activa permitiendo cambio de investigador
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _repository.logout();
    state = const AuthState(researcher: null, isLoading: false);
  }
}

/// Provider global de autenticación
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
