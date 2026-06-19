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
  final TextEditingController searchQueryController = TextEditingController();
  // final TextEditingController quantityTextController = TextEditingController(text: '0');
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;
  final RxList<ProductModel> orderedProducts = <ProductModel>[].obs;
  OrderModel? cartItems;

  final RxBool isLoading = false.obs;

  final RxInt cart = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();

    debounce(searchQuery, (_) => filterProducts(), time: const Duration(milliseconds: 300));
  }

  /// Initialize barcode scanner
  void initializeScanner() => scannerController = MobileScannerController(detectionSpeed: DetectionSpeed.normal, facing: CameraFacing.back);

  /// Dispose barcode scanner
  void disposeScanner() {
    scannerController?.dispose();
    scannerController = null;
  }

  /// Fetch all products from Supabase
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

  /// Search product by barcode
  ProductModel? searchProductByCode(int code) => products.firstWhere((ProductModel product) => product.code == code);

  /// Filter products based on search query
  void filterProducts() {
    if (searchQuery.value.isEmpty) {
      filteredProducts.value = .from(products);
    } else {
      filteredProducts.value = products.where((ProductModel product) => product.name.toLowerCase().contains(searchQuery.value.toLowerCase()) || product.code == int.tryParse(searchQuery.value)).toList();
      // filteredProducts.value = products.where((ProductModel product) => product.name.toLowerCase().contains(searchQuery.value.toLowerCase()) || product.code.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
    }
  }

  void showOrderConfirmationDialog() {
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
              Get.back();
              _confirmOrder();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _confirmOrder() async {
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

  void incrementCart(ProductModel product, int orderedProductsCount) {
    cart.value++;
    orderedProductsCount++;
    if (orderedProductsCount == 1) {
      orderedProducts.add(product.copyWith(quantity: 1));
    } else {
      orderedProducts[orderedProducts.indexWhere((ProductModel p) => p.code == product.code)] = product.copyWith(quantity: orderedProductsCount);
    }
  }

  void decrementCart(ProductModel product, int orderedProductsCount) {
    cart.value--;
    orderedProductsCount--;
    if (orderedProductsCount == 0) {
      orderedProducts.removeAt(orderedProducts.indexWhere((ProductModel p) => p.code == product.code));
    } else {
      orderedProducts[orderedProducts.indexWhere((ProductModel p) => p.code == product.code)] = product.copyWith(quantity: orderedProductsCount);
    }
  }

  ProductModel? orderedProduct(ProductModel product) => orderedProducts.firstWhereOrNull((ProductModel p) => p.code == product.code);

  void updateProductQuantity(ProductModel product, int quantity) {
    if (orderedProduct(product) != null) {
      orderedProducts[orderedProducts.indexWhere((ProductModel p) => p.code == product.code)] = product.copyWith(quantity: quantity);
    } else if (quantity != 0) {
      orderedProducts.add(product.copyWith(quantity: quantity));
    }
    cart.value = orderedProducts.fold(0, (int sum, ProductModel product) => sum + product.quantity);
  }

  TextEditingController getQuantityTextController(int quantity) => TextEditingController(text: quantity.toString());

  @override
  void onClose() {
    searchQueryController.dispose();
    // quantityTextController.dispose();
    super.onClose();
  }
}
