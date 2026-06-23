import 'dart:ui';

class AppColors {
  AppColors._();

  // --- Dark Theme Palette (Your Dashboard Colors) ---
  static const Color darkBg = Color(0xFF1F212C); // Main app background
  static const Color darkSurface = Color(0xFF2A2D3E); // Cards, Dialogs, Drawer
  static const Color darkActive = Color(0xFF4D4F5B); // Hover, Active list items
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF8B8D96);

  // --- Light Theme Palette (Complementary Cool Tech Gray) ---
  static const Color lightBg = Color(0xFFF4F5F7); // Main app background
  static const Color lightSurface = Color(0xFFFFFFFF); // Cards, Dialogs, Drawer
  static const Color lightActive = Color(0xFFE2E4E9); // Hover, Active list items
  static const Color lightTextPrimary = Color(0xFF1F212C);
  static const Color lightTextSecondary = Color(0xFF686A75);

  // --- Global Component Accents ---
  static const Color success = Color(0xFF4CAF50); // Revenue green
  static const Color info = Color(0xFF2196F3); // Invoice blue
  static const Color warning = Color(0xFFFF9800); // Low stock orange
  static const Color error = Color(0xFFF44336); // Expired red
}
