import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/modules/not_found/bindings/not_found_binding.dart';
import 'app/modules/not_found/views/not_found_view.dart';
import 'app/routes/app_pages.dart';
import 'services/auth_service.dart';
import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await Supabase.initialize(
    url: 'https://tzocbumydgkhnznohrvn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR6b2NidW15ZGdraG56bm9ocnZuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEwMDkwMTcsImV4cCI6MjA3NjU4NTAxN30.QJqOclKu6fO5TcKHGkTsDcDnl2bFoi0PF-uTDlcknGs',
    postgrestOptions: const PostgrestClientOptions(schema: 'ftm_pos'),
  );
  Get.put(AuthService());
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
