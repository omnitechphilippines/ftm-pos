import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../models/order_model.dart';
import '../../../../widgets/app_bars/custom_app_bar.dart';
import '../../../../widgets/drawers/side_drawer.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentRoute = Get.currentRoute.isNotEmpty ? Get.currentRoute : (Get.routing.current.isNotEmpty ? Get.routing.current : ModalRoute.of(context)?.settings.name ?? '');
    final bool isMobile = MediaQuery.of(context).size.width < 1024;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Dashboard',
        actions: <Widget>[IconButton(icon: const Icon(Icons.refresh), onPressed: () => controller.refreshDashboard(), tooltip: 'Refresh Dashboard')],
      ),
      drawer: SideDrawer(currentRoute: currentRoute),
      body: Obx(() {
        if (controller.isLoading.value && controller.recentOrdersList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshDashboard(),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // SECTION 1: Clickable KPI Summary Metric Cards Grid
                isMobile ? _buildVerticalMetrics(context) : _buildHorizontalMetrics(context),
                SizedBox(height: isMobile ? 16 : 24),

                // SECTION 2: Data Insights Splitting Layout
                if (isMobile) ...<Widget>[_buildTopProductsCard(context), const SizedBox(height: 16), _buildRecentOrdersCard(context)] else ...<Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(flex: 4, child: _buildTopProductsCard(context)),
                      const SizedBox(width: 24),
                      Expanded(flex: 6, child: _buildRecentOrdersCard(context)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHorizontalMetrics(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: _buildClickableMetricCard(context, 'Gross Revenue', '₱${controller.totalRevenue.value.toStringAsFixed(2)}', Icons.payments, Colors.green, () => _showRevenueDetails())),
        const SizedBox(width: 16),
        Expanded(child: _buildClickableMetricCard(context, 'Total Invoices', '${controller.totalOrders.value}', Icons.receipt, Colors.blue, () => _showInvoicesSummaryDialog())),
        const SizedBox(width: 16),
        Expanded(child: _buildClickableMetricCard(context, 'Low Stock Alerts', '${controller.lowStockCount.value}', Icons.inventory_2, Colors.orange, () => _showLowStockDetailsDialog())),
        // NEW: Expiry Monitoring KPI Dashboard Card
        const SizedBox(width: 16),
        Expanded(child: _buildClickableMetricCard(context, 'Expiry Alerts', '${controller.expiryAlertCount.value}', Icons.running_with_errors, controller.expiryItemsList.any((dynamic item) => item['is_expired'] == true) ? Colors.red : Colors.yellow, () => _showExpiryDetailsDialog())),
      ],
    );
  }

  Widget _buildVerticalMetrics(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildClickableMetricCard(context, 'Gross Revenue', '₱${controller.totalRevenue.value.toStringAsFixed(2)}', Icons.payments, Colors.green, () => _showRevenueDetails()),
        const SizedBox(height: 12),
        _buildClickableMetricCard(context, 'Total Invoices', '${controller.totalOrders.value}', Icons.receipt, Colors.blue, () => _showInvoicesSummaryDialog()),
        const SizedBox(height: 12),
        _buildClickableMetricCard(context, 'Low Stock Alerts', '${controller.lowStockCount.value}', Icons.inventory_2, Colors.orange, () => _showLowStockDetailsDialog()),
        // NEW: Expiry Monitoring KPI Dashboard Card
        const SizedBox(height: 12),
        _buildClickableMetricCard(context, 'Expiry Alerts', '${controller.expiryAlertCount.value}', Icons.running_with_errors, controller.expiryItemsList.any((dynamic item) => item['is_expired'] == true) ? Colors.red : Colors.yellow, () => _showExpiryDetailsDialog()),
      ],
    );
  }

  Widget _buildClickableMetricCard(BuildContext context, String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias, // Ensures the splash ripple effect stays inside the card borders
      child: InkWell(
        onTap: onTap,
        hoverColor: Colors.white.withValues(alpha: 0.05),
        splashColor: color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.2),
                radius: 26,
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopProductsCard(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showFullLeaderboardDialog(),
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
                  itemBuilder: (BuildContext context, int index) {
                    final dynamic item = controller.topProductsList[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(backgroundColor: const Color(0xFF1F212C), child: Text('${index + 1}')),
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

  Widget _buildRecentOrdersCard(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showAllRecentInvoicesDialog(),
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
                  itemBuilder: (BuildContext context, int index) {
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
                      onTap: () => _showSingleReceiptDetailPopUp(order),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRevenueDetails() {
    Get.dialog(
      AlertDialog(
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
      ),
    );
  }

  void _showInvoicesSummaryDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Invoice Transactions Record', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('A total of ${controller.totalOrders.value} individual checkout sales records have been written to the system database history log.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CLOSE', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _showLowStockDetailsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: <Widget>[
            Icon(Icons.warning, color: Colors.orange),
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
      ),
    );
  }

  void _showFullLeaderboardDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Complete Moving Leaderboard', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 450,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: controller.topProductsList.length,
            itemBuilder: (BuildContext context, int index) {
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
      ),
    );
  }

  void _showAllRecentInvoicesDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Full Recent Invoices Index', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 500,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: controller.recentOrdersList.length,
            itemBuilder: (BuildContext context, int index) {
              final OrderModel order = controller.recentOrdersList[index];
              return ListTile(
                title: Text('ID: #${order.id.substring(0, 8).toUpperCase()}'),
                subtitle: Text('Date: ${order.orderAt.toString().substring(0, 16)}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                trailing: Text(
                  '₱${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Get.back(); // Closes index list first
                  _showSingleReceiptDetailPopUp(order); // Opens detailed items view
                },
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
      ),
    );
  }

  void _showSingleReceiptDetailPopUp(OrderModel order) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: <Widget>[
            const Icon(Icons.receipt_long, size: 22),
            const SizedBox(width: 8),
            Text('Invoice #${order.id.substring(0, 8).toUpperCase()} Details', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: SizedBox(
          width: 480, // Bounded fallback width for desktop monitors
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Transaction Reference: ${order.id}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                const SizedBox(height: 4),
                Text('Date Placed: ${order.orderAt.toString().substring(0, 16)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const Divider(color: Colors.grey, height: 24, thickness: 1),

                // Double-scrollable container prevents any UI rendering exceptions on small phones
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
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
                    ),
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
      ),
    );
  }

  void _showExpiryDetailsDialog() {
    Get.dialog(
      AlertDialog(
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
                  itemBuilder: (BuildContext context, int index) {
                    final dynamic item = controller.expiryItemsList[index];
                    final bool isExpired = item['is_expired'] ?? false;

                    return Card(
                      // color: const Color(0xFF1F212C),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: Icon(isExpired ? Icons.cancel : Icons.error_outline, color: isExpired ? Colors.red : Colors.yellow),
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
                              style: TextStyle(color: isExpired ? Colors.red : Colors.yellow, fontSize: 10, fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
