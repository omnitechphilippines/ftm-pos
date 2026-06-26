import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../data/services/auth_service.dart';

class SignUpController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final GlobalKey<FormState> formKeySignUp = GlobalKey<FormState>();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController password2Controller = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final FocusNode userNameFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode password2Focus = FocusNode();
  final FocusNode firstNameFocus = FocusNode();
  final FocusNode lastNameFocus = FocusNode();
  final RxBool showPassword = false.obs;
  final RxBool showPassword2 = false.obs;
  final Rx<PackageInfo?> packageInfo = Rx<PackageInfo?>(null);
  final RxBool isPasswordEmpty = true.obs;
  final RxBool isPassword2Empty = true.obs;

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
  void get toggleShowPassword2 => showPassword2.toggle();

  void get handleSubmit => _authService.signUp(userNameController.text.trim(), passwordController.text.trim(), firstNameController.text.trim(), lastNameController.text.trim());

  @override
  void onClose() {
    userNameController.dispose();
    passwordController.dispose();
    password2Controller.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    userNameFocus.dispose();
    passwordFocus.dispose();
    password2Focus.dispose();
    firstNameFocus.dispose();
    lastNameFocus.dispose();
    super.onClose();
  }
}
