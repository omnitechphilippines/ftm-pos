import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';

import '../../../../models/order_model.dart';
import '../../../../models/product_model.dart';
import '../../../../widgets/app_bars/custom_app_bar.dart';
import '../../../../widgets/drawers/side_drawer.dart';
import '../controllers/orders_controller.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});
  @override
  Widget build(BuildContext context) {
    final String currentRoute = Get.currentRoute.isNotEmpty ? Get.currentRoute : (Get.routing.current.isNotEmpty ? Get.routing.current : ModalRoute.of(context)?.settings.name ?? '/');
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Orders',
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: () => _showScannerDialog(), tooltip: 'Scan Barcode'),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => controller.fetchProducts(), tooltip: 'Refresh'),
          Obx(
            () => Stack(
              children: <Widget>[
                IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () => _showReceiptDialog(), tooltip: 'Cart'),
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
      body: Column(
        children: <Widget>[
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (String value) => controller.searchQuery.value = value,
              decoration: InputDecoration(
                hintText: 'Search by name or code...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
              ),
            ),
          ),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.products.isEmpty) {
                return _buildLoadingIndicator();
              }

              if (controller.filteredProducts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No products found', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                    ],
                  ),
                );
              }

              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double width = constraints.maxWidth;
                  final int crossAxisCount = (width / 250).floor().clamp(2, 6);

                  return GridView.builder(
                    itemCount: controller.filteredProducts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, childAspectRatio: 0.75),
                    itemBuilder: (BuildContext context, int index) {
                      final ProductModel product = controller.filteredProducts[index];
                      return Obx(() => _buildOrderCard(product));
                    },
                  );
                },
              );
            }),
          ),
          // _pagination(),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading products...', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Widget _pagination() {
  //   return Obx(
  //     () => Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //       color: const Color(0xFF2A2D3E),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: <Widget>[
  //           ElevatedButton(
  //             onPressed: controller.currentPage.value > 1 ? () => controller.navigateToPage(controller.currentPage.value - 1) : null,
  //             style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(8), backgroundColor: Colors.blue[100], foregroundColor: Colors.blue[800]),
  //             child: const Icon(Icons.chevron_left),
  //           ),
  //           const SizedBox(width: 16),
  //           Text('Page ${controller.currentPage} of ${controller.totalPages}', style: const TextStyle(fontWeight: FontWeight.w500)),
  //           const SizedBox(width: 16),
  //           ElevatedButton(
  //             onPressed: controller.currentPage.value < controller.totalPages ? () => controller.navigateToPage(controller.currentPage.value + 1) : null,
  //             style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(8), backgroundColor: Colors.blue[100], foregroundColor: Colors.blue[800]),
  //             child: const Icon(Icons.chevron_right),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void _showScannerDialog({Function(String)? onScanned}) {
    controller.initializeScanner();

    Get.dialog(
      barrierDismissible: false,
      Dialog(
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

                        if (onScanned != null) {
                          onScanned(code);
                        } else {
                          // Search for existing product
                          final ProductModel? product = await controller.searchProductByCode(code);
                          if (product != null) {
                            controller.loadProductToForm(product);
                            _showProductDialog(product: product);
                          } else {
                            // Create new product with scanned code
                            // controller.codeController.text = code;
                            _showProductDialog();
                          }
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
      ),
    ).then((_) => controller.disposeScanner());
  }

  void _showProductDialog({ProductModel? product}) {}

  Widget _buildOrderCard(ProductModel product) {
    final bool isExpiringSoon = product.expiryDate != null && product.expiryDate!.difference(DateTime.now()).inDays <= 30 && product.expiryDate!.isAfter(DateTime.now());
    final bool isExpired = product.expiryDate != null && product.expiryDate!.isBefore(DateTime.now());
    final bool isLowStock = product.quantity <= 5;
    int orderedProductsCount = controller.orderedProducts.firstWhereOrNull((ProductModel p) => p.name == product.name)?.quantity ?? 0;
    return Stack(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF4D4F5B),
            borderRadius: BorderRadius.circular(20),
            boxShadow: <BoxShadow>[BoxShadow(color: Colors.grey.withValues(alpha: 0.05), spreadRadius: 2, blurRadius: 10, offset: const Offset(0, 5))],
            border: Border.all(color: isExpired ? Colors.red : (isExpiringSoon ? Colors.orange : Colors.grey), width: isExpired || isExpiringSoon ? 2 : 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: const Color(0xFF4D4F5B), borderRadius: BorderRadius.circular(16)),
                    child: Center(
                      child: InkWell(
                        onTap: () => Get.dialog(
                          Dialog(
                            child: ClipRRect(child: InteractiveViewer(child: Image.memory(product.image))),
                          ),
                        ),
                        child: Image.memory(product.image),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    product.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                    textAlign: .center,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '₱${product.sellingPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: Container(
                            decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                            child: IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: orderedProductsCount > 0
                                  ? () {
                                      controller.cart.value--;
                                      orderedProductsCount--;
                                      product.quantity++;
                                      if (orderedProductsCount == 0) {
                                        controller.orderedProducts.removeAt(controller.orderedProducts.indexWhere((ProductModel p) => p.name == product.name));
                                      } else {
                                        controller.orderedProducts[controller.orderedProducts.indexWhere((ProductModel p) => p.name == product.name)] = product.copyWith(quantity: orderedProductsCount);
                                      }
                                    }
                                  : null,
                              tooltip: 'Deduct',
                              splashRadius: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: Container(
                            decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                            child: IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: controller.products[controller.products.indexOf(product)].quantity > 0
                                  ? () {
                                      controller.cart.value++;
                                      orderedProductsCount++;
                                      product.quantity--;
                                      if (orderedProductsCount == 1) {
                                        controller.orderedProducts.add(product.copyWith(quantity: 1));
                                      } else {
                                        controller.orderedProducts[controller.orderedProducts.indexWhere((ProductModel p) => p.name == product.name)] = product.copyWith(quantity: orderedProductsCount);
                                      }
                                    }
                                  : null,
                              tooltip: 'Add',
                              splashRadius: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text('${product.quantity} pcs', style: TextStyle(color: isLowStock ? Colors.red : Colors.white)),
              ],
            ),
          ),
        ),
        if (orderedProductsCount > 0)
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Center(
                child: Text(
                  orderedProductsCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showReceiptDialog() {
    controller.orderedProducts.sort((ProductModel a, ProductModel b) => a.name.compareTo(b.name));
    controller.cartItems = OrderModel(
      id: const Uuid().v4(),
      code: controller.orderedProducts.map((ProductModel product) => product.code).toList(),
      name: controller.orderedProducts.map((ProductModel product) => product.name).toList(),
      originalPrice: controller.orderedProducts.map((ProductModel product) => product.originalPrice).toList(),
      sellingPrice: controller.orderedProducts.map((ProductModel product) => product.sellingPrice).toList(),
      amount: controller.orderedProducts.map((ProductModel product) => product.sellingPrice * product.quantity).toList(),
      quantity: controller.orderedProducts.map((ProductModel product) => product.quantity).toList(),
      total: controller.orderedProducts.fold(0.0, (double sum, ProductModel product) => sum + product.sellingPrice * product.quantity),
      orderAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (controller.cartItems == null || controller.cartItems!.name.isEmpty) {
      Get.snackbar(
        '',
        '',
        snackPosition: .BOTTOM,
        backgroundColor: Colors.white,
        borderRadius: 0,
        titleText: const SizedBox.shrink(),
        messageText: const Text('Your cart is empty!', style: TextStyle(color: Colors.black)),
      );
      return;
    }

    final OrderModel order = controller.cartItems!;

    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
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
            onPressed: () {
              controller.showConfirmationDialog();
              // Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirm Order', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (controller.isLoading.value) {
      Get.dialog(const Center(child: CircularProgressIndicator()));
    }
  }
}
