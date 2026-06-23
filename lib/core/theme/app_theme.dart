import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // --- LIGHT THEME DEFINITION ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.lightTextPrimary,
    scaffoldBackgroundColor: AppColors.lightBg,
    canvasColor: AppColors.lightSurface, // Targets Drawers natively

    colorScheme: const ColorScheme.light(primary: AppColors.lightTextPrimary, secondary: AppColors.lightActive, surface: AppColors.lightSurface, error: AppColors.error, onPrimary: Colors.white, onSecondary: AppColors.lightTextPrimary, onSurface: AppColors.lightTextPrimary, onError: Colors.white),

    cardTheme: const CardThemeData(color: AppColors.lightSurface, elevation: 1),

    dialogTheme: const DialogThemeData(backgroundColor: AppColors.lightSurface, surfaceTintColor: Colors.transparent),

    dividerTheme: const DividerThemeData(color: AppColors.lightActive),

    listTileTheme: const ListTileThemeData(selectedTileColor: Color(0xFFEAEBED)),
  );

  // --- DARK THEME DEFINITION ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.darkTextPrimary,
    scaffoldBackgroundColor: AppColors.darkBg,
    canvasColor: AppColors.darkSurface, // Targets Drawers natively

    colorScheme: const ColorScheme.dark(primary: AppColors.darkTextPrimary, secondary: AppColors.darkActive, surface: AppColors.darkSurface, error: AppColors.error, onPrimary: AppColors.darkBg, onSecondary: AppColors.darkTextPrimary, onSurface: AppColors.darkTextPrimary, onError: Colors.white),

    cardTheme: const CardThemeData(color: AppColors.darkSurface, elevation: 2),

    dialogTheme: const DialogThemeData(backgroundColor: AppColors.darkSurface, surfaceTintColor: Colors.transparent),

    dividerTheme: const DividerThemeData(color: Colors.grey),

    listTileTheme: const ListTileThemeData(selectedTileColor: Color(0xFF4D4F5B)),
  );
}
