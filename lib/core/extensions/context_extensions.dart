import 'package:flutter/material.dart';

extension ResponsiveContext on BuildContext {
  // Get width and height directly from context
  double get screenWidth => MediaQuery.widthOf(this);
  double get screenHeight => MediaQuery.heightOf(this);

  // Responsive Breakpoints
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;
  bool get isDesktop => screenWidth >= 1200;

  // Environment states
  bool get isDarkMode => (Theme.of(this).brightness == Brightness.dark);
  bool get isLandscape => screenWidth > screenHeight;
}
