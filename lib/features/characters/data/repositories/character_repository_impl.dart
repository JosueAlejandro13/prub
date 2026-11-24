import '../../../../core/network/network_info.dart';
import '../../domain/entities/character.dart';
import '../../domain/repositories/character_repository.dart';
import '../datasources/character_local_data_source.dart';
import '../datasources/character_remote_data_source.dart';
import '../models/character_model.dart';

/// Implementación del repositorio de personajes coordinando red y SQLite
class CharacterRepositoryImpl implements CharacterRepository {
  final CharacterRemoteDataSource _remoteDataSource;
  final CharacterLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  CharacterRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  @override
  Future<List<Character>> getCharacters({
    int page = 1,
    String? name,
    String? status,
  }) async {
    final bool hasInternet = await _networkInfo.isConnected;

    if (hasInternet) {
      try {
        final remoteCharacters = await _remoteDataSource.fetchCharacters(
          page: page,
          name: name,
          status: status,
        );
        // Se guarda en caché local para persistencia sin conexión
        if (remoteCharacters.isNotEmpty) {
          await _localDataSource.cacheCharacters(remoteCharacters);
        }
        return remoteCharacters;
      } catch (_) {
        // En caso de falla en red, recurre a la caché local
        return await _localDataSource.getCachedCharacters(name: name, status: status);
      }
    } else {
      // Sin conexión: recupera los datos almacenados en SQLite
      return await _localDataSource.getCachedCharacters(name: name, status: status);
    }
  }

  @override
  Future<List<Character>> getSavedCharacters(String userPhone) async {
    return await _localDataSource.getSavedCharactersForUser(userPhone);
  }

  @override
  Future<void> saveCharacter(
    Character character,
    String userPhone, {
    String? notes,
  }) async {
    final model = CharacterModel(
      id: character.id,
      name: character.name,
      status: character.status,
      species: character.species,
      type: character.type,
      gender: character.gender,
      originName: character.originName,
      locationName: character.locationName,
      image: character.image,
      episodeCount: character.episodeCount,
      notes: notes,
      isSaved: true,
    );
    await _localDataSource.saveCharacterForUser(model, userPhone, notes: notes);
  }

  @override
  Future<void> removeCharacter(int characterId, String userPhone) async {
    await _localDataSource.removeCharacterForUser(characterId, userPhone);
  }

  @override
  Future<bool> isCharacterSaved(int characterId, String userPhone) async {
    return await _localDataSource.isSavedForUser(characterId, userPhone);
  }
}
