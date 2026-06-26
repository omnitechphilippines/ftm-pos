import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../data/services/auth_service.dart';

class ResetPasswordController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final GlobalKey<FormState> formKeyReset = GlobalKey<FormState>();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode userNameFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final RxBool showPassword = false.obs;
  final Rx<PackageInfo?> packageInfo = Rx<PackageInfo?>(null);
  final RxBool isPasswordEmpty = true.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchPackageInfo();
  }

  @override
  void onReady() {
    super.onReady();
    userNameFocus.requestFocus();
  }

  Future<void> _fetchPackageInfo() async => packageInfo.value = await PackageInfo.fromPlatform();

  void get toggleShowPassword => showPassword.toggle();

  void get handleSubmit => _authService.resetPassword(userNameController.text.trim(), passwordController.text.trim());

  @override
  void onClose() {
    userNameController.dispose();
    passwordController.dispose();
    userNameFocus.dispose();
    passwordFocus.dispose();
    super.onClose();
  }
}
