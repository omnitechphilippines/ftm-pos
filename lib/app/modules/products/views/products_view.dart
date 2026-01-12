import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../models/product_model.dart';
import '../../../../widgets/app_bars/custom_app_bar.dart';
import '../../../../widgets/drawers/side_drawer.dart';
import '../controllers/products_controller.dart';

class ProductsView extends GetView<ProductsController> {
  const ProductsView({super.key});
  @override
  Widget build(BuildContext context) {
    final String currentRoute = Get.currentRoute.isNotEmpty ? Get.currentRoute : (Get.routing.current.isNotEmpty ? Get.routing.current : ModalRoute.of(context)?.settings.name ?? '/');
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Products',
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: () => _showScannerDialog(controller), tooltip: 'Scan Barcode'),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => controller.fetchProducts(), tooltip: 'Refresh'),
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
                // fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Product List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.products.isEmpty) {
                return const Center(child: CircularProgressIndicator());
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

              return RefreshIndicator(
                onRefresh: controller.fetchProducts,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.filteredProducts.length,
                  itemBuilder: (BuildContext context, int index) {
                    final ProductModel product = controller.filteredProducts[index];
                    return _buildProductCard(product, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _showProductDialog(controller), icon: const Icon(Icons.add), label: const Text('Add Product'), backgroundColor: Colors.blue),
    );
  }

  Widget _buildProductCard(ProductModel product, ProductsController controller) {
    final bool isExpiringSoon = product.expiryDate != null && product.expiryDate!.difference(DateTime.now()).inDays <= 30 && product.expiryDate!.isAfter(DateTime.now());

    final bool isExpired = product.expiryDate != null && product.expiryDate!.isBefore(DateTime.now());

    final bool isLowStock = product.quantity <= 5;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: product.image != null
            ? InkWell(
                onTap: () => Get.dialog(
                  Dialog(
                    insetPadding: const EdgeInsets.all(16),
                    child: InteractiveViewer(child: Image.memory(product.image!)),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(product.image!, width: 56, height: 56, fit: BoxFit.contain),
                ),
              )
            : CircleAvatar(
                backgroundColor: isExpired ? Colors.red : (isExpiringSoon ? Colors.orange : Colors.blue),
                child: Text(
                  product.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
        title: Text(product.weight!.isNotEmpty ? '${product.name} - ${product.weight}' : product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 4),
            Text('Code: ${product.code}'),
            Text('Price: ₱ ${product.sellingPrice.toStringAsFixed(2)}'),
            Row(
              children: <Widget>[
                Text(
                  'Stock: ${product.quantity}',
                  style: TextStyle(color: isLowStock ? Colors.red : Colors.black87, fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal),
                ),
                if (isLowStock)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.warning, color: Colors.red, size: 16),
                  ),
              ],
            ),
            if (product.expiryDate != null)
              Text(
                'Expires: ${DateFormat('MMM dd, yyyy').format(product.expiryDate!)}',
                style: TextStyle(color: isExpired ? Colors.red : (isExpiringSoon ? Colors.orange : Colors.black87), fontWeight: (isExpired || isExpiringSoon) ? FontWeight.bold : FontWeight.normal),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: <Widget>[
                  Icon(Icons.edit, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: <Widget>[
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
          onSelected: (String value) {
            if (value == 'edit') {
              controller.loadProductToForm(product);
              _showProductDialog(controller, product: product);
            } else if (value == 'delete') {
              _showDeleteConfirmation(controller, product);
            }
          },
        ),
      ),
    );
  }

  void _showProductDialog(ProductsController controller, {ProductModel? product}) {
    final bool isEditing = product != null;

    if (!isEditing) {
      controller.clearForm();
    }

    Get.dialog(
      barrierDismissible: false,
      Builder(
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: Get.mediaQuery.size.width * 0.9,
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
                        Text(isEditing ? 'Edit Product' : 'Add New Product', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            // controller.clearForm();
                            Get.back();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Product Code with Scanner
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: controller.codeController,
                            decoration: InputDecoration(
                              labelText: 'Product Code *',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.qr_code),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
                          onPressed: () {
                            Get.back();
                            _showScannerDialog(
                              controller,
                              onScanned: (String code) {
                                controller.codeController.text = code;
                                _showProductDialog(controller, product: product);
                              },
                            );
                          },
                          tooltip: 'Scan Barcode',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Product Name
                    TextField(
                      controller: controller.nameController,
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
                            controller: controller.originalPriceController,
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
                            controller: controller.sellingPriceController,
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
                      controller: controller.quantityController,
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
                      controller: controller.weightController,
                      decoration: InputDecoration(
                        labelText: 'Weight (Optional)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.scale),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Expiry Date
                    Obx(
                      () => InkWell(
                        onTap: () async {
                          final DateTime? date = await showDatePicker(context: context, initialDate: controller.expiryDate.value ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 3650)));
                          if (date != null) {
                            controller.expiryDate.value = date;
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Expiry Date (Optional)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            prefixIcon: const Icon(Icons.calendar_today),
                            suffixIcon: controller.expiryDate.value != null ? IconButton(icon: const Icon(Icons.clear), onPressed: () => controller.expiryDate.value = null) : null,
                          ),
                          child: Text(controller.expiryDate.value != null ? DateFormat('MMM dd, yyyy').format(controller.expiryDate.value!) : 'Select date', style: TextStyle(color: controller.expiryDate.value != null ? Colors.black : Colors.grey)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Product Image
                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text('Product Image (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          if (controller.selectedImage.value != null)
                            Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(controller.selectedImage.value!, fit: BoxFit.contain),
                              ),
                            )
                          else
                            InkWell(
                              onTap: () => controller.showImagePickerOptions(),
                              child: Container(
                                width: double.infinity,
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                                  color: Colors.grey[100],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.image_outlined, size: 48, color: Colors.grey[400]),
                                    const SizedBox(height: 8),
                                    Text('No image selected', style: TextStyle(color: Colors.grey[600])),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          onPressed: () {
                            Get.back();
                            // controller.clearForm();
                          },
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        Obx(
                          () => ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () {
                                    if (isEditing) {
                                      controller.updateProduct(product.id);
                                    } else {
                                      controller.createProduct();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: controller.isLoading.value ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(isEditing ? 'Update' : 'Add Product'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(ProductsController controller, ProductModel product) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: <Widget>[
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteProduct(product.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showScannerDialog(ProductsController controller, {Function(String)? onScanned}) {
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
                            controller.codeController.text = code;
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
}
