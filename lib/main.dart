import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/modules/not_found/bindings/not_found_binding.dart';
import 'app/modules/not_found/views/not_found_view.dart';
import 'app/routes/app_pages.dart';
import 'services/auth_service.dart';
import 'services/responsive_service.dart';
import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await Supabase.initialize(
    url: 'https://tzocbumydgkhnznohrvn.supabase.co',
    publishableKey: 'sb_publishable_fJjqdtTLaB_vN-7qoxYwyQ_vqNCCRkg',
    postgrestOptions: const PostgrestClientOptions(schema: 'ftm_pos'),
  );
  Get.put(AuthService());
  Get.put(ResponsiveService());
  runApp(
    GetMaterialApp(
      title: 'Point of Sale',
      theme: lightTheme,
      darkTheme: darkTheme,
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
