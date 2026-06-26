import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/text_form_fields/custom_text_form_field.dart';
import '../../../routes/app_pages.dart';
import '../controllers/sign_up_controller.dart';

class SignUpView extends GetView<SignUpController> {
  const SignUpView({super.key});
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
                  children: <Widget>[
                    SizedBox(width: 150, child: Image.asset('assets/images/logo.png')),
                    const Text('Point of Sale', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(width: 450, child: SignUpCard(controller: controller)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text('I have already an account', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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

class SignUpCard extends StatelessWidget {
  const SignUpCard({super.key, required this.controller});

  final SignUpController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        child: Form(
          key: controller.formKeySignUp,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 16),
              const Text('Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              // Username field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Username', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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
                ],
              ),
              const SizedBox(height: 12),
              // Password field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Obx(
                    () => CustomTextFormField(
                      controller: controller.passwordController,
                      focusNode: controller.passwordFocus,
                      onEditingComplete: () => controller.password2Focus.requestFocus(),
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
                ],
              ),
              const SizedBox(height: 12),
              // Password Again field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Password Again', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Obx(
                    () => CustomTextFormField(
                      controller: controller.password2Controller,
                      focusNode: controller.password2Focus,
                      onEditingComplete: () => controller.firstNameFocus.requestFocus(),
                      obscureText: !controller.showPassword2.value,
                      onChanged: (String value) => controller.isPasswordEmpty.value = value.isEmpty,
                      prefixIcon: const Icon(Icons.lock),
                      hintText: 'Enter your password again',
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
                ],
              ),
              const SizedBox(height: 12),
              // First Name field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('First Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    controller: controller.firstNameController,
                    focusNode: controller.firstNameFocus,
                    onEditingComplete: () => controller.lastNameFocus.requestFocus(),
                    prefixIcon: const Icon(Icons.person_3),
                    hintText: 'Enter your first name',
                    hintColor: const Color(0xFF8D8D90),
                    enabledBorderColor: const Color(0xFF636571),
                    focusedBorderColor: context.isDarkMode ? Colors.white70 : Colors.black,
                    errorBorderColor: Colors.red.shade900,
                    focusedErrorBorderColor: Colors.redAccent,
                    validator: (String? value) => value == null || value.isEmpty
                        ? '❌ First Name is required'
                        : value.length < 3
                        ? '❌ First Name characters is not less than 3'
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Last Name field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Last Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    controller: controller.lastNameController,
                    focusNode: controller.lastNameFocus,
                    onEditingComplete: () => controller.formKeySignUp.currentState!.validate() ? controller.handleSubmit : null,
                    prefixIcon: const Icon(Icons.people),
                    hintText: 'Enter your last name',
                    hintColor: const Color(0xFF8D8D90),
                    enabledBorderColor: const Color(0xFF636571),
                    focusedBorderColor: context.isDarkMode ? Colors.white70 : Colors.black,
                    errorBorderColor: Colors.red.shade900,
                    focusedErrorBorderColor: Colors.redAccent,
                    validator: (String? value) => value == null || value.isEmpty
                        ? '❌ Last Name is required'
                        : value.length < 3
                        ? '❌ Last Name characters is not less than 3'
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Sign Up button
              ElevatedButton(
                onPressed: () => controller.formKeySignUp.currentState!.validate() ? controller.handleSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.info,
                  minimumSize: const Size(100, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Center(
                  child: Text(
                    'Sign Up',
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
