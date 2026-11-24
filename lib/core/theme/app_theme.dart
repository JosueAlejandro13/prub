import 'package:flutter/material.dart';

/// Configuración de colores y temas claro y oscuro de la aplicación
class AppTheme {
  static const Color primaryGreen = Color(0xFF0FA958);
  static const Color primaryDark = Color(0xFF0B7A3E);
  static const Color portalGreen = Color(0xFF00FF9D);

  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color cardLight = Colors.white;
  static const Color surfaceLight = Color(0xFFF1F5F9);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);

  static const Color spaceDark = Color(0xFF0B0E14);
  static const Color cardDark = Color(0xFF161B22);
  static const Color surfaceDark = Color(0xFF1F242C);
  static const Color borderDark = Color(0xFF2B323E);
  static const Color accentCyan = Color(0xFF0284C7);

  /// Retorna el color principal de texto según el tema activo
  static Color textColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? Colors.white : textPrimary;
  }

  /// Retorna el color secundario de texto según el tema activo
  static Color subtextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? Colors.white70 : textSecondary;
  }

  /// Retorna el color de superficie según el tema activo
  static Color surfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? surfaceDark : surfaceLight;
  }

  /// Retorna el color de tarjeta según el tema activo
  static Color cardBgColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? cardDark : cardLight;
  }

  /// Retorna el color de bordes según el tema activo
  static Color borderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? borderDark : borderLight;
  }

  /// Tema claro con fondo blanco (predeterminado)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      primaryColor: primaryGreen,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: accentCyan,
        surface: cardLight,
        error: Colors.redAccent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0.5,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 3,
        indicatorColor: primaryGreen.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: primaryDark,
            );
          }
          return const TextStyle(fontSize: 12, color: textMuted);
        }),
      ),
    );
  }

  /// Tema oscuro con acentos neón y fondo espacial
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: spaceDark,
      primaryColor: portalGreen,
      colorScheme: const ColorScheme.dark(
        primary: portalGreen,
        secondary: Color(0xFF00E5FF),
        surface: cardDark,
        error: Colors.redAccent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: spaceDark,
        foregroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: borderDark, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: spaceDark,
        elevation: 3,
        indicatorColor: portalGreen.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: portalGreen,
            );
          }
          return const TextStyle(fontSize: 12, color: Colors.white60);
        }),
      ),
    );
  }
}
