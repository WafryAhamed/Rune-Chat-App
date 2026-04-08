import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../widgets/glass_card.dart';
import '../widgets/gradient_background.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About App')),
      body: GradientBackground(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            final packageInfo = snapshot.data;
            return GlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.chat_rounded, size: 70),
                  const SizedBox(height: 12),
                  const Text(
                    'Lanka Chat',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version: ${packageInfo?.version ?? '1.0.0'} (${packageInfo?.buildNumber ?? '1'})',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ශ්‍රී ලංකා දේශනීය ගෝපනීය සන්නිවේදනය, Flutter + ASP.NET Core + SignalR විසින් බලගැන්වනු ලබයි.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
