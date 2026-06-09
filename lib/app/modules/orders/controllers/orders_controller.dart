import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/order_model.dart';
import '../../../../models/product_model.dart';

class OrdersController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Scanner controller
  MobileScannerController? scannerController;

  // Observable lists and states
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;
  final RxList<ProductModel> orderedProducts = <ProductModel>[].obs;
  OrderModel? cartItems;

  final RxInt currentPage = 1.obs;
  final RxBool isLoading = false.obs;
  // final int totalPages = 5;

  final RxInt cart = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();

    // Listen to search query changes
    debounce(searchQuery, (_) => filterProducts());
  }

  // Initialize scanner
  void initializeScanner() => scannerController = MobileScannerController(detectionSpeed: DetectionSpeed.normal, facing: CameraFacing.back);

  // Dispose scanner
  void disposeScanner() {
    scannerController?.dispose();
    scannerController = null;
  }

  // Fetch all products from Supabase
  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final PostgrestList response = await _supabase.from('products_master').select().order('updated_at', ascending: false);
      products.value = response.map((Map<String, dynamic> json) => ProductModel.fromJson(json)).toList();
      filteredProducts.value = products;
    } catch (e) {
      errorMessage.value = 'Failed to fetch products: $e';
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 5), borderRadius: 0);
    } finally {
      isLoading.value = false;
    }
  }

  // Search product by barcode
  Future<ProductModel?> searchProductByCode(String code) async {
    try {
      final PostgrestMap? response = await _supabase.from('products_master').select().eq('code', code).maybeSingle();

      if (response != null) {
        return ProductModel.fromJson(response);
      }
      return null;
    } catch (e) {
      errorMessage.value = 'Failed to search product: $e';
      return null;
    }
  }

  // Load product data into form for editing
  void loadProductToForm(ProductModel product) {
    // codeController.text = product.code;
    // nameController.text = product.name;
    // sellingPriceController.text = product.sellingPrice.toString();
    // originalPriceController.text = product.originalPrice.toString();
    // quantityController.text = product.quantity.toString();
    // weightController.text = product.weight.toString();
    // expiryDate.value = product.expiryDate;
    // selectedImage.value = product.image;
  }

  // Filter products based on search query
  void filterProducts() {
    if (searchQuery.value.isEmpty) {
      filteredProducts.value = products;
    } else {
      filteredProducts.value = products.where((ProductModel product) => product.name.toLowerCase().contains(searchQuery.value.toLowerCase()) || product.code.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
    }
  }

  // Future<void> navigateToPage(int page) async {
  //   isLoading.value = true;
  //   await Future<dynamic>.delayed(const Duration(milliseconds: 0));
  //   currentPage
  //     ..value = page.clamp(1, totalPages)
  //     ..refresh();
  //   isLoading.value = false;
  // }

  // Future<void> testOrdersTableConnection() async {
  //   try {
  //     isLoading.value = true;
  //     final PostgrestList response = await supabase.from('orders').select();
  //     Get.snackbar('Success', 'Successfully connected to orders table. Rows: ${response.length}', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
  //     print('Orders table response: $response');
  //   } catch (e) {
  //     Get.snackbar('Error', 'Failed to connect to orders table: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 5));
  //     print('Error connecting to orders table: $e');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  void showConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: <Widget>[
            Icon(Icons.help_outline, color: Colors.orange),
            SizedBox(width: 10),
            Text('Confirm Order', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Are you sure you want to finalize this order?', style: TextStyle(fontSize: 14)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Closes the dialog first
              confirmOrder(); // Executes the actual database transaction
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void confirmOrder() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      cartItems = cartItems!.copyWith(orderAt: DateTime.now(), createdAt: DateTime.now(), updatedAt: DateTime.now());
      await _supabase.rpc('confirm_order_and_deduct_stock', params: <String, dynamic>{'p_codes': cartItems!.code, 'p_quantities': cartItems!.quantity, 'p_order_data': cartItems!.toJson()});
      Get.back();
      Get.snackbar('Success', 'Order confirmed and stock successfully adjusted!', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white, borderRadius: 0);
      orderedProducts.clear();
      cartItems = null;
      filterProducts();
      cart.value = 0;
    } catch (e) {
      errorMessage.value = 'Transaction failed: $e';
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 5));
    } finally {
      isLoading.value = false;
    }
  }
}
