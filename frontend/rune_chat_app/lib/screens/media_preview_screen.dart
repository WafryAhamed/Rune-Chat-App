import 'package:flutter/material.dart';

import '../widgets/glass_card.dart';
import '../widgets/gradient_background.dart';

class MediaPreviewScreen extends StatelessWidget {
  const MediaPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media Preview')),
      body: GradientBackground(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 100,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Preview image/video before sending.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
