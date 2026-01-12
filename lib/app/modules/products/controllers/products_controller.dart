import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../models/product_model.dart';

class ProductsController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  final ImagePicker _imagePicker = ImagePicker();

  // Observable lists and states
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString errorMessage = ''.obs;

  // Form controllers
  final TextEditingController codeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController sellingPriceController = TextEditingController();
  final TextEditingController originalPriceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final Rx<DateTime?> expiryDate = Rx<DateTime?>(null);

  // Image handling
  final Rx<Uint8List?> selectedImage = Rx<Uint8List?>(null);

  // Scanner controller
  MobileScannerController? scannerController;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();

    // Listen to search query changes
    debounce(searchQuery, (_) => filterProducts());
  }

  @override
  void onClose() {
    codeController.dispose();
    nameController.dispose();
    sellingPriceController.dispose();
    originalPriceController.dispose();
    quantityController.dispose();
    weightController.dispose();
    scannerController?.dispose();
    super.onClose();
  }

  // Fetch all products from Supabase
  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final PostgrestList response = await supabase.from('products_master').select().order('updated_at', ascending: false);
      products.value = response.map((Map<String, dynamic> json) => ProductModel.fromJson(json)).toList();
      filteredProducts.value = products;
    } catch (e) {
      errorMessage.value = 'Failed to fetch products: $e';
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 5));
    } finally {
      isLoading.value = false;
    }
  }

  // Filter products based on search query
  void filterProducts() {
    if (searchQuery.value.isEmpty) {
      filteredProducts.value = products;
    } else {
      filteredProducts.value = products.where((ProductModel product) => product.name.toLowerCase().contains(searchQuery.value.toLowerCase()) || product.code.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
    }
  }

  // Pick image from camera
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera, maxWidth: 800, maxHeight: 800, imageQuality: 85);

      if (image != null) {
        final Uint8List imageBytes = await image.readAsBytes();
        selectedImage.value = imageBytes;
        Get.snackbar('Success', 'Image captured successfully', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture image: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);

      if (result != null && result.files.isNotEmpty) {
        final Uint8List? imageBytes = result.files.single.bytes;
        if (imageBytes != null) {
          selectedImage.value = imageBytes;
          Get.snackbar('Success', 'Image selected successfully', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // Show image picker options
  void showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Image Source', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                pickImageFromGallery();
              },
            ),
            if (selectedImage.value != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Image'),
                onTap: () {
                  Get.back();
                  selectedImage.value = null;
                  Get.snackbar('Success', 'Image removed', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
                },
              ),
          ],
        ),
      ),
    );
  }

  // Create a new product
  Future<void> createProduct() async {
    if (!_validateForm()) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final ProductModel product = ProductModel(
        id: const Uuid().v4(),
        code: codeController.text.trim(),
        name: nameController.text.trim(),
        originalPrice: double.parse(originalPriceController.text),
        sellingPrice: double.parse(sellingPriceController.text),
        quantity: int.parse(quantityController.text),
        weight: weightController.text.trim(),
        expiryDate: expiryDate.value,
        image: selectedImage.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await supabase.from('products_master').insert(product.toJson());

      products.insert(0, product);
      filterProducts();

      clearForm();
      Get.back();

      Get.snackbar('Success', 'Product added successfully', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      errorMessage.value = 'Failed to create product: $e';
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Update an existing product
  Future<void> updateProduct(String productId) async {
    if (!_validateForm()) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final ProductModel updatedProduct = ProductModel(
        id: productId,
        code: codeController.text.trim(),
        name: nameController.text.trim(),
        sellingPrice: double.parse(sellingPriceController.text),
        originalPrice: double.parse(originalPriceController.text),
        quantity: int.parse(quantityController.text),
        weight: weightController.text.isNotEmpty ? weightController.text.trim() : '',
        expiryDate: expiryDate.value,
        image: selectedImage.value,
        createdAt: products.firstWhere((ProductModel p) => p.id == productId).createdAt,
        updatedAt: DateTime.now(),
      );

      await supabase.from('products_master').update(updatedProduct.toJson()).eq('id', productId);

      final int index = products.indexWhere((ProductModel p) => p.id == productId);
      if (index != -1) {
        products[index] = updatedProduct;
        filterProducts();
      }

      clearForm();
      Get.back();

      Get.snackbar('Success', 'Product updated successfully', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      errorMessage.value = 'Failed to update product: $e';
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Delete a product
  Future<void> deleteProduct(String productId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await supabase.from('products_master').delete().eq('id', productId);

      products.removeWhere((ProductModel p) => p.id == productId);
      filterProducts();

      Get.snackbar('Success', 'Product deleted successfully', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      errorMessage.value = 'Failed to delete product: $e';
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
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
    codeController.text = product.code;
    nameController.text = product.name;
    sellingPriceController.text = product.sellingPrice.toString();
    originalPriceController.text = product.originalPrice.toString();
    quantityController.text = product.quantity.toString();
    weightController.text = product.weight.toString();
    expiryDate.value = product.expiryDate;
    selectedImage.value = product.image;
  }

  // Clear form
  void clearForm() {
    codeController.clear();
    nameController.clear();
    sellingPriceController.clear();
    originalPriceController.clear();
    quantityController.clear();
    weightController.clear();
    expiryDate.value = null;
    selectedImage.value = null;
  }

  // Validate form
  bool _validateForm() {
    if (codeController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Product code is required', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    if (nameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Product name is required', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    if (sellingPriceController.text.trim().isEmpty || double.tryParse(sellingPriceController.text) == null) {
      Get.snackbar('Error', 'Valid selling price is required', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    if (originalPriceController.text.trim().isEmpty || double.tryParse(originalPriceController.text) == null) {
      Get.snackbar('Error', 'Valid original price is required', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    if (quantityController.text.trim().isEmpty || int.tryParse(quantityController.text) == null) {
      Get.snackbar('Error', 'Valid quantity is required', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    return true;
  }

  // Initialize scanner
  void initializeScanner() => scannerController = MobileScannerController(detectionSpeed: DetectionSpeed.normal, facing: CameraFacing.back);

  // Dispose scanner
  void disposeScanner() {
    scannerController?.dispose();
    scannerController = null;
  }
}
