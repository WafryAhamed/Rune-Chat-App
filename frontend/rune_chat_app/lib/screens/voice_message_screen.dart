import 'package:flutter/material.dart';

import '../widgets/glass_card.dart';
import '../widgets/glowing_mic_button.dart';
import '../widgets/gradient_background.dart';
import '../widgets/neon_button.dart';

class VoiceMessageScreen extends StatefulWidget {
  const VoiceMessageScreen({super.key});

  @override
  State<VoiceMessageScreen> createState() => _VoiceMessageScreenState();
}

class _VoiceMessageScreenState extends State<VoiceMessageScreen> {
  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Message')),
      body: GradientBackground(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isRecording ? 'Recording...' : 'Tap mic to record',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                GlowingMicButton(
                  onTap: () => setState(() => _isRecording = !_isRecording),
                ),
                const SizedBox(height: 18),
                NeonButton(
                  label: 'Send Voice',
                  onPressed: _isRecording
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Voice message sent.'),
                            ),
                          );
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
