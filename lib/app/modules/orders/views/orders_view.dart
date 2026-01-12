import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../models/product_model.dart';
import '../../../../widgets/app_bars/custom_app_bar.dart';
import '../../../../widgets/cards/product_card.dart';
import '../../../../widgets/drawers/side_drawer.dart';
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
          actions: <Widget>[
            IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: () => _showScannerDialog(controller), tooltip: 'Scan Barcode'),
            Stack(
              children: <Widget>[
                IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () {}, tooltip: 'Cart'),
                if (controller.cart.value > 0)
                  Positioned(
                    right: 0,
                    bottom: -3,
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
          ],
        ),
        drawer: SideDrawer(currentRoute: currentRoute),
        body: Column(
          children: <Widget>[
            Expanded(
              child: controller.isLoading.value
                  ? _buildLoadingIndicator(controller)
                  : LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        final double width = constraints.maxWidth;
                        final int crossAxisCount = (width / 250).floor().clamp(2, 6);

                        return GridView.builder(
                          itemCount: controller.products.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, childAspectRatio: 0.75),
                          itemBuilder: (BuildContext context, int index) => ProductCard(product: controller.products[index]),
                        );
                      },
                    ),
            ),
            _pagination(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(OrdersController productsController) {
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

  Widget _pagination() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: const Color(0xFF2A2D3E),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: controller.currentPage.value > 1 ? () => controller.navigateToPage(controller.currentPage.value - 1) : null,
              style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(8), backgroundColor: Colors.blue[100], foregroundColor: Colors.blue[800]),
              child: const Icon(Icons.chevron_left),
            ),
            const SizedBox(width: 16),
            Text('Page ${controller.currentPage} of ${controller.totalPages}', style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: controller.currentPage.value < controller.totalPages ? () => controller.navigateToPage(controller.currentPage.value + 1) : null,
              style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(8), backgroundColor: Colors.blue[100], foregroundColor: Colors.blue[800]),
              child: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  void _showScannerDialog(OrdersController controller, {Function(String)? onScanned}) {
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
                            _showProductDialog(controller, product: product);
                          } else {
                            // Create new product with scanned code
                            // controller.codeController.text = code;
                            _showProductDialog(controller);
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

  void _showProductDialog(OrdersController controller, {ProductModel? product}) {
    // final bool isEditing = product != null;

    // if (!isEditing) {
    //   controller.clearForm();
    // }

    // Get.dialog(
    //   barrierDismissible: false,
    //   Builder(
    //     builder: (BuildContext context) {
    //       return Dialog(
    //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    //         child: Container(
    //           width: Get.mediaQuery.size.width * 0.9,
    //           constraints: const BoxConstraints(maxWidth: 600),
    //           padding: const EdgeInsets.all(24),
    //           child: SingleChildScrollView(
    //             child: Column(
    //               mainAxisSize: MainAxisSize.min,
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: <Widget>[
    //                 Row(
    //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                   children: <Widget>[
    //                     Text(isEditing ? 'Edit Product' : 'Add New Product', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    //                     IconButton(
    //                       icon: const Icon(Icons.close),
    //                       onPressed: () {
    //                         // controller.clearForm();
    //                         Get.back();
    //                       },
    //                     ),
    //                   ],
    //                 ),
    //                 const SizedBox(height: 20),

    //                 // Product Code with Scanner
    //                 Row(
    //                   children: <Widget>[
    //                     Expanded(
    //                       child: TextField(
    //                         controller: controller.codeController,
    //                         decoration: InputDecoration(
    //                           labelText: 'Product Code *',
    //                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    //                           prefixIcon: const Icon(Icons.qr_code),
    //                         ),
    //                       ),
    //                     ),
    //                     const SizedBox(width: 8),
    //                     IconButton(
    //                       icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
    //                       onPressed: () {
    //                         Get.back();
    //                         _showScannerDialog(
    //                           controller,
    //                           onScanned: (String code) {
    //                             controller.codeController.text = code;
    //                             _showProductDialog(controller, product: product);
    //                           },
    //                         );
    //                       },
    //                       tooltip: 'Scan Barcode',
    //                     ),
    //                   ],
    //                 ),
    //                 const SizedBox(height: 16),

    //                 // Product Name
    //                 TextField(
    //                   controller: controller.nameController,
    //                   decoration: InputDecoration(
    //                     labelText: 'Product Name *',
    //                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    //                     prefixIcon: const Icon(Icons.inventory_2),
    //                   ),
    //                 ),
    //                 const SizedBox(height: 16),

    //                 // Prices Row
    //                 Row(
    //                   children: <Widget>[
    //                     Expanded(
    //                       child: TextField(
    //                         controller: controller.originalPriceController,
    //                         keyboardType: TextInputType.number,
    //                         decoration: InputDecoration(
    //                           labelText: 'Original Price *',
    //                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    //                           prefixIcon: const Text('₱', style: TextStyle(fontSize: 24), textAlign: .center),
    //                         ),
    //                       ),
    //                     ),
    //                     const SizedBox(width: 16),
    //                     Expanded(
    //                       child: TextField(
    //                         controller: controller.sellingPriceController,
    //                         keyboardType: TextInputType.number,
    //                         decoration: InputDecoration(
    //                           labelText: 'Selling Price *',
    //                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    //                           prefixIcon: const Icon(Icons.sell),
    //                         ),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //                 const SizedBox(height: 16),

    //                 // Quantity
    //                 TextField(
    //                   controller: controller.quantityController,
    //                   keyboardType: TextInputType.number,
    //                   decoration: InputDecoration(
    //                     labelText: 'Quantity *',
    //                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    //                     prefixIcon: const Icon(Icons.numbers),
    //                   ),
    //                 ),
    //                 const SizedBox(height: 16),

    //                 // Weight
    //                 TextField(
    //                   controller: controller.weightController,
    //                   decoration: InputDecoration(
    //                     labelText: 'Weight (Optional)',
    //                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    //                     prefixIcon: const Icon(Icons.scale),
    //                   ),
    //                 ),
    //                 const SizedBox(height: 16),

    //                 // Expiry Date
    //                 Obx(
    //                   () => InkWell(
    //                     onTap: () async {
    //                       final DateTime? date = await showDatePicker(context: context, initialDate: controller.expiryDate.value ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 3650)));
    //                       if (date != null) {
    //                         controller.expiryDate.value = date;
    //                       }
    //                     },
    //                     child: InputDecorator(
    //                       decoration: InputDecoration(
    //                         labelText: 'Expiry Date (Optional)',
    //                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    //                         prefixIcon: const Icon(Icons.calendar_today),
    //                         suffixIcon: controller.expiryDate.value != null ? IconButton(icon: const Icon(Icons.clear), onPressed: () => controller.expiryDate.value = null) : null,
    //                       ),
    //                       child: Text(controller.expiryDate.value != null ? DateFormat('MMM dd, yyyy').format(controller.expiryDate.value!) : 'Select date', style: TextStyle(color: controller.expiryDate.value != null ? Colors.black : Colors.grey)),
    //                     ),
    //                   ),
    //                 ),
    //                 const SizedBox(height: 24),

    //                 // Product Image
    //                 Obx(
    //                   () => Column(
    //                     crossAxisAlignment: CrossAxisAlignment.start,
    //                     children: <Widget>[
    //                       const Text('Product Image (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    //                       const SizedBox(height: 8),
    //                       if (controller.selectedImage.value != null)
    //                         Container(
    //                           width: double.infinity,
    //                           height: 200,
    //                           decoration: BoxDecoration(
    //                             borderRadius: BorderRadius.circular(8),
    //                             border: Border.all(color: Colors.grey[300]!),
    //                           ),
    //                           child: ClipRRect(
    //                             borderRadius: BorderRadius.circular(8),
    //                             child: Image.memory(controller.selectedImage.value!, fit: BoxFit.contain),
    //                           ),
    //                         )
    //                       else
    //                         InkWell(
    //                           onTap: () => controller.showImagePickerOptions(),
    //                           child: Container(
    //                             width: double.infinity,
    //                             height: 150,
    //                             decoration: BoxDecoration(
    //                               borderRadius: BorderRadius.circular(8),
    //                               border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
    //                               color: Colors.grey[100],
    //                             ),
    //                             child: Column(
    //                               mainAxisAlignment: MainAxisAlignment.center,
    //                               children: <Widget>[
    //                                 Icon(Icons.image_outlined, size: 48, color: Colors.grey[400]),
    //                                 const SizedBox(height: 8),
    //                                 Text('No image selected', style: TextStyle(color: Colors.grey[600])),
    //                               ],
    //                             ),
    //                           ),
    //                         ),
    //                     ],
    //                   ),
    //                 ),
    //                 const SizedBox(height: 16),

    //                 // Action Buttons
    //                 Row(
    //                   mainAxisAlignment: MainAxisAlignment.end,
    //                   children: <Widget>[
    //                     TextButton(
    //                       onPressed: () {
    //                         Get.back();
    //                         // controller.clearForm();
    //                       },
    //                       child: const Text('Cancel'),
    //                     ),
    //                     const SizedBox(width: 12),
    //                     Obx(
    //                       () => ElevatedButton(
    //                         onPressed: controller.isLoading.value
    //                             ? null
    //                             : () {
    //                                 if (isEditing) {
    //                                   controller.updateProduct(product.id);
    //                                 } else {
    //                                   controller.createProduct();
    //                                 }
    //                               },
    //                         style: ElevatedButton.styleFrom(
    //                           backgroundColor: Colors.blue,
    //                           padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
    //                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    //                         ),
    //                         child: controller.isLoading.value ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(isEditing ? 'Update' : 'Add Product'),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //       );
    //     },
    //   ),
    // );
  }
}
