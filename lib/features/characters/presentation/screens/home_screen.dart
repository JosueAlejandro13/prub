import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/screens/profile_screen.dart';
import '../providers/character_di_providers.dart';
import '../providers/character_list_provider.dart';
import '../providers/saved_characters_provider.dart';
import '../widgets/character_card.dart';
import '../widgets/network_status_banner.dart';
import '../widgets/search_filter_bar.dart';
import 'character_detail_screen.dart';
import 'notifications_screen.dart';
import 'saved_missions_screen.dart';

/// Pantalla principal con exploración del multiverso, misiones locales y perfil
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(characterListProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final characterState = ref.watch(characterListProvider);
    final savedCharacters = ref.watch(savedCharactersProvider);
    final isConnectedAsync = ref.watch(connectivityStreamProvider);
    final isOffline = isConnectedAsync.value == false || characterState.isOffline;

    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.hub_rounded, color: AppTheme.primaryGreen, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'MULTIVERSE',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textColor(context),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Badge(
                    label: const Text('3'),
                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.portalGreen
                        : AppTheme.primaryGreen,
                    textColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                    child: Icon(
                      Icons.notifications_outlined,
                      color: AppTheme.textColor(context),
                    ),
                  ),
                  tooltip: 'Notificaciones',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 6),
              ],
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          Column(
            children: [
              NetworkStatusBanner(isOffline: isOffline),
              SearchFilterBar(
                initialQuery: characterState.searchQuery,
                initialStatus: characterState.statusFilter,
                onSearchChanged: (query) {
                  ref.read(characterListProvider.notifier).setSearchQuery(query);
                },
                onStatusChanged: (status) {
                  ref.read(characterListProvider.notifier).setStatusFilter(status);
                },
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppTheme.primaryGreen,
                  onRefresh: () async {
                    await ref.read(characterListProvider.notifier).loadCharacters(isRefresh: true);
                    await ref.read(savedCharactersProvider.notifier).loadSavedCharacters();
                  },
                  child: _buildCharactersList(characterState, savedCharacters),
                ),
              ),
            ],
          ),
          const SavedMissionsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 4,
        indicatorColor: AppTheme.primaryGreen.withValues(alpha: 0.18),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.explore_outlined, color: AppTheme.textMuted),
            selectedIcon: Icon(Icons.explore, color: AppTheme.primaryDark),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('${savedCharacters.length}'),
              isLabelVisible: savedCharacters.isNotEmpty,
              backgroundColor: AppTheme.primaryGreen,
              textColor: Colors.white,
              child: const Icon(Icons.bookmark_border_rounded, color: AppTheme.textMuted),
            ),
            selectedIcon: Badge(
              label: Text('${savedCharacters.length}'),
              isLabelVisible: savedCharacters.isNotEmpty,
              backgroundColor: AppTheme.primaryGreen,
              textColor: Colors.white,
              child: const Icon(Icons.bookmark_rounded, color: AppTheme.primaryDark),
            ),
            label: 'Mis Misiones',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded, color: AppTheme.textMuted),
            selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primaryDark),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildCharactersList(
    CharacterListState state,
    List<dynamic> savedCharacters,
  ) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGreen),
      );
    }

    if (state.errorMessage != null && state.characters.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off_rounded, size: 64, color: AppTheme.textMuted),
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppTheme.subtextColor(context), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(characterListProvider.notifier).loadCharacters();
                },
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Reintentar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.characters.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.characters.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen),
            ),
          );
        }

        final character = state.characters[index];
        final isSaved = ref.read(savedCharactersProvider.notifier).isSaved(character.id);

        return CharacterCard(
          character: character,
          isSaved: isSaved,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CharacterDetailScreen(character: character),
              ),
            );
          },
          onToggleSave: () {
            ref.read(savedCharactersProvider.notifier).toggleSaveCharacter(character);
          },
        );
      },
    );
  }
}
