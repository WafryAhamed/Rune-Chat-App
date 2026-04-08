import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/route_names.dart';
import '../features/auth/auth_controller.dart';
import '../features/settings/theme_controller.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_background.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: GradientBackground(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            GlassCard(
              child: SwitchListTile(
                title: const Text('අධ්න අධ්න'),
                subtitle: const Text('අධුවනීය ලග෕ රේවත ගේවණය'),
                value: isDark,
                onChanged: (value) => ref
                    .read(themeControllerProvider.notifier)
                    .toggleTheme(value),
              ),
            ),
            const SizedBox(height: 10),
            GlassCard(
              child: SwitchListTile(
                title: const Text('ංගනණය'),
                subtitle: const Text('සමවැද අලැර්තූ පැගැඹ්න'),
                value: true,
                onChanged: (_) {},
              ),
            ),
            const SizedBox(height: 10),
            GlassCard(
              child: ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('ප්‍රൺනය අපෑරෑකලම අපෑරෑකලම'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, RouteNames.privacy),
              ),
            ),
            const SizedBox(height: 10),
            GlassCard(
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About App'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, RouteNames.about),
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
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
            ),
          ],
        ),
      ),
    );
  }
}
