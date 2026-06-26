import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/text_form_fields/custom_text_form_field.dart';
import '../../../routes/app_pages.dart';
import '../controllers/reset_password_controller.dart';

class ResetPasswordView extends GetView<ResetPasswordController> {
  const ResetPasswordView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 15,
                  children: <Widget>[
                    SizedBox(
                      width: 350,
                      child: Container(margin: const EdgeInsets.all(16), child: Image.asset('assets/images/logo.png')),
                    ),
                    const Text('Point of Sale', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    SizedBox(width: 450, child: ResetPasswordCard(controller: controller)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text('Back to', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => Get.offNamed(Routes.LOGIN),
                          child: const Text('Sign In', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: .min,
        children: <Widget>[
          const Divider(),
          Obx(() => Text(controller.packageInfo.value == null ? '' : 'V${controller.packageInfo.value?.version}+${controller.packageInfo.value?.buildNumber}', textAlign: TextAlign.center)),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class ResetPasswordCard extends StatelessWidget {
  const ResetPasswordCard({super.key, required this.controller});

  final ResetPasswordController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        child: Form(
          key: controller.formKeyReset,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 16),
              const Text('Reset Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Row(
                children: <Widget>[Text('Username', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))],
              ),
              const SizedBox(height: 8),
              CustomTextFormField(
                controller: controller.userNameController,
                focusNode: controller.userNameFocus,
                onEditingComplete: () => controller.passwordFocus.requestFocus(),
                prefixIcon: const Icon(Icons.person),
                hintText: 'Enter your username',
                hintColor: const Color(0xFF8D8D90),
                enabledBorderColor: const Color(0xFF636571),
                focusedBorderColor: context.isDarkMode ? Colors.white70 : Colors.black,
                errorBorderColor: Colors.red.shade900,
                focusedErrorBorderColor: Colors.redAccent,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return '❌ Field is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              const Row(
                children: <Widget>[Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))],
              ),
              const SizedBox(height: 8),
              Obx(
                () => CustomTextFormField(
                  controller: controller.passwordController,
                  focusNode: controller.passwordFocus,
                  onEditingComplete: () => controller.formKeyReset.currentState!.validate() ? controller.handleSubmit : null,
                  obscureText: !controller.showPassword.value,
                  onChanged: (String value) => controller.isPasswordEmpty.value = value.isEmpty,
                  prefixIcon: const Icon(Icons.lock),
                  hintText: 'Enter your password',
                  hintColor: const Color(0xFF8D8D90),
                  enabledBorderColor: const Color(0xFF636571),
                  focusedBorderColor: context.isDarkMode ? Colors.white70 : Colors.black,
                  errorBorderColor: Colors.red.shade900,
                  focusedErrorBorderColor: Colors.redAccent,
                  validator: (String? value) => value == null || value.isEmpty
                      ? '❌ Password is required'
                      : value.length < 5
                      ? '❌ Password characters is not less than 5'
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => controller.formKeyReset.currentState!.validate() ? controller.handleSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.info,
                  minimumSize: const Size(100, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Center(
                  child: Text(
                    'Reset Password',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
