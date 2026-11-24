import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/saved_characters_provider.dart';
import '../widgets/character_card.dart';
import 'character_detail_screen.dart';

/// Pantalla que muestra los personajes guardados para misiones del investigador activo
class SavedMissionsScreen extends ConsumerWidget {
  const SavedMissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedCharacters = ref.watch(savedCharactersProvider);
    final authState = ref.watch(authNotifierProvider);
    final userPhone = authState.researcher?.phone ?? 'Desconocido';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registros de Misión'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
            child: Row(
              children: [
                Icon(
                  Icons.person_pin,
                  size: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.portalGreen
                      : AppTheme.primaryDark,
                ),
                const SizedBox(width: 6),
                Text(
                  'Espacio de trabajo celular: $userPhone',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.portalGreen
                        : AppTheme.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: savedCharacters.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor(context),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.inventory_2_outlined, size: 56, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No tienes personajes guardados en tu misión',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor(context)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explora el multiverso y pulsa el marcador para conservar personajes de manera offline en este dispositivo sin mezclarse con otros investigadores.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppTheme.subtextColor(context), height: 1.4),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: savedCharacters.length,
              itemBuilder: (context, index) {
                final character = savedCharacters[index];
                return Dismissible(
                  key: Key('saved_${character.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.redAccent,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    ref.read(savedCharactersProvider.notifier).toggleSaveCharacter(character);
                    AppSnackBar.showInfo(context, '${character.name} removido de tu misión.');
                  },
                  child: CharacterCard(
                    character: character,
                    isSaved: true,
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
                  ),
                );
              },
            ),
    );
  }
}
