import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/route_names.dart';
import '../features/auth/auth_controller.dart';
import '../widgets/avatar_status.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_background.dart';
import '../widgets/neon_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not authenticated')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: GradientBackground(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            GlassCard(
              child: Column(
                children: [
                  AvatarStatus(
                    name: user.username,
                    avatarUrl: user.avatarUrl,
                    isOnline: user.isOnline,
                    radius: 48,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user.email,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.bio ?? 'ප්‍රൺනක් බේඹ ංගනි. මෙරී අුඹට ඁක එකගා දභ්ම අකරන්න.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  NeonButton(
                    label: 'Edit Profile',
                    onPressed: () =>
                        Navigator.pushNamed(context, RouteNames.editProfile),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            NeonButton(
              label: 'ධ්‍රඹය ගේවන්න',
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).logout();
                if (!context.mounted) {
                  return;
                }

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteNames.login,
                  (_) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
