
import 'dart:async';

import 'package:flutter/material.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  final PageController _pageController = PageController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_pageController.page == 2) {
        _pageController.animateToPage(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      } else {
        _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: PageView(
        controller: _pageController,
        children: <Widget>[
          Container(
            color: Colors.red,
            child: const Center(child: Text('Product 1')),
          ),
          Container(
            color: Colors.green,
            child: const Center(child: Text('Product 2')),
          ),
          Container(
            color: Colors.blue,
            child: const Center(child: Text('Product 3')),
          ),
        ],
      ),
    );
  }
}
