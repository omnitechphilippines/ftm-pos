import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResponsiveService extends GetxService {
  double screenWidth(BuildContext context) => MediaQuery.widthOf(context);
  double screenHeight(BuildContext context) => MediaQuery.heightOf(context);

  bool isMobile(BuildContext context) => screenWidth(context) < 600;
  bool isTablet(BuildContext context) {
    final double width = screenWidth(context);
    return width >= 600 && width < 1200;
  }

  bool isDesktop(BuildContext context) => screenWidth(context) >= 1200;

  bool isDarkMode(BuildContext context) => MediaQuery.platformBrightnessOf(context) == Brightness.dark;
  bool isLandscape(BuildContext context) => screenWidth(context) > screenHeight(context);
}
