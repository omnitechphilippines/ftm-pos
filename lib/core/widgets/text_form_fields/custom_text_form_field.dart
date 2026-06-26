import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function()? onEditingComplete;
  final bool obscureText;
  final void Function(String)? onChanged;
  final Widget? prefixIcon;
  final String? hintText;
  final Color? hintColor;
  final double borderRadius;
  final Color enabledBorderColor;
  final Color focusedBorderColor;
  final Color errorBorderColor;
  final Color focusedErrorBorderColor;
  final String? Function(String?)? validator;
  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onEditingComplete,
    this.obscureText = false,
    this.onChanged,
    this.prefixIcon,
    this.hintText,
    this.hintColor,
    this.borderRadius = 4.0,
    this.enabledBorderColor = const Color(0xFF000000),
    this.focusedBorderColor = const Color(0xFF000000),
    this.errorBorderColor = const Color(0xFF000000),
    this.focusedErrorBorderColor = const Color(0xFF000000),
    this.validator,
  });
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      onEditingComplete: onEditingComplete,
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        constraints: const BoxConstraints(maxHeight: 40.0, minHeight: 40.0),
        prefixIcon: prefixIcon,
        hintText: hintText,
        hintStyle: TextStyle(color: hintColor, fontSize: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: enabledBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: focusedBorderColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: errorBorderColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: focusedErrorBorderColor),
        ),
      ),
      validator: validator,
    );
  }
}
