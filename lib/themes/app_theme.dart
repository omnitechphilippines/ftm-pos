import 'package:flutter/material.dart';

class AppColors {
  // --- Dark Theme Palette (Your Dashboard Colors) ---
  static const Color darkBg = Color(0xFF1F212C); // Main app background
  static const Color darkSurface = Color(0xFF2A2D3E); // Cards, Dialogs, Drawer
  static const Color darkActive = Color(0xFF4D4F5B); // Hover, Active list items
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFF8B8D96);

  // --- Light Theme Palette (Complementary Cool Tech Gray) ---
  static const Color lightBg = Color(0xFFF4F5F7); // Main app background
  static const Color lightSurface = Colors.white; // Cards, Dialogs, Drawer
  static const Color lightActive = Color(0xFFE2E4E9); // Hover, Active list items
  static const Color lightTextPrimary = Color(0xFF1F212C);
  static const Color lightTextSecondary = Color(0xFF686A75);

  // --- Global Component Accents ---
  static const Color success = Color(0xFF4CAF50); // Revenue green
  static const Color info = Color(0xFF2196F3); // Invoice blue
  static const Color warning = Color(0xFFFF9800); // Low stock orange
  static const Color error = Color(0xFFF44336); // Expired red
}

// --- LIGHT THEME DEFINITION ---
ThemeData get lightTheme => ThemeData(
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
ThemeData get darkTheme => ThemeData(
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
