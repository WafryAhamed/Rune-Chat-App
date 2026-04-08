import 'package:flutter/material.dart';

import '../core/constants/route_names.dart';
import '../core/theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_background.dart';
import '../widgets/neon_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
        child: Column(
          children: [
            const Spacer(),
            GlassCard(
              child: Column(
                children: [
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 60,
                      color: AppColors.accentGreen,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Connect with Sri Lankans instantly',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.softWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Real-time private messaging with smooth neon glass vibes and friends from Sri Lanka.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.84),
                      fontSize: 15,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 30),
                  NeonButton(
                    label: 'Get Started',
                    onPressed: () =>
                        Navigator.pushNamed(context, RouteNames.login),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.g_mobiledata_rounded),
                          label: const Text('Google'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.apple),
                          label: const Text('Apple'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
