import 'package:flutter_test/flutter_test.dart';
import 'package:multiverse_explorers/core/network/api_client.dart';
import 'package:multiverse_explorers/core/network/network_info.dart';
import 'package:multiverse_explorers/core/storage/database_helper.dart';
import 'package:multiverse_explorers/features/characters/data/datasources/character_local_data_source.dart';
import 'package:multiverse_explorers/features/characters/data/datasources/character_remote_data_source.dart';
import 'package:multiverse_explorers/features/characters/data/models/character_model.dart';
import 'package:multiverse_explorers/features/characters/data/repositories/character_repository_impl.dart';

class FakeNetworkInfo implements NetworkInfo {
  bool isOnline = true;

  @override
  Future<bool> get isConnected async => isOnline;

  @override
  Stream<bool> get onConnectivityChanged => Stream.value(isOnline);
}

class FakeRemoteDataSource extends CharacterRemoteDataSource {
  FakeRemoteDataSource() : super(ApiClient());

  bool shouldThrow = false;
  List<CharacterModel> mockCharacters = [];

  @override
  Future<List<CharacterModel>> fetchCharacters({int page = 1, String? name, String? status}) async {
    if (shouldThrow) throw Exception('API Connection Failure');
    return mockCharacters;
  }
}

class FakeLocalDataSource extends CharacterLocalDataSource {
  FakeLocalDataSource() : super(DatabaseHelper());

  final List<CharacterModel> cached = [];
  final Map<String, List<CharacterModel>> savedByUser = {};

  @override
  Future<void> cacheCharacters(List<CharacterModel> characters) async {
    cached.clear();
    cached.addAll(characters);
  }

  @override
  Future<List<CharacterModel>> getCachedCharacters({String? name, String? status}) async {
    return cached;
  }

  @override
  Future<void> saveCharacterForUser(CharacterModel character, String userPhone, {String? notes}) async {
    savedByUser.putIfAbsent(userPhone, () => []);
    savedByUser[userPhone]!.removeWhere((c) => c.id == character.id);
    savedByUser[userPhone]!.add(character);
  }

  @override
  Future<List<CharacterModel>> getSavedCharactersForUser(String userPhone) async {
    return savedByUser[userPhone] ?? [];
  }

  @override
  Future<void> removeCharacterForUser(int characterId, String userPhone) async {
    savedByUser[userPhone]?.removeWhere((c) => c.id == characterId);
  }

  @override
  Future<bool> isSavedForUser(int characterId, String userPhone) async {
    return savedByUser[userPhone]?.any((c) => c.id == characterId) ?? false;
  }
}

void main() {
  group('CharacterRepositoryImpl', () {
    late FakeNetworkInfo fakeNetwork;
    late FakeRemoteDataSource fakeRemote;
    late FakeLocalDataSource fakeLocal;
    late CharacterRepositoryImpl repository;

    final sampleChar = const CharacterModel(
      id: 1,
      name: 'Rick Sanchez',
      status: 'Alive',
      species: 'Human',
      type: '',
      gender: 'Male',
      originName: 'Earth',
      locationName: 'Earth',
      image: 'https://example.com/rick.png',
      episodeCount: 51,
    );

    setUp(() {
      fakeNetwork = FakeNetworkInfo();
      fakeRemote = FakeRemoteDataSource();
      fakeLocal = FakeLocalDataSource();
      repository = CharacterRepositoryImpl(fakeRemote, fakeLocal, fakeNetwork);
    });

    test('getCharacters consume remoto y actualiza caché local cuando está online', () async {
      fakeNetwork.isOnline = true;
      fakeRemote.mockCharacters = [sampleChar];

      final results = await repository.getCharacters(page: 1);

      expect(results.length, 1);
      expect(results.first.name, 'Rick Sanchez');
      expect(fakeLocal.cached.length, 1);
    });

    test('getCharacters recurre a caché local cuando está offline', () async {
      fakeNetwork.isOnline = false;
      fakeLocal.cached.add(sampleChar);

      final results = await repository.getCharacters(page: 1);

      expect(results.length, 1);
      expect(results.first.name, 'Rick Sanchez');
    });

    test('getCharacters recurre a caché local si la llamada remota falla', () async {
      fakeNetwork.isOnline = true;
      fakeRemote.shouldThrow = true;
      fakeLocal.cached.add(sampleChar);

      final results = await repository.getCharacters(page: 1);

      expect(results.length, 1);
      expect(results.first.name, 'Rick Sanchez');
    });

    test('saveCharacter y getSavedCharacters persisten y recuperan datos', () async {
      await repository.saveCharacter(sampleChar, '5512345678', notes: 'Prioritario');

      final saved = await repository.getSavedCharacters('5512345678');
      expect(saved.length, 1);
      expect(await repository.isCharacterSaved(1, '5512345678'), true);

      await repository.removeCharacter(1, '5512345678');
      expect(await repository.isCharacterSaved(1, '5512345678'), false);
    });
  });
}
