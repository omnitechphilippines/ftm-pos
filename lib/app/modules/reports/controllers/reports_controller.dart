import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/order_model.dart';

class ReportsController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  RxBool isLoading = false.obs;
  RxString selectedTimeframe = 'Daily'.obs; // Daily, Weekly, Monthly
  RxList<dynamic> reportSummaryLines = <dynamic>[].obs;

  // Drill-down tracking variables
  RxString selectedPeriod = ''.obs;
  RxList<OrderModel> detailedOrdersForPeriod = <OrderModel>[].obs;
  Rxn<OrderModel> selectedDetailedOrder = Rxn<OrderModel>();

  @override
  void onInit() {
    fetchReportSummary();
    super.onInit();
  }

  void changeTimeframe(String timeframe) {
    selectedTimeframe.value = timeframe;
    selectedPeriod.value = '';
    detailedOrdersForPeriod.clear();
    selectedDetailedOrder.value = null;
    fetchReportSummary();
  }

  Future<void> fetchReportSummary() async {
    try {
      isLoading.value = true;
      String rpcFunction = 'get_daily_reports';
      if (selectedTimeframe.value == 'Weekly') {
        rpcFunction = 'get_weekly_reports';
      }
      if (selectedTimeframe.value == 'Monthly') {
        rpcFunction = 'get_monthly_reports';
      }

      final List<dynamic> response = await _supabase.rpc(rpcFunction);
      reportSummaryLines.value = response;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load report summary: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch individual raw orders when clicking a summary row (Drill Down Level 1)
  Future<void> drillDownIntoPeriod(String periodText) async {
    try {
      isLoading.value = true;
      selectedPeriod.value = periodText;
      selectedDetailedOrder.value = null; // Clear individual receipt view

      PostgrestFilterBuilder<List<Map<String, dynamic>>> query = _supabase.from('orders').select();

      if (selectedTimeframe.value == 'Daily') {
        query = query.gte('order_at', '$periodText 00:00:00').lte('order_at', '$periodText 23:59:59');
      } else if (selectedTimeframe.value == 'Monthly') {
        // Example periodText: "2026-06"
        final List<String> parts = periodText.split('-');
        final int year = int.parse(parts[0]);
        final int month = int.parse(parts[1]);

        // Calculate the exact first day of the next month
        final DateTime startOfMonth = DateTime(year, month, 1);
        final DateTime startOfNextMonth = DateTime(year, month + 1, 1); // Dart automatically handles rolling December (12+1) to January of next year!

        // Filter: From first day of this month up until (but not including) first day of next month
        query = query.gte('order_at', startOfMonth.toIso8601String()).lt('order_at', startOfNextMonth.toIso8601String()); // Use .lt (less than) instead of .lte
      } // Note: Weekly range text requires standard date bounds parse depending on system rules

      final List<dynamic> response = await query.order('order_at', ascending: false);

      detailedOrdersForPeriod.value = response.map((dynamic item) => OrderModel.fromJson(item)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to retrieve period orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Select a specific receipt to view item tables (Drill Down Level 2)
  void selectSpecificOrder(OrderModel order) {
    selectedDetailedOrder.value = order;
  }
}
