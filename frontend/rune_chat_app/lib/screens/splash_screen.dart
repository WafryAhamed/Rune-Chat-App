import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/route_names.dart';
import '../core/theme/app_colors.dart';
import '../features/auth/auth_controller.dart';
import '../widgets/gradient_background.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    Future<void>.microtask(_bootstrap);
  }

  Future<void> _bootstrap() async {
    await ref.read(authControllerProvider.notifier).bootstrap();
    if (!mounted) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) {
      return;
    }

    final authState = ref.read(authControllerProvider);
    Navigator.pushReplacementNamed(
      context,
      authState.isAuthenticated ? RouteNames.home : RouteNames.onboarding,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentGreen.withValues(alpha: 0.45),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.forum_rounded,
                    size: 54,
                    color: AppColors.accentGreen,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Lanka Chat',
                  style: TextStyle(
                    color: AppColors.softWhite,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
