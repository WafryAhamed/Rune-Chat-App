import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class AvatarStatus extends StatelessWidget {
  const AvatarStatus({
    required this.name,
    required this.isOnline,
    super.key,
    this.avatarUrl,
    this.radius = 22,
  });

  final String name;
  final bool isOnline;
  final String? avatarUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: Colors.white.withValues(alpha: 0.12),
          backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
              ? NetworkImage(avatarUrl!)
              : null,
          child: avatarUrl == null || avatarUrl!.isEmpty
              ? Text(
                  name.isEmpty ? '?' : name[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.softWhite,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            height: 12,
            width: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? AppColors.accentGreen : Colors.grey,
              border: Border.all(color: AppColors.primaryDark, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
