import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/characters/presentation/providers/character_di_providers.dart';

/// Notifier para gestionar la preferencia de tema (claro u oscuro)
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const String _themeKey = 'app_theme_mode';

  @override
  ThemeMode build() {
    Future.microtask(() => _loadSavedTheme());
    return ThemeMode.light;
  }

  /// Carga la preferencia de tema guardada en SQLite y almacenamiento seguro
  Future<void> _loadSavedTheme() async {
    try {
      final dbHelper = ref.read(databaseHelperProvider);
      final savedFromDb = await dbHelper.getSetting(_themeKey);
      if (savedFromDb == 'dark') {
        state = ThemeMode.dark;
        return;
      } else if (savedFromDb == 'light') {
        state = ThemeMode.light;
        return;
      }

      final storage = ref.read(secureStorageProvider);
      final saved = await storage.readCustom(_themeKey);
      if (saved == 'dark') {
        state = ThemeMode.dark;
      } else {
        state = ThemeMode.light;
      }
    } catch (_) {
      state = ThemeMode.light;
    }
  }

  /// Alterna entre modo oscuro y claro y guarda la preferencia en SQLite y Secure Storage
  Future<void> toggleTheme(bool isDark) async {
    final modeStr = isDark ? 'dark' : 'light';
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    try {
      final dbHelper = ref.read(databaseHelperProvider);
      await dbHelper.saveSetting(_themeKey, modeStr);
      final storage = ref.read(secureStorageProvider);
      await storage.writeCustom(_themeKey, modeStr);
    } catch (_) {}
  }
}

/// Provider del modo de tema de la aplicación
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
