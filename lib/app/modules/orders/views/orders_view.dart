import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../widgets/app_bars/custom_app_bar.dart';
import '../../../../widgets/drawers/side_drawer.dart';
import '../controllers/orders_controller.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});
  @override
  Widget build(BuildContext context) {
    final String currentRoute = Get.currentRoute.isNotEmpty ? Get.currentRoute : (Get.routing.current.isNotEmpty ? Get.routing.current : ModalRoute.of(context)?.settings.name ?? '/');
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Orders',
        actions: <Widget>[IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () {}, tooltip: 'Cart')],
      ),
      drawer: SideDrawer(currentRoute: currentRoute),
      body: const Center(child: Text('OrdersView is working', style: TextStyle(fontSize: 20))),
    );
  }
}
