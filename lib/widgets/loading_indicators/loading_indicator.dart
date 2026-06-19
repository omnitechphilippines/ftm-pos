import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? label;
  const LoadingIndicator({super.key, this.label});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const CircularProgressIndicator(),
          if (label != null) ...<Widget>[const SizedBox(height: 8), Text(label!, style: const TextStyle(fontWeight: FontWeight.bold))],
        ],
      ),
    );
  }
}
