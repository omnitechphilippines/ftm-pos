import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../models/auth_model.dart';
import '../../../../services/auth_service.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final GlobalKey<FormState> formKeyLogin = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final RxBool showPassword = false.obs;
  final Rx<PackageInfo?> packageInfo = Rx<PackageInfo?>(null);
  final RxBool isPasswordEmpty = true.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchPackageInfo();

    passwordController.addListener(() {
      isPasswordEmpty.value = passwordController.text.isEmpty;
    });

    ever<AuthModel>(_authService.state, (AuthModel next) {
      if (next.status == AuthStatus.loading) {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      } else {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
      }

      if (next.status == AuthStatus.success) {
        Get.offAllNamed(Routes.DASHBOARD);
      }

      if (next.status == AuthStatus.failure) {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            title: const Text('Login Failed'),
            content: Text(next.error!.contains('fetch') ? 'Server connection error!' : next.error ?? 'Incorrect user name or password'),
            actions: <Widget>[TextButton(onPressed: () => Get.back(), child: const Text('OK'))],
          ),
        );
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    emailFocus.requestFocus();
  }

  Future<void> _fetchPackageInfo() async {
    packageInfo.value = await PackageInfo.fromPlatform();
  }

  void toggleShowPassword() {
    showPassword.toggle();
  }

  void handleSubmit() {
    _authService.login(emailController.text.trim(), passwordController.text.trim());
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.onClose();
  }
}
