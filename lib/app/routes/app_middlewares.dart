import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/services/auth_service.dart';
import 'app_pages.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) => Get.find<AuthService>().isLoggedIn ? null : const RouteSettings(name: Routes.LOGIN);
}

class GuestMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) => Get.find<AuthService>().isLoggedIn ? const RouteSettings(name: Routes.DASHBOARD) : null;
}
