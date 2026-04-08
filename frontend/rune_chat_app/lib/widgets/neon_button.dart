import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class NeonButton extends StatelessWidget {
  const NeonButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.isExpanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: AppColors.accentGreen,
        foregroundColor: AppColors.primaryDark,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    );

    final glow = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentGreen.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: button,
    );

    if (isExpanded) {
      return SizedBox(width: double.infinity, child: glow);
    }

    return glow;
  }
}
