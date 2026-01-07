import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/auth_service.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? image;
  final List<Widget>? actions;

  const CustomAppBar({super.key, required this.title, this.image, this.actions});

  @override
  Widget build(BuildContext context) {
    final List<Widget> defaultActions = <Widget>[IconButton(icon: const Icon(Icons.logout), onPressed: _logout, tooltip: 'Logout')];
    final List<Widget> allActions = actions != null ? <Widget>[...actions!, ...defaultActions] : defaultActions;
    return AppBar(
      title: Row(
        children: <Widget>[
          if (image != null) ...<Widget>[SizedBox(width: 32, child: Image.asset(image!)), const SizedBox(width: 8)],
          // if (image != null) SizedBox(width: 32, child: Image.asset(image!)),
          // if (image != null) const SizedBox(width: 8),
          Text(title),
        ],
      ),
      // actions: <Widget>[
      //   IconButton(icon: const Icon(Icons.search), onPressed: () {}),
      //   IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () {}),
      //   // IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
      // ],
      actions: allActions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _logout() async {
    await Get.find<AuthService>().logout();
  }
}
