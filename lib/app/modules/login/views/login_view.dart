import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../services/responsive_service.dart';
import '../../../../themes/app_theme.dart';
import '../../../../widgets/text_form_fields/custom_text_form_field.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

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
                    SizedBox(width: 450, child: LoginCard(controller: controller)),
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

class LoginCard extends StatelessWidget {
  const LoginCard({super.key, required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    final ResponsiveService responsive = Get.find<ResponsiveService>();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        child: Form(
          key: controller.formKeyLogin,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 16),
              const Text('Login Credentials', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: controller.emailController,
                focusNode: controller.emailFocus,
                onEditingComplete: () => controller.passwordFocus.requestFocus(),
                prefixIcon: const Icon(Icons.person),
                hintText: 'Email',
                hintColor: const Color(0xFF8D8D90),
                enabledBorderColor: const Color(0xFF636571),
                focusedBorderColor: responsive.isDarkMode(context) ? Colors.white70 : Colors.black,
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
              Obx(
                () => CustomTextFormField(
                  controller: controller.passwordController,
                  focusNode: controller.passwordFocus,
                  onEditingComplete: () => controller.formKeyLogin.currentState!.validate() ? controller.handleSubmit : null,
                  obscureText: !controller.showPassword.value,
                  onChanged: (String value) => controller.isPasswordEmpty.value = value.isEmpty,
                  prefixIcon: const Icon(Icons.lock),
                  hintText: 'Password',
                  hintColor: const Color(0xFF8D8D90),
                  enabledBorderColor: const Color(0xFF636571),
                  focusedBorderColor: responsive.isDarkMode(context) ? Colors.white70 : Colors.black,
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
                onPressed: () => controller.formKeyLogin.currentState!.validate() ? controller.handleSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.info,
                  minimumSize: const Size(100, 58),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Center(
                  child: Text(
                    'Sign in',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
