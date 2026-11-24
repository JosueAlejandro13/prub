import 'package:flutter_test/flutter_test.dart';
import 'package:multiverse_explorers/core/storage/secure_storage_service.dart';
import 'package:multiverse_explorers/features/auth/data/auth_repository_impl.dart';

class FakeSecureStorageService extends SecureStorageService {
  final Map<String, String> _storage = {};

  @override
  Future<void> saveToken(String token) async {
    _storage['auth_token'] = token;
  }

  @override
  Future<String?> getToken() async => _storage['auth_token'];

  @override
  Future<void> saveCurrentUserPhone(String phone) async {
    _storage['current_user_phone'] = phone;
  }

  @override
  Future<String?> getCurrentUserPhone() async => _storage['current_user_phone'];

  @override
  Future<void> clearSession() async {
    _storage.clear();
  }
}

void main() {
  group('AuthRepositoryImpl', () {
    late FakeSecureStorageService fakeStorage;
    late AuthRepositoryImpl authRepository;

    setUp(() {
      fakeStorage = FakeSecureStorageService();
      authRepository = AuthRepositoryImpl(fakeStorage);
    });

    test('loginWithPhone genera token sha256 y persiste sesión con remember=true', () async {
      final researcher = await authRepository.loginWithPhone('5512345678', '1234', remember: true);

      expect(researcher.phone, '5512345678');
      expect(researcher.token, isNotEmpty);
      expect(await fakeStorage.getToken(), researcher.token);
      expect(await fakeStorage.getCurrentUserPhone(), '5512345678');
    });

    test('loginWithPhone no persiste datos en storage con remember=false', () async {
      final researcher = await authRepository.loginWithPhone('5512345678', '1234', remember: false);

      expect(researcher.phone, '5512345678');
      expect(await fakeStorage.getToken(), isNull);
      expect(await fakeStorage.getCurrentUserPhone(), isNull);
    });

    test('getCurrentResearcher recupera la sesión almacenada', () async {
      await authRepository.loginWithPhone('5598765432', '1234', remember: true);

      final current = await authRepository.getCurrentResearcher();

      expect(current, isNotNull);
      expect(current!.phone, '5598765432');
    });

    test('logout limpia la sesión activa', () async {
      await authRepository.loginWithPhone('5598765432', '1234', remember: true);
      await authRepository.logout();

      final current = await authRepository.getCurrentResearcher();
      expect(current, isNull);
      expect(await fakeStorage.getToken(), isNull);
    });
  });
}
