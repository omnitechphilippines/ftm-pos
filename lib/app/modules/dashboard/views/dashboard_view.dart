import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../models/order_model.dart';
import '../../../../services/responsive_service.dart';
import '../../../../themes/app_theme.dart';
import '../../../../widgets/app_bars/custom_app_bar.dart';
import '../../../../widgets/cards/clickable_metric_card.dart';
import '../../../../widgets/drawers/side_drawer.dart';
import '../../../../widgets/loading_indicators/loading_indicator.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentRoute = Get.currentRoute.isNotEmpty ? Get.currentRoute : (Get.routing.current.isNotEmpty ? Get.routing.current : ModalRoute.of(context)?.settings.name ?? '');
    final ResponsiveService responsive = Get.find<ResponsiveService>();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Dashboard'),
      drawer: SideDrawer(currentRoute: currentRoute),
      body: Obx(
        () => controller.isLoading.value && controller.recentOrdersList.isEmpty
            ? const LoadingIndicator(label: 'Loading dashboard...')
            : RefreshIndicator(
                onRefresh: () => controller.refreshDashboard(),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(responsive.isMobile(context) ? 12 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // SECTION 1: Clickable KPI Summary Metric Cards Grid
                      responsive.isMobile(context) ? const VerticalMetricsCards() : const HorizontalMetricsCards(),
                      SizedBox(height: responsive.isMobile(context) ? 16 : 24),

                      // SECTION 2: Data Insights Splitting Layout
                      if (responsive.isMobile(context)) ...<Widget>[const TopProductsCard(), const SizedBox(height: 16), const RecentOrdersCard()] else ...<Widget>[
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(flex: 4, child: TopProductsCard()),
                            SizedBox(width: 24),
                            Expanded(flex: 6, child: RecentOrdersCard()),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class VerticalMetricsCards extends StatelessWidget {
  const VerticalMetricsCards({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();
    return Column(
      children: <Widget>[
        ClickableMetricCard(title: 'Gross Revenue', value: '₱${controller.totalRevenue.value.toStringAsFixed(2)}', icon: Icons.payments, color: AppColors.success, onTap: () => Get.dialog(const RevenueDetailsDialog())),
        const SizedBox(height: 12),
        ClickableMetricCard(title: 'Total Invoices', value: '${controller.totalOrders.value}', icon: Icons.receipt, color: AppColors.info, onTap: () => Get.dialog(const InvoicesSummaryDialog())),
        const SizedBox(height: 12),
        ClickableMetricCard(title: 'Low Stock Alerts', value: '${controller.lowStockCount.value}', icon: Icons.inventory_2, color: AppColors.warning, onTap: () => Get.dialog(const LowStockDetailsDialog())),
        const SizedBox(height: 12),
        ClickableMetricCard(
          title: 'Expiry Alerts',
          value: '${controller.expiryAlertCount.value}',
          icon: Icons.running_with_errors,
          color: controller.expiryItemsList.any((dynamic item) => item['is_expired'] == true) ? AppColors.error : AppColors.warning,
          onTap: () => Get.dialog(const ExpiryDetailsDialog()),
        ),
      ],
    );
  }
}

class HorizontalMetricsCards extends StatelessWidget {
  const HorizontalMetricsCards({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();
    return Row(
      children: <Widget>[
        Expanded(
          child: ClickableMetricCard(title: 'Gross Revenue', value: '₱${controller.totalRevenue.value.toStringAsFixed(2)}', icon: Icons.payments, color: AppColors.success, onTap: () => Get.dialog(const RevenueDetailsDialog())),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ClickableMetricCard(title: 'Total Invoices', value: '${controller.totalOrders.value}', icon: Icons.receipt, color: AppColors.info, onTap: () => Get.dialog(const InvoicesSummaryDialog())),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ClickableMetricCard(title: 'Low Stock Alerts', value: '${controller.lowStockCount.value}', icon: Icons.inventory_2, color: AppColors.warning, onTap: () => Get.dialog(const LowStockDetailsDialog())),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ClickableMetricCard(
            title: 'Expiry Alerts',
            value: '${controller.expiryAlertCount.value}',
            icon: Icons.running_with_errors,
            color: controller.expiryItemsList.any((dynamic item) => item['is_expired'] == true) ? AppColors.error : AppColors.warning,
            onTap: () => Get.dialog(const ExpiryDetailsDialog()),
          ),
        ),
      ],
    );
  }
}

class TopProductsCard extends StatelessWidget {
  const TopProductsCard({super.key});
  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Get.dialog(const FullLeaderboardDialog()),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Top Moving Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Icon(Icons.open_in_new, color: Colors.grey, size: 18),
                ],
              ),
              const Divider(color: Colors.grey),
              if (controller.topProductsList.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No sales records available.', style: TextStyle(color: Colors.grey)),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.topProductsList.length > 5 ? 5 : controller.topProductsList.length,
                  itemBuilder: (_, int index) {
                    final dynamic item = controller.topProductsList[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF1F212C),
                        child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(
                        item['p_name'] ?? 'Unknown Item',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text('${item['total_qty_sold']} units sold', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      trailing: Text(
                        '₱${(item['total_revenue_generated'] as num).toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecentOrdersCard extends StatelessWidget {
  const RecentOrdersCard({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Get.dialog(const AllRecentInvoicesDialog()),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Recent Invoices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Icon(Icons.open_in_new, color: Colors.grey, size: 18),
                ],
              ),
              const Divider(color: Colors.grey),
              if (controller.recentOrdersList.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No orders processed yet.', style: TextStyle(color: Colors.grey)),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.recentOrdersList.length > 5 ? 5 : controller.recentOrdersList.length,
                  itemBuilder: (_, int index) {
                    final OrderModel order = controller.recentOrdersList[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Invoice #${order.id.substring(0, 8).toUpperCase()}'),
                      subtitle: Text(
                        '${order.name.length} items • ${order.orderAt.toString().substring(11, 16)}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text('₱${order.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      onTap: () => Get.dialog(SingleReceiptDetailDialog(order: order)),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class RevenueDetailsDialog extends StatelessWidget {
  const RevenueDetailsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();
    return AlertDialog(
      title: const Text('Gross Financial Revenue', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Total Net Lifetime Sales Accumulation Summary:', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Text(
            '₱${controller.totalRevenue.value.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.green, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('CLOSE', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
}

class InvoicesSummaryDialog extends StatelessWidget {
  const InvoicesSummaryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();
    return AlertDialog(
      title: const Text('Invoice Transactions Record', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Text('A total of ${controller.totalOrders.value} individual checkout sales records have been written to the system database history log.'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('CLOSE', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
}

class LowStockDetailsDialog extends StatelessWidget {
  const LowStockDetailsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();
    return AlertDialog(
      title: const Row(
        children: <Widget>[
          Icon(Icons.warning, color: AppColors.warning),
          SizedBox(width: 8),
          Text('Low Stock Alerts', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Text('There are currently ${controller.lowStockCount.value} products in your catalog master directory that have 5 or fewer items remaining in inventory.'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('CLOSE', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
}

class ExpiryDetailsDialog extends StatelessWidget {
  const ExpiryDetailsDialog({super.key});

  @override
  Widget build(_) {
    final DashboardController controller = Get.find<DashboardController>();
    return AlertDialog(
      title: const Row(
        children: <Widget>[
          Icon(Icons.hourglass_bottom, color: Colors.orange),
          SizedBox(width: 8),
          Text('Product Expiry Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: controller.expiryItemsList.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: Text('All clear! No products are currently expired or expiring within 30 days.', style: TextStyle(color: Colors.grey)),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: controller.expiryItemsList.length,
                itemBuilder: (_, int index) {
                  final dynamic item = controller.expiryItemsList[index];
                  final bool isExpired = item['is_expired'] ?? false;

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade600, width: 1.0),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Icon(isExpired ? Icons.cancel : Icons.error_outline, color: isExpired ? AppColors.error : AppColors.warning),
                      title: Text(
                        item['name'] ?? 'Unknown Product',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text('Code: ${item['code']} • Stock Remaining: ${item['quantity']}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            isExpired ? 'EXPIRED' : 'EXPIRING SOON',
                            style: TextStyle(color: isExpired ? AppColors.error : AppColors.warning, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(item['expiry_label'] ?? '', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Get.back(),
          child: const Text(
            'CLOSE',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class FullLeaderboardDialog extends StatelessWidget {
  const FullLeaderboardDialog({super.key});

  @override
  Widget build(_) {
    final DashboardController controller = Get.find<DashboardController>();
    return AlertDialog(
      title: const Text('Complete Moving Leaderboard', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 450,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: controller.topProductsList.length,
          itemBuilder: (_, int index) {
            final dynamic item = controller.topProductsList[index];
            return ListTile(
              leading: Text('${index + 1}.', style: const TextStyle(color: Colors.grey)),
              title: Text(item['p_name'] ?? 'Unknown'),
              subtitle: Text('${item['total_qty_sold']} units sold', style: const TextStyle(color: Colors.grey, fontSize: 11)),
              trailing: Text(
                '₱${(item['total_revenue_generated'] as num).toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('CLOSE', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
}

class AllRecentInvoicesDialog extends StatelessWidget {
  const AllRecentInvoicesDialog({super.key});

  @override
  Widget build(_) {
    final DashboardController controller = Get.find<DashboardController>();
    return AlertDialog(
      title: const Text('Full Recent Invoices Index', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 500,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: controller.recentOrdersList.length,
          itemBuilder: (_, int index) {
            final OrderModel order = controller.recentOrdersList[index];
            return ListTile(
              title: Text('ID: #${order.id.substring(0, 8).toUpperCase()}'),
              subtitle: Text('Date: ${order.orderAt.toString().substring(0, 16)}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
              trailing: Text(
                '₱${order.total.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              onTap: () => Get.dialog(SingleReceiptDetailDialog(order: order)),
            );
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('CLOSE', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
}

class SingleReceiptDetailDialog extends StatelessWidget {
  final OrderModel order;
  const SingleReceiptDetailDialog({super.key, required this.order});

  @override
  Widget build(_) => AlertDialog(
    title: Row(
      children: <Widget>[
        const Icon(Icons.receipt_long, size: 22),
        const SizedBox(width: 8),
        Text('Invoice #${order.id.substring(0, 8).toUpperCase()} Details', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    ),
    content: SizedBox(
      width: 480,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Transaction Reference: ${order.id}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 4),
            Text('Date Placed: ${order.orderAt.toString().substring(0, 16)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const Divider(color: Colors.grey, height: 24, thickness: 1),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: FullInvoiceTable(order: order),
              ),
            ),

            const Divider(color: Colors.grey, height: 32, thickness: 1.5),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('Total Paid Amount:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(
                  '₱${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () => Get.back(),
        child: const Text(
          'BACK',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
    ],
  );
}

class FullInvoiceTable extends StatelessWidget {
  final OrderModel order;

  const FullInvoiceTable({super.key, required this.order});

  @override
  Widget build(_) => DataTable(
    horizontalMargin: 0,
    columnSpacing: 24,
    headingRowHeight: 28,
    dataRowMinHeight: 32,
    dataRowMaxHeight: 48,
    columns: const <DataColumn>[
      DataColumn(
        label: Text(
          'Item Name',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn(
        label: Text(
          'Qty',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        numeric: true,
      ),
      DataColumn(
        label: Text(
          'Subtotal',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        numeric: true,
      ),
    ],
    rows: List<DataRow>.generate(order.name.length, (int idx) {
      return DataRow(
        cells: <DataCell>[
          DataCell(
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child: Text(order.name[idx], style: const TextStyle(fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ),
          DataCell(Text('x${order.quantity[idx]}', style: const TextStyle(fontSize: 13))),
          DataCell(
            Text(
              '₱${order.amount[idx].toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      );
    }),
  );
}
