import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/character.dart';
import '../../domain/repositories/character_repository.dart';
import 'character_di_providers.dart';

/// Notifier para gestionar los personajes guardados en la misión del investigador activo
class SavedCharactersNotifier extends Notifier<List<Character>> {
  CharacterRepository get _repository => ref.read(characterRepositoryProvider);

  String get _userPhone {
    final authState = ref.read(authNotifierProvider);
    return authState.researcher?.phone ?? '';
  }

  @override
  List<Character> build() {
    final authState = ref.watch(authNotifierProvider);
    final phone = authState.researcher?.phone ?? '';
    if (phone.isNotEmpty) {
      Future.microtask(() => loadSavedCharacters());
    }
    return [];
  }

  /// Carga los personajes guardados para este número celular desde SQLite
  Future<void> loadSavedCharacters() async {
    final phone = _userPhone;
    if (phone.isEmpty) {
      state = [];
      return;
    }
    final saved = await _repository.getSavedCharacters(phone);
    state = saved;
  }

  /// Guarda o actualiza un personaje con sus notas sin deseleccionarlo
  Future<void> saveOrUpdateCharacter(Character character, {String? notes}) async {
    final phone = _userPhone;
    if (phone.isEmpty) return;

    await _repository.saveCharacter(character, phone, notes: notes);
    final updatedCharacter = character.copyWith(isSaved: true, notes: notes);
    state = [
      updatedCharacter,
      ...state.where((c) => c.id != character.id),
    ];
  }

  /// Alterna el guardado de un personaje para este investigador
  Future<void> toggleSaveCharacter(Character character, {String? notes}) async {
    final phone = _userPhone;
    if (phone.isEmpty) return;

    final isSaved = state.any((c) => c.id == character.id);
    if (isSaved) {
      await _repository.removeCharacter(character.id, phone);
      state = state.where((c) => c.id != character.id).toList();
    } else {
      await _repository.saveCharacter(character, phone, notes: notes);
      final updatedCharacter = character.copyWith(isSaved: true, notes: notes);
      state = [updatedCharacter, ...state];
    }
  }

  /// Verifica si un personaje específico está guardado por este investigador
  bool isSaved(int characterId) {
    return state.any((c) => c.id == characterId);
  }
}

/// Provider de los personajes guardados, dependiente del usuario en sesión
final savedCharactersProvider =
    NotifierProvider<SavedCharactersNotifier, List<Character>>(SavedCharactersNotifier.new);
