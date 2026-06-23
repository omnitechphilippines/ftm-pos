import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/data/models/product_model.dart';
import '../../../app/modules/orders/controllers/orders_controller.dart';

class OrderCard extends StatelessWidget {
  final ProductModel product;
  const OrderCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final OrdersController controller = Get.find<OrdersController>();
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4D4F5B),
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[BoxShadow(color: Colors.grey.withValues(alpha: 0.05), spreadRadius: 2, blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(color: const Color(0xFF4D4F5B), borderRadius: BorderRadius.circular(16)),
                child: Stack(
                  children: <Widget>[
                    Center(child: Image.memory(product.image ?? Uint8List(0))),
                    const Positioned(top: 0, right: 0, child: Icon(Icons.more_vert, size: 16, color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '₱ ${product.sellingPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                        child: IconButton(icon: const Icon(Icons.remove, size: 18), onPressed: () => controller.cart.value--, tooltip: 'Deduct', splashRadius: 18),
                      ),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                        child: IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () => controller.cart.value++, tooltip: 'Add', splashRadius: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
