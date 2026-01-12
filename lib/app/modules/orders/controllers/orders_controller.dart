import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/product_model.dart';

class OrdersController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  // Scanner controller
  MobileScannerController? scannerController;

  // Observable lists and states
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxString errorMessage = ''.obs;

  final RxInt currentPage = 1.obs;
  final RxBool isLoading = false.obs;
  final int totalPages = 5;

  final RxInt cart = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
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

      final PostgrestList response = await supabase.from('products_master').select().order('updated_at', ascending: false);
      products.value = response.map((Map<String, dynamic> json) => ProductModel.fromJson(json)).toList();
      // filteredProducts.value = products;
    } catch (e) {
      errorMessage.value = 'Failed to fetch products: $e';
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 5));
    } finally {
      isLoading.value = false;
    }
  }

  // Search product by barcode
  Future<ProductModel?> searchProductByCode(String code) async {
    try {
      final PostgrestMap? response = await supabase.from('products_master').select().eq('code', code).maybeSingle();

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

  Future<void> navigateToPage(int page) async {
    isLoading.value = true;
    await Future<dynamic>.delayed(const Duration(milliseconds: 0));
    currentPage
      ..value = page.clamp(1, totalPages)
      ..refresh();
    isLoading.value = false;
  }
}
