import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({required this.child, super.key, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark,
            AppColors.deepTeal,
            AppColors.accentGreen,
          ],
        ),
      ),
      child: Stack(
        children: [
          const _BlurCircle(
            top: -120,
            left: -80,
            size: 240,
            color: Color(0x6640D2BA),
          ),
          const _BlurCircle(
            top: 100,
            right: -100,
            size: 260,
            color: Color(0x5537B8A8),
          ),
          const _BlurCircle(
            bottom: -140,
            left: 30,
            size: 300,
            color: Color(0x5536D1D4),
          ),
          Padding(padding: padding ?? EdgeInsets.zero, child: child),
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  const _BlurCircle({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.color,
  });

  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}
