import 'package:flutter/material.dart';

ThemeData get lightTheme => ThemeData(
  primaryColor: const Color(0xFF000000),
  colorScheme: const ColorScheme.light(primary: Color(0xFF000000), secondary: Color(0xFFFFFFFF), surface: Color(0xFFF5F5F5), error: Color(0xFFB00020), onPrimary: Color(0xFFFFFFFF), onSecondary: Color(0xFF000000), onSurface: Color(0xFF000000), onError: Color(0xFFFFFFFF)),
  scaffoldBackgroundColor: const Color(0xFFFFFFFF),
);

ThemeData get darkTheme => ThemeData(
  primaryColor: const Color(0xFFFFFFFF),
  colorScheme: const ColorScheme.dark(primary: Color(0xFFFFFFFF), secondary: Color(0xFF000000), surface: Color(0xFF121212), error: Color(0xFFCF6679), onPrimary: Color(0xFF000000), onSecondary: Color(0xFFFFFFFF), onSurface: Color(0xFFFFFFFF), onError: Color(0xFF000000)),
  scaffoldBackgroundColor: const Color(0xFF212332),
  canvasColor: const Color(0xFF2A2D3E),
);
