import 'package:flutter/material.dart';

import '../widgets/gradient_background.dart';
import '../widgets/loading_shimmer.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: SizedBox(
            width: 240,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                LoadingShimmer(height: 56),
                SizedBox(height: 12),
                LoadingShimmer(height: 16),
                SizedBox(height: 6),
                LoadingShimmer(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
