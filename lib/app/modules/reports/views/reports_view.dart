import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_bars/custom_app_bar.dart';
import '../../../../core/widgets/drawers/side_drawer.dart';
import '../../../../core/widgets/loading_indicators/loading_indicator.dart';
import '../../../data/models/order_model.dart';
import '../controllers/reports_controller.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentRoute = Get.currentRoute.isNotEmpty ? Get.currentRoute : (Get.routing.current.isNotEmpty ? Get.routing.current : ModalRoute.of(context)?.settings.name ?? '/');

    // Detect if the device screen is mobile width
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return Obx(() {
      // Handle the system-level Android/iOS physical back button on mobile drill-downs
      return PopScope(
        canPop: !isMobile || (controller.selectedPeriod.value.isEmpty),
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (didPop) {
            return;
          }
          if (controller.selectedDetailedOrder.value != null) {
            controller.selectedDetailedOrder.value = null;
          } else if (controller.selectedPeriod.value.isNotEmpty) {
            controller.selectedPeriod.value = '';
          }
        },
        child: Scaffold(
          appBar: CustomAppBar(
            title: 'Sales & Reports',
            // Show a back button on mobile when deep inside drill-downs
            leading: isMobile && controller.selectedPeriod.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      if (controller.selectedDetailedOrder.value != null) {
                        controller.selectedDetailedOrder.value = null; // Go back to invoices list
                      } else {
                        controller.selectedPeriod.value = ''; // Go back to summary list
                      }
                    },
                  )
                : null, // Keeps standard burger drawer icon on top level
          ),
          drawer: isMobile && controller.selectedPeriod.value.isNotEmpty ? null : SideDrawer(currentRoute: currentRoute),
          body: () {
            if (controller.isLoading.value && controller.reportSummaryLines.isEmpty) {
              return const LoadingIndicator(label: 'Loading reports...');
            }

            // --- SCENARIO 1: MOBILE VIEW (Single Column Navigation Stack) ---
            if (isMobile) {
              if (controller.selectedPeriod.value.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildTimeframeSelector(),
                      const SizedBox(height: 20),
                      Expanded(child: _buildSummaryList()),
                    ],
                  ),
                );
              }

              if (controller.selectedDetailedOrder.value == null) {
                return Container(padding: const EdgeInsets.all(16), child: _buildPeriodOrdersView());
              }

              return Container(padding: const EdgeInsets.all(16), child: _buildReceiptDetailsView(isMobile: true));
            }

            // --- SCENARIO 2: DESKTOP VIEW (3-Column Layout Preserved) ---
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildTimeframeSelector(),
                        const SizedBox(height: 20),
                        Expanded(child: _buildSummaryList()),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(color: Colors.grey, width: 1),
                Expanded(
                  flex: 3,
                  child: Container(padding: const EdgeInsets.all(16), child: _buildPeriodOrdersView()),
                ),
                const VerticalDivider(color: Colors.grey, width: 1),
                Expanded(
                  flex: 4,
                  child: Container(padding: const EdgeInsets.all(16), child: _buildReceiptDetailsView(isMobile: false)),
                ),
              ],
            );
          }(),
        ),
      );
    });
  }

  Widget _buildReceiptDetailsView({required bool isMobile}) {
    final OrderModel? order = controller.selectedDetailedOrder.value;
    if (order == null) {
      return const Center(
        child: Text('Click an invoice row to drill down into items & pricing.', style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Invoice Specifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(color: Colors.grey),
        Text('ID: ${order.id}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
        Text('Timestamp: ${order.orderAt}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 15),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Fixed mobile text constraint layout squeeze
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                horizontalMargin: 0,
                columnSpacing: isMobile ? 20 : 40, // Shrink columns spacing on mobile screen
                columns: const <DataColumn>[
                  DataColumn(label: Text('Item Name')),
                  DataColumn(label: Text('Qty'), numeric: true),
                  DataColumn(label: Text('Total'), numeric: true),
                ],
                rows: List<DataRow>.generate(order.name.length, (int idx) {
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(Text(order.name[idx])),
                      DataCell(Text('x${order.quantity[idx]}')),
                      DataCell(Text('₱${order.amount[idx].toStringAsFixed(2)}', style: const TextStyle(color: Colors.green))),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
        const Divider(color: Colors.grey, thickness: 1.5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text('Total Net Gross:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              '₱${order.total.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.green, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeframeSelector() {
    return ToggleButtons(
      isSelected: <bool>[controller.selectedTimeframe.value == 'Daily', controller.selectedTimeframe.value == 'Weekly', controller.selectedTimeframe.value == 'Monthly'],
      onPressed: (int index) {
        final List<String> options = <String>['Daily', 'Weekly', 'Monthly'];
        controller.changeTimeframe(options[index]);
      },
      borderRadius: BorderRadius.circular(8),
      selectedColor: Colors.white,
      fillColor: const Color(0xFF4D4F5B),
      color: Colors.grey,
      children: const <Widget>[
        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Daily')),
        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Weekly')),
        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Monthly')),
      ],
    );
  }

  Widget _buildSummaryList() {
    return ListView.builder(
      itemCount: controller.reportSummaryLines.length,
      itemBuilder: (BuildContext context, int index) {
        final dynamic line = controller.reportSummaryLines[index];
        final String periodLabel = line['report_date'] ?? '';
        final double sales = (line['total_sales'] ?? 0.0).toDouble();
        final int count = line['order_count'] ?? 0;
        final bool isSelected = controller.selectedPeriod.value == periodLabel;

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            selected: isSelected,
            title: Text(periodLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('$count Orders Placed', style: const TextStyle(color: Colors.grey)),
            trailing: Text(
              '₱${sales.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onTap: () => controller.drillDownIntoPeriod(periodLabel),
          ),
        );
      },
    );
  }

  Widget _buildPeriodOrdersView() {
    if (controller.selectedPeriod.isEmpty) {
      return const Center(
        child: Text('Select a report range to review individual invoices.', style: TextStyle(color: Colors.grey)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Invoices for: ${controller.selectedPeriod.value}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(color: Colors.grey),
        Expanded(
          child: ListView.builder(
            itemCount: controller.detailedOrdersForPeriod.length,
            itemBuilder: (BuildContext context, int index) {
              final OrderModel order = controller.detailedOrdersForPeriod[index];
              final bool isSelected = controller.selectedDetailedOrder.value?.id == order.id;

              return ListTile(
                selected: isSelected,
                title: Text('Invoice ID: ${order.id.substring(0, 13)}...'),
                subtitle: Text('Time: ${order.orderAt.toString().substring(11, 16)}', style: const TextStyle(color: Colors.grey)),
                trailing: Text('₱${order.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () => controller.selectSpecificOrder(order),
              );
            },
          ),
        ),
      ],
    );
  }
}
