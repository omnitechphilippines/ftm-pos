import 'package:get/get.dart';

import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/not_found/bindings/not_found_binding.dart';
import '../modules/not_found/views/not_found_view.dart';
import '../modules/orders/bindings/orders_binding.dart';
import '../modules/orders/views/orders_view.dart';
import '../modules/products/bindings/products_binding.dart';
import '../modules/products/views/products_view.dart';
import '../modules/reports/bindings/reports_binding.dart';
import '../modules/reports/views/reports_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const String INITIAL = Routes.LOGIN;

  static final List<GetPage<dynamic>> routes = <GetPage<dynamic>>[
    GetPage<dynamic>(name: _Paths.LOGIN, page: () => const LoginView(), binding: LoginBinding()),
    GetPage<dynamic>(name: _Paths.NOT_FOUND, page: () => const NotFoundView(), binding: NotFoundBinding()),
    GetPage<dynamic>(name: _Paths.DASHBOARD, page: () => const DashboardView(), binding: DashboardBinding()),
    GetPage<dynamic>(name: _Paths.ORDERS, page: () => const OrdersView(), binding: OrdersBinding()),
    GetPage<dynamic>(name: _Paths.PRODUCTS, page: () => const ProductsView(), binding: ProductsBinding()),
    GetPage<dynamic>(name: _Paths.REPORTS, page: () => const ReportsView(), binding: ReportsBinding()),
  ];
}
