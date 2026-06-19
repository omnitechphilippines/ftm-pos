import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final dynamic controller;
  const CustomSearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SearchBar(
        hintText: 'Search by name or code...',
        leading: const Icon(Icons.search),
        controller: controller.searchQueryController,
        onChanged: (String value) => controller.searchQuery.value = value,
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
        elevation: WidgetStateProperty.all(0),
      ),
    );
  }
}
