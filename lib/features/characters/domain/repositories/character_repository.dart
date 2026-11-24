import '../entities/character.dart';

/// Contrato para el repositorio de personajes
abstract class CharacterRepository {
  /// Obtiene lista de personajes por página y filtros (nombre y estado)
  Future<List<Character>> getCharacters({
    int page = 1,
    String? name,
    String? status,
  });

  /// Obtiene los personajes guardados en misión por el investigador
  Future<List<Character>> getSavedCharacters(String userPhone);

  /// Guarda un personaje en el registro de misión del investigador
  Future<void> saveCharacter(Character character, String userPhone, {String? notes});

  /// Remueve un personaje del registro de misión del investigador
  Future<void> removeCharacter(int characterId, String userPhone);

  /// Comprueba si un personaje está guardado por el investigador
  Future<bool> isCharacterSaved(int characterId, String userPhone);
}
