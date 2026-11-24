import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/character.dart';
import '../../domain/repositories/character_repository.dart';
import 'character_di_providers.dart';

/// Estado de la lista de exploración de personajes
class CharacterListState {
  final List<Character> characters;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String searchQuery;
  final String statusFilter;
  final String? errorMessage;
  final bool isOffline;

  const CharacterListState({
    this.characters = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.searchQuery = '',
    this.statusFilter = 'all',
    this.errorMessage,
    this.isOffline = false,
  });

  CharacterListState copyWith({
    List<Character>? characters,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? searchQuery,
    String? statusFilter,
    String? errorMessage,
    bool? isOffline,
  }) {
    return CharacterListState(
      characters: characters ?? this.characters,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      errorMessage: errorMessage,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

/// Notifier para controlar la lista de personajes, paginación, filtros y búsqueda
class CharacterListNotifier extends Notifier<CharacterListState> {
  CharacterRepository get _repository => ref.read(characterRepositoryProvider);

  @override
  CharacterListState build() {
    Future.microtask(() => loadCharacters());
    return const CharacterListState(isLoading: true);
  }

  /// Carga inicial o recarga de personajes
  Future<void> loadCharacters({bool isRefresh = false}) async {
    final net = await ref.read(networkInfoProvider).isConnected;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentPage: 1,
      isOffline: !net,
    );

    try {
      final results = await _repository.getCharacters(
        page: 1,
        name: state.searchQuery,
        status: state.statusFilter,
      );

      state = state.copyWith(
        characters: results,
        isLoading: false,
        hasMore: net && results.length >= 20,
        errorMessage: results.isEmpty
            ? (state.searchQuery.isNotEmpty
                ? (!net
                    ? 'Modo Expedición: No hay coincidencias descargadas en caché local para "${state.searchQuery}".'
                    : 'No se encontraron personajes con el nombre "${state.searchQuery}".')
                : (!net
                    ? 'Modo Expedición: Sin conexión a internet y sin registros almacenados en caché.'
                    : 'No se encontraron registros en este momento.'))
            : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al consultar registros: $e',
      );
    }
  }

  /// Carga la siguiente página de personajes para scroll infinito
  Future<void> loadNextPage() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore || state.isOffline) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    try {
      final newCharacters = await _repository.getCharacters(
        page: nextPage,
        name: state.searchQuery,
        status: state.statusFilter,
      );

      if (newCharacters.isEmpty) {
        state = state.copyWith(isLoadingMore: false, hasMore: false);
      } else {
        state = state.copyWith(
          characters: [...state.characters, ...newCharacters],
          currentPage: nextPage,
          isLoadingMore: false,
          hasMore: newCharacters.length >= 20,
        );
      }
    } catch (_) {
      state = state.copyWith(isLoadingMore: false, hasMore: false);
    }
  }

  /// Actualiza el término de búsqueda por nombre
  void setSearchQuery(String query) {
    if (state.searchQuery == query) return;
    state = state.copyWith(searchQuery: query);
    loadCharacters();
  }

  /// Aplica filtro por estado (vivo, muerto, desconocido o todos)
  void setStatusFilter(String status) {
    if (state.statusFilter == status) return;
    state = state.copyWith(statusFilter: status);
    loadCharacters();
  }
}

/// Provider de la lista de personajes
final characterListProvider =
    NotifierProvider<CharacterListNotifier, CharacterListState>(CharacterListNotifier.new);
