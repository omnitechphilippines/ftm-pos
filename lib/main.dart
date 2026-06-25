import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/data/services/auth_service.dart';
import 'app/modules/not_found/bindings/not_found_binding.dart';
import 'app/modules/not_found/views/not_found_view.dart';
import 'app/routes/app_pages.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await Supabase.initialize(
    url: 'https://tzocbumydgkhnznohrvn.supabase.co',
    publishableKey: 'sb_publishable_fJjqdtTLaB_vN-7qoxYwyQ_vqNCCRkg',
    postgrestOptions: const PostgrestClientOptions(schema: 'ftm_pos'),
  );
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(prefs, permanent: true);
  Get.put(AuthService());
  runApp(
    GetMaterialApp(
      title: 'Point of Sale',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      unknownRoute: GetPage<Object>(name: Routes.NOT_FOUND, page: () => const NotFoundView(), binding: NotFoundBinding()),
      defaultTransition: Transition.noTransition,
      transitionDuration: Duration.zero,
    ),
  );
}
