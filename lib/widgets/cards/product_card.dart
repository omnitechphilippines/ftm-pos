import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/modules/orders/controllers/orders_controller.dart';
import '../../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();
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
                    Center(child: Image.memory(product.image!)),
                    const Positioned(top: 0, right: 0, child: Icon(Icons.more_vert, size: 16, color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Text(
            //   product.category.toUpperCase(),
            //   style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.0),
            // ),
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
                  children: <Widget>[
                    Container(
                      decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                      child: IconButton(icon: const Icon(Icons.remove), onPressed: () => controller.cart.value--, tooltip: 'Deduct'),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                      child: IconButton(icon: const Icon(Icons.add), onPressed: () => controller.cart.value++, tooltip: 'Add'),
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
