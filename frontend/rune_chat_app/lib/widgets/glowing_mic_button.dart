import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class GlowingMicButton extends StatelessWidget {
  const GlowingMicButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 62,
        width: 62,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppColors.accentGreen, Color(0xFF32BFA8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentGreen.withValues(alpha: 0.55),
              blurRadius: 22,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.mic, color: AppColors.primaryDark, size: 30),
      ),
    );
  }
}
