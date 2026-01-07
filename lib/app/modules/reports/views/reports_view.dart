import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../widgets/app_bars/custom_app_bar.dart';
import '../../../../widgets/drawers/side_drawer.dart';
import '../controllers/reports_controller.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});
  @override
  Widget build(BuildContext context) {
    final String currentRoute = Get.currentRoute.isNotEmpty ? Get.currentRoute : (Get.routing.current.isNotEmpty ? Get.routing.current : ModalRoute.of(context)?.settings.name ?? '/');
    return Scaffold(
      appBar: const CustomAppBar(title: 'Reports'),
      drawer: SideDrawer(currentRoute: currentRoute),
      body: const Center(child: Text('ReportsView is working', style: TextStyle(fontSize: 20))),
    );
  }
}
