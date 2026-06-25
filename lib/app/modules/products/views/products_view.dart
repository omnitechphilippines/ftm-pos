import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_bars/custom_app_bar.dart';
import '../../../../core/widgets/drawers/side_drawer.dart';
import '../../../../core/widgets/loading_indicators/loading_indicator.dart';
import '../../../../core/widgets/search_bars/custom_search_bar.dart';
import '../../../data/models/product_model.dart';
import '../controllers/products_controller.dart';

class ProductsView extends GetView<ProductsController> {
  const ProductsView({super.key});
  @override
  Widget build(BuildContext context) {
    final String currentRoute = Get.currentRoute.isNotEmpty ? Get.currentRoute : (Get.routing.current.isNotEmpty ? Get.routing.current : ModalRoute.of(context)?.settings.name ?? '/');
    return Obx(
      () => Scaffold(
        appBar: CustomAppBar(
          title: 'Products',
          actions: controller.isLoading.value ? null : <Widget>[IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: () => Get.dialog(barrierDismissible: false, const ScannerDialog()).then((_) => controller.disposeScanner()), tooltip: 'Scan Barcode')],
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

                  // Product List
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
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: controller.filteredProducts.length,
                              itemBuilder: (BuildContext context, int index) {
                                final ProductModel product = controller.filteredProducts[index];
                                return _buildProductCard(product);
                              },
                            ),
                          ),
                  ),
                ],
              ),
        floatingActionButton: controller.isLoading.value
            ? null
            : FloatingActionButton.extended(
                onPressed: () => showProductDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final bool isExpiringSoon = product.expiryDate != null && product.expiryDate!.difference(DateTime.now()).inDays <= 30 && product.expiryDate!.isAfter(DateTime.now());

    final bool isExpired = product.expiryDate != null && product.expiryDate!.isBefore(DateTime.now());

    final bool isLowStock = product.quantity <= 5;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: InkWell(
              onTap: () => Get.dialog(Dialog(child: product.image != null ? InteractiveViewer(child: Image.memory(product.image!)) : const Icon(Icons.image_outlined, size: 250))),
              child: Hero(
                tag: 'product-img-${product.id}',
                child: product.image != null ? Image.memory(product.image!, width: 50, height: 50, fit: BoxFit.contain) : const Icon(Icons.image_outlined, size: 50),
              ),
            ),
            title: Text(product.weight!.isNotEmpty ? '${product.name} - ${product.weight}' : product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 4),
                Text('Code: ${product.code}'),
                Text('Price: ₱ ${numberFormatter.format(product.sellingPrice)}'),
                Row(
                  children: <Widget>[
                    Text(
                      'Stock: ${product.quantity}',
                      style: TextStyle(color: isLowStock ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (product.expiryDate != null)
                  Text(
                    'Expires: ${DateFormat('MMM dd, yyyy').format(product.expiryDate!)}',
                    style: TextStyle(color: isExpired ? Colors.red : (isExpiringSoon ? Colors.orange : Colors.white38), fontWeight: (isExpired || isExpiringSoon) ? FontWeight.bold : FontWeight.normal),
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
                  showProductDialog(product: product);
                } else if (value == 'delete') {
                  _showDeleteConfirmation(product);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  void showProductDialog({ProductModel? product, String? code}) {
    controller.isEditingForm.value = product != null;
    controller.codeController.text = code ?? product?.code ?? '';

    Get.dialog(
      barrierDismissible: false,
      Builder(
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              // width: responsive.screenWidth(context) * 0.9,
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
                        Obx(() => Text(controller.isEditingForm.value ? 'Edit Product' : 'Add New Product', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Get.back();
                            controller.clearForm();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Product Code with Scanner
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Obx(
                            () => TextField(
                              controller: controller.codeController,
                              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                              readOnly: controller.isEditingForm.value || code != null ? true : false,
                              decoration: InputDecoration(
                                labelText: 'Product Code *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                prefixIcon: const Icon(Icons.qr_code),
                                errorText: controller.errorMessage.value.isNotEmpty && controller.codeController.text.isEmpty ? 'Required' : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.qr_code_scanner, color: controller.isEditingForm.value || code != null ? null : Colors.blue),
                          onPressed: controller.isEditingForm.value || code != null
                              ? null
                              : () async {
                                  final dynamic product = await Get.dialog(ScannerDialog(onScanned: (String code) => controller.codeController.text = code));
                                  if (product is ProductModel) {
                                    controller.isEditingForm.value = true;
                                    controller.loadProductToForm(product);
                                  } else if (product is String) {
                                    controller.clearForm();
                                    controller.codeController.text = product;
                                    controller.isEditingForm.value = false;
                                  }
                                  controller.disposeScanner();
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
                        errorText: controller.errorMessage.value.isNotEmpty && controller.nameController.text.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Prices Row
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: controller.originalPriceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: <TextInputFormatter>[CurrencyFormatter()],
                            decoration: InputDecoration(
                              labelText: 'Original Price *',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Text('₱', style: TextStyle(fontSize: 24), textAlign: .center),
                              prefixText: ' ₱ ',
                              errorText: controller.errorMessage.value.isNotEmpty && controller.originalPriceController.text.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: controller.sellingPriceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: <TextInputFormatter>[CurrencyFormatter()],
                            decoration: InputDecoration(
                              labelText: 'Selling Price *',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.sell),
                              prefixText: ' ₱ ',
                              errorText: controller.errorMessage.value.isNotEmpty && controller.sellingPriceController.text.isEmpty ? 'Required' : null,
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
                        errorText: controller.errorMessage.value.isNotEmpty && controller.quantityController.text.isEmpty ? 'Required' : null,
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
                          child: Text(controller.expiryDate.value != null ? DateFormat('MMM dd, yyyy').format(controller.expiryDate.value!) : 'Select date', style: TextStyle(color: controller.expiryDate.value != null ? Colors.white : Colors.grey)),
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
                            InkWell(
                              onTap: () => Get.bottomSheet(const ImagePickerOptions()),
                              child: Container(
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
                              ),
                            )
                          else
                            InkWell(
                              onTap: () => Get.bottomSheet(const ImagePickerOptions()),
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
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          TextButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () {
                                    Get.back();
                                    controller.clearForm();
                                  },
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () {
                                    if (controller.isEditingForm.value) {
                                      controller.updateProduct(product!.id);
                                    } else {
                                      controller.createProduct();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: controller.isLoading.value ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(controller.isEditingForm.value ? 'Update Product' : 'Add Product'),
                          ),
                        ],
                      ),
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

  void _showDeleteConfirmation(ProductModel product) {
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
}

class ScannerDialog extends StatelessWidget {
  final Function(String)? onScanned;
  const ScannerDialog({super.key, this.onScanned});

  @override
  Widget build(BuildContext context) {
    final ProductsController controller = Get.find<ProductsController>();
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

                      // Search for existing product
                      final ProductModel? product = controller.searchProductByCode(code);
                      Get.back(result: product ?? code);
                      controller.searchQuery.value = code;
                      controller.searchInputController.text = code;
                      controller.filterProducts();
                      if (onScanned == null) {
                        if (product != null) {
                          controller.loadProductToForm(product);
                          const ProductsView().showProductDialog(product: product);
                        } else {
                          const ProductsView().showProductDialog(code: code);
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
    );
  }
}

/// Show image picker options
class ImagePickerOptions extends StatelessWidget {
  const ImagePickerOptions({super.key});
  @override
  Widget build(BuildContext context) {
    final ProductsController controller = Get.find<ProductsController>();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.isDarkMode ? const Color(0xFF2C2C3D) : Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Material(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Select Image Source', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                controller.pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                controller.pickImageFromGallery();
              },
            ),
            if (controller.selectedImage.value != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Image'),
                onTap: () {
                  Get.back();
                  controller.selectedImage.value = null;
                  Get.snackbar('Success', 'Image removed', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white, borderRadius: 0);
                },
              ),
          ],
        ),
      ),
    );
  }
}
