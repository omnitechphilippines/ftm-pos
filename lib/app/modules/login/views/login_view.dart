import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212332),
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
                    const Text(
                      'Point of Sale',
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 450,
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        color: const Color(0xFF2A2D3E),
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          child: Form(
                            key: controller.formKeyLogin,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const SizedBox(height: 16),
                                const Text(
                                  'Login Credentials',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: controller.emailController,
                                  focusNode: controller.emailFocus,
                                  onEditingComplete: () => controller.passwordFocus.requestFocus(),
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.person, color: Color(0xFFC0C0C5)),
                                    hintText: 'Email',
                                    hintStyle: const TextStyle(color: Color(0xFF8D8D90)),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(3),
                                      borderSide: const BorderSide(color: Color(0xFF636571)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(3),
                                      borderSide: BorderSide(color: Colors.grey.shade400),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(3),
                                      borderSide: BorderSide(color: Colors.red.shade900),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(3),
                                      borderSide: const BorderSide(color: Colors.redAccent),
                                    ),
                                  ),
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return '❌ Field is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                Obx(
                                  () => TextFormField(
                                    controller: controller.passwordController,
                                    focusNode: controller.passwordFocus,
                                    onEditingComplete: () => controller.formKeyLogin.currentState!.validate() ? controller.handleSubmit() : null,
                                    obscureText: !controller.showPassword.value,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.lock, color: Color(0xFFC0C0C5)),
                                      suffixIcon: Opacity(
                                        opacity: controller.isPasswordEmpty.value ? 0.0 : 1.0,
                                        child: IconButton(
                                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                          icon: Icon(controller.showPassword.value ? Icons.visibility : Icons.visibility_off, color: const Color(0xFFC0C0C5)),
                                          onPressed: controller.isPasswordEmpty.value ? null : controller.toggleShowPassword,
                                        ),
                                      ),
                                      hintText: 'Password',
                                      hintStyle: const TextStyle(color: Color(0xFF8D8D90)),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(3),
                                        borderSide: const BorderSide(color: Color(0xFF636571)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(3),
                                        borderSide: BorderSide(color: Colors.grey.shade400),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(3),
                                        borderSide: BorderSide(color: Colors.red.shade900),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(3),
                                        borderSide: const BorderSide(color: Colors.redAccent),
                                      ),
                                    ),
                                    validator: (String? value) => value == null || value.isEmpty
                                        ? '❌ Password is required'
                                        : value.length < 5
                                        ? '❌ Password characters is not less than 5'
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () => controller.formKeyLogin.currentState!.validate() ? controller.handleSubmit() : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2196F3),
                                    minimumSize: const Size(100, 58),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF2A2D3E),
        padding: const EdgeInsets.all(8.0),
        child: Obx(
          () => Text(
            controller.packageInfo.value == null ? '' : 'V${controller.packageInfo.value?.version}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF8D8D90)),
          ),
        ),
      ),
    );
  }
}
