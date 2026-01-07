import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app_pages.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) => GetStorage('auth').read('status') == 'success' ? null : const RouteSettings(name: Routes.LOGIN);
}

class GuestMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) => GetStorage('auth').read('status') == 'success' ? const RouteSettings(name: Routes.DASHBOARD) : null;
}
