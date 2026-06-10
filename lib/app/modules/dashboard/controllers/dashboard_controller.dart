import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/order_model.dart';

class DashboardController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final RxBool isLoading = false.obs;

  // KPI Metrics
  final RxDouble totalRevenue = 0.0.obs;
  final RxInt totalOrders = 0.obs;
  final RxInt lowStockCount = 0.obs;

  // Lists
  final RxList<dynamic> topProductsList = <dynamic>[].obs;
  final RxList<OrderModel> recentOrdersList = <OrderModel>[].obs;

  final RxInt expiryAlertCount = 0.obs;
  final RxList<dynamic> expiryItemsList = <dynamic>[].obs;

  @override
  void onInit() {
    refreshDashboard();
    super.onInit();
  }

  Future<void> refreshDashboard() async {
    try {
      isLoading.value = true;

      // 1. Fetch Aggregated Metrics
      final dynamic analyticsPayload = await _supabase.rpc('get_homepage_dashboard_stats');
      if (analyticsPayload != null) {
        totalRevenue.value = (analyticsPayload['total_revenue'] ?? 0.0).toDouble();
        totalOrders.value = analyticsPayload['total_orders'] ?? 0;
        lowStockCount.value = analyticsPayload['low_stock_count'] ?? 0;
        topProductsList.value = analyticsPayload['top_products'] ?? <dynamic>[];
      }

      // 2. Fetch Recent Transactions
      final List<dynamic> recentOrdersResponse = await _supabase.from('orders').select().order('order_at', ascending: false).limit(10);

      recentOrdersList.value = recentOrdersResponse.map((dynamic item) => OrderModel.fromJson(item as Map<String, dynamic>)).toList();

      // Update the portion inside your refreshDashboard() function to read the new JSON keys:
      if (analyticsPayload != null) {
        totalRevenue.value = (analyticsPayload['total_revenue'] ?? 0.0).toDouble();
        totalOrders.value = analyticsPayload['total_orders'] ?? 0;
        lowStockCount.value = analyticsPayload['low_stock_count'] ?? 0;

        // Parse new fields
        expiryAlertCount.value = analyticsPayload['expiry_alert_count'] ?? 0;
        expiryItemsList.value = analyticsPayload['expiry_items'] ?? [];

        topProductsList.value = analyticsPayload['top_products'] ?? [];
      }
    } catch (e) {
      Get.snackbar('Error', 'Dashboard failed to sync: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch the complete product leaderboard list for the pop-up detail view
  Future<List<dynamic>> fetchFullProductLeaderboard() async {
    try {
      // Reuses your database view logic to extract all aggregated units sold
      final dynamic analyticsPayload = await _supabase.rpc('get_homepage_dashboard_stats');
      return analyticsPayload != null ? analyticsPayload['top_products'] ?? <dynamic>[] : <dynamic>[];
    } catch (e) {
      Get.snackbar('Error', 'Failed to pull complete product leaderboard: $e', backgroundColor: Colors.red, colorText: Colors.white);
      return <dynamic>[];
    }
  }
}
