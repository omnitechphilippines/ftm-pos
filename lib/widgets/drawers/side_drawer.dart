import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_pages.dart';
import '../../services/auth_service.dart';

class SideDrawer extends StatelessWidget {
  final String currentRoute;

  const SideDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF2A2D3E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: <Color>[Color(0xFF2A2D3E), Color(0xFF2A2D3E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: SizedBox(width: 32, child: Image.asset('assets/images/logo.png')),
          ),
          HoverListTile(icon: Icons.dashboard_outlined, title: 'Dashboard', route: Routes.DASHBOARD, currentRoute: currentRoute),
          HoverListTile(icon: Icons.insert_chart_outlined, title: 'Orders', route: Routes.ORDERS, currentRoute: currentRoute),
          HoverListTile(icon: Icons.pie_chart_outline_outlined, title: 'Products', route: Routes.PRODUCTS, currentRoute: currentRoute),
          HoverListTile(icon: Icons.report, title: 'Reports', route: Routes.REPORTS, currentRoute: currentRoute),
        ],
      ),
    );
  }
}

class HoverListTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String route;
  final String currentRoute;

  const HoverListTile({super.key, required this.icon, required this.title, required this.route, required this.currentRoute});

  @override
  State<HoverListTile> createState() => _HoverListTileState();
}

class _HoverListTileState extends State<HoverListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.currentRoute == widget.route;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(color: isActive ? const Color(0xFF4D4F5B) : (_isHovered ? const Color(0xFF4D4F5B) : Colors.transparent)),
        child: ListTile(
          leading: Icon(widget.icon, size: 26, color: isActive ? Colors.white : (_isHovered ? Colors.white : const Color(0xFF8B8D96))),
          title: Text(widget.title, style: TextStyle(color: isActive ? Colors.white : (_isHovered ? Colors.white : const Color(0xFF8B8D96)))),
          onTap: () async {
            if (widget.route == Routes.LOGIN) {
              Get.find<AuthService>().logout();
            } else if (!isActive) {
              Get.toNamed(widget.route);
            }
          },
        ),
      ),
    );
  }
}
