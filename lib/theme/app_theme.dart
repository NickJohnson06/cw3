// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

/// Shared seed color
const Color _seed = Colors.amber;

// DARK THEME
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorSchemeSeed: _seed,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0F1115),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0F1115),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF1A1F27),
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  ),
  listTileTheme: const ListTileThemeData(
    iconColor: Colors.white70,
    textColor: Colors.white,
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Color(0xFF1A1F27),
    contentTextStyle: TextStyle(color: Colors.white),
    behavior: SnackBarBehavior.floating,
  ),
);

// LIGHT THEME
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorSchemeSeed: _seed,
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFFDFDFD),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 0,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFFF1F3F5),
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  ),
  listTileTheme: const ListTileThemeData(
    iconColor: Colors.black54,
    textColor: Colors.black87,
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Colors.black87,
    contentTextStyle: TextStyle(color: Colors.white),
    behavior: SnackBarBehavior.floating,
  ),
);

// Cycle helper
ThemeMode cycleTheme(ThemeMode current) {
  switch (current) {
    case ThemeMode.system:
      return ThemeMode.light;
    case ThemeMode.light:
      return ThemeMode.dark;
    case ThemeMode.dark:
      return ThemeMode.system;
  }
}

IconData themeIconFor(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.system:
      return Icons.auto_mode;
    case ThemeMode.light:
      return Icons.wb_sunny_outlined;
    case ThemeMode.dark:
      return Icons.dark_mode_outlined;
  }
}
