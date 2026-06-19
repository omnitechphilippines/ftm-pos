import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../models/order_model.dart';
import '../../../../models/product_model.dart';
import '../../../../services/responsive_service.dart';
import '../../../../themes/app_theme.dart';
import '../../../../widgets/app_bars/custom_app_bar.dart';
import '../../../../widgets/drawers/side_drawer.dart';
import '../../../../widgets/loading_indicators/loading_indicator.dart';
import '../../../../widgets/search_bars/custom_search_bar.dart';
import '../controllers/orders_controller.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentRoute = Get.currentRoute.isNotEmpty ? Get.currentRoute : (Get.routing.current.isNotEmpty ? Get.routing.current : ModalRoute.of(context)?.settings.name ?? '/');

    return Obx(
      () => Scaffold(
        appBar: CustomAppBar(
          title: 'Orders',
          actions: controller.isLoading.value
              ? null
              : <Widget>[
                  IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: () => Get.dialog(barrierDismissible: false, const ScannerDialog()).then((_) => controller.disposeScanner()), tooltip: 'Scan Barcode'),
                  Obx(
                    () => Stack(
                      children: <Widget>[
                        IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () => controller.showCartDialog(), tooltip: 'Cart'),
                        if (controller.cart.value > 0)
                          Positioned(
                            right: 0,
                            bottom: -1,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                              child: Center(
                                child: Text(
                                  controller.cart.value.toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
        ),
        drawer: SideDrawer(currentRoute: currentRoute),
        body: controller.isLoading.value
            ? const LoadingIndicator(label: 'Loading products...')
            : Column(
                children: <Widget>[
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomSearchBar(
                      textEditingController: controller.searchInputController,
                      onSubmitted: (String value) {
                        controller.searchQuery.value = value;
                        controller.filterProducts();
                      },
                      hintText: 'Search by name or code...',
                    ),
                  ),

                  // Product Cards List
                  Expanded(
                    child: controller.filteredProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text('No products found', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => controller.fetchProducts(),
                            child: LayoutBuilder(
                              builder: (BuildContext context, BoxConstraints constraints) {
                                final double width = constraints.maxWidth;
                                final int crossAxisCount = (width / 250).floor().clamp(2, 8);

                                return GridView.builder(
                                  itemCount: controller.filteredProducts.length,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, childAspectRatio: 0.75),
                                  itemBuilder: (BuildContext context, int index) {
                                    final ProductModel product = controller.filteredProducts[index];
                                    return OrderCard(product: product);
                                  },
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final ProductModel product;

  const OrderCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final OrdersController controller = Get.find<OrdersController>();
    final ResponsiveService responsive = Get.find<ResponsiveService>();
    final bool isMobile = responsive.isMobile(context);

    final bool isExpiringSoon = product.expiryDate != null && product.expiryDate!.difference(DateTime.now()).inDays <= 30 && product.expiryDate!.isAfter(DateTime.now());
    final bool isExpired = product.expiryDate != null && product.expiryDate!.isBefore(DateTime.now());
    final bool isLowStock = product.quantity <= 5;

    final double cardMargin = isMobile ? 8.0 : 16.0;
    final double actionButtonSize = isMobile ? 28.0 : 32.0;
    final double actionIconSize = isMobile ? 14.0 : 18.0;

    return Obx(() {
      final int currentOrderedQty = controller.orderedProduct(product)?.quantity ?? 0;
      return Stack(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(cardMargin),
            decoration: BoxDecoration(
              color: const Color(0xFF4D4F5B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isExpired ? AppColors.error : (isExpiringSoon ? AppColors.warning : Colors.grey), width: isExpired || isExpiringSoon ? 2 : 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: const Color(0xFF3D3F4A), borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        onTap: () => Get.dialog(Dialog(child: InteractiveViewer(child: product.image != null ? Image.memory(product.image!) : const Icon(Icons.image_outlined, size: 250)))),
                        child: Hero(
                          tag: 'product-img-${product.id}',
                          child: product.image != null ? Image.memory(product.image!, fit: BoxFit.contain) : const Icon(Icons.image_outlined, size: 100),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: InkWell(
                      onTap: () => Get.dialog(ProductDialog(product: product)),
                      child: Text(
                        product.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '₱${product.sellingPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // Minus Button
                          SizedBox(
                            width: actionButtonSize,
                            height: actionButtonSize,
                            child: Container(
                              decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.remove, size: actionIconSize),
                                onPressed: currentOrderedQty > 0 ? () => controller.decrementCart(product, currentOrderedQty) : null,
                                tooltip: 'Deduct',
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          // Text Quantity Field
                          SizedBox(
                            width: 32,
                            child: TextField(
                              controller: controller.getQuantityTextController(currentOrderedQty),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, TextInputFormatter.withFunction((TextEditingValue oldValue, TextEditingValue newValue) => (int.tryParse(newValue.text) ?? 0) <= product.quantity ? newValue : oldValue)],
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 4)),
                              onSubmitted: (String value) {
                                final int? quantity = int.tryParse(value);
                                if (quantity != null && quantity >= 0) {
                                  controller.updateProductQuantity(product, quantity);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 2),
                          // Plus Button
                          SizedBox(
                            width: actionButtonSize,
                            height: actionButtonSize,
                            child: Container(
                              decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.add, size: actionIconSize),
                                onPressed: product.quantity != currentOrderedQty ? () => controller.incrementCart(product, currentOrderedQty) : null,
                                tooltip: 'Add',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${product.quantity} pcs left', style: TextStyle(fontSize: 12, color: isLowStock ? Colors.redAccent : Colors.white70)),
                ],
              ),
            ),
          ),
          // Cart count indicator badge
          if (currentOrderedQty > 0)
            Positioned(
              right: isMobile ? 4 : 10,
              top: isMobile ? 4 : 10,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                child: Center(
                  child: Text(
                    currentOrderedQty.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

class ScannerDialog extends StatelessWidget {
  const ScannerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final OrdersController controller = Get.find<OrdersController>();
    controller.initializeScanner();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('Scan Barcode', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller.disposeScanner();
                    Get.back();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: MobileScanner(
                  controller: controller.scannerController,
                  onDetect: (BarcodeCapture capture) async {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                      final String code = barcodes.first.rawValue!;
                      controller.disposeScanner();
                      Get.back();

                      // Search for existing product
                      final ProductModel? product = controller.searchProductByCode(int.parse(code));
                      if (product != null) {
                        controller.incrementCart(product, controller.orderedProduct(product)?.quantity ?? 0);
                        controller.searchQuery.value = product.code.toString();
                        controller.searchInputController.text = product.code.toString();
                      } else {
                        Get.snackbar(
                          '',
                          '',
                          snackPosition: .BOTTOM,
                          backgroundColor: Colors.white,
                          borderRadius: 0,
                          titleText: const SizedBox.shrink(),
                          messageText: const Text('Product not found!', style: TextStyle(color: Colors.black)),
                        );
                      }
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Position the barcode within the frame', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class OrderReceiptDialog extends StatelessWidget {
  const OrderReceiptDialog({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final OrdersController controller = Get.find<OrdersController>();
    return AlertDialog(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: .spaceBetween,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.receipt_long, color: Colors.blueGrey),
              SizedBox(width: 10),
              Text('Order Receipt', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
        ],
      ),
      content: IntrinsicWidth(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Get.size.width * 0.9),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Divider(thickness: 1.5),

                Text('Date: ${order.orderAt.toString().substring(0, 16)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 10),

                // Table Layout for Items, Price, Qty, Amount
                Center(
                  child: SingleChildScrollView(
                    scrollDirection: .horizontal,
                    child: DataTable(
                      columnSpacing: 6,
                      horizontalMargin: 0,
                      columns: const <DataColumn>[
                        DataColumn(
                          label: Text('No.', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Item', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Price', style: TextStyle(fontWeight: FontWeight.bold)),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold)),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                          numeric: true,
                        ),
                      ],
                      rows: List<DataRow>.generate(order.name.length, (int index) {
                        String displayName = order.name[index];
                        if (displayName.length > 16) {
                          displayName = '${displayName.substring(0, 15)}...';
                        }

                        return DataRow(
                          cells: <DataCell>[DataCell(Text((index + 1).toString())), DataCell(Text(displayName)), DataCell(Text('₱${order.sellingPrice[index].toStringAsFixed(2)}')), DataCell(Text('x${order.quantity[index]}')), DataCell(Text('₱${order.amount[index].toStringAsFixed(2)}'))],
                        );
                      }),
                    ),
                  ),
                ),

                const Divider(thickness: 1.5),

                // Total Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text('TOTAL:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      '₱${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ElevatedButton(
          onPressed: () => controller.showOrderConfirmationDialog(),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Confirm Order', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class ProductDialog extends StatelessWidget {
  final ProductModel product;
  const ProductDialog({super.key, required this.product});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: Get.size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Product Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                ],
              ),
              const SizedBox(height: 20),

              // Product Code with Scanner
              TextField(
                readOnly: true,
                controller: TextEditingController(text: product.code.toString()),
                decoration: InputDecoration(
                  labelText: 'Product Code *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.qr_code),
                ),
              ),
              const SizedBox(height: 16),

              // Product Name
              TextField(
                readOnly: true,
                controller: TextEditingController(text: product.name),
                decoration: InputDecoration(
                  labelText: 'Product Name *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.inventory_2),
                ),
              ),
              const SizedBox(height: 16),

              // Prices Row
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      controller: TextEditingController(text: product.originalPrice.toString()),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Original Price *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Text('₱', style: TextStyle(fontSize: 24), textAlign: .center),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      controller: TextEditingController(text: product.sellingPrice.toString()),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Selling Price *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.sell),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Quantity
              TextField(
                readOnly: true,
                controller: TextEditingController(text: product.quantity.toString()),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.numbers),
                ),
              ),
              const SizedBox(height: 16),

              // Weight
              TextField(
                readOnly: true,
                controller: TextEditingController(text: product.weight!.isEmpty || product.weight == 'null' ? ' ' : product.weight),
                decoration: InputDecoration(
                  labelText: 'Weight (Optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.scale),
                ),
              ),
              const SizedBox(height: 16),

              // Expiry Date
              TextField(
                readOnly: true,
                controller: TextEditingController(text: product.expiryDate.toString() == 'null' ? ' ' : DateFormat('MMM dd, yyyy').format(product.expiryDate!)),
                decoration: InputDecoration(
                  labelText: 'Expiry Date (Optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.date_range),
                ),
              ),
              const SizedBox(height: 24),

              // Product Image
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Product Image', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  InkWell(
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: product.image != null ? Image.memory(product.image!, fit: BoxFit.contain) : const Icon(Icons.image_outlined, size: 200),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
