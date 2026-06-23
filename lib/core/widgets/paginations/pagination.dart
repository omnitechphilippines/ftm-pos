  // Widget _buildLoadingIndicator() => const Center(
  //   child: Column(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: <Widget>[
  //       CircularProgressIndicator(),
  //       SizedBox(height: 16),
  //       Text('Loading products...', style: TextStyle(fontWeight: FontWeight.bold)),
  //     ],
  //   ),
  // );

  // Widget _pagination() {
  //   return Obx(
  //     () => Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //       color: const Color(0xFF2A2D3E),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: <Widget>[
  //           ElevatedButton(
  //             onPressed: controller.currentPage.value > 1 ? () => controller.navigateToPage(controller.currentPage.value - 1) : null,
  //             style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(8), backgroundColor: Colors.blue[100], foregroundColor: Colors.blue[800]),
  //             child: const Icon(Icons.chevron_left),
  //           ),
  //           const SizedBox(width: 16),
  //           Text('Page ${controller.currentPage} of ${controller.totalPages}', style: const TextStyle(fontWeight: FontWeight.w500)),
  //           const SizedBox(width: 16),
  //           ElevatedButton(
  //             onPressed: controller.currentPage.value < controller.totalPages ? () => controller.navigateToPage(controller.currentPage.value + 1) : null,
  //             style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(8), backgroundColor: Colors.blue[100], foregroundColor: Colors.blue[800]),
  //             child: const Icon(Icons.chevron_right),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
