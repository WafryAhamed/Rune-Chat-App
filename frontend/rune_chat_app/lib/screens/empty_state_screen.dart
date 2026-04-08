import 'package:flutter/material.dart';

import '../widgets/empty_state_view.dart';
import '../widgets/gradient_background.dart';

class EmptyStateScreen extends StatelessWidget {
  const EmptyStateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: const EmptyStateView(
          icon: Icons.chat_bubble_outline,
          title: 'No chats yet',
          subtitle: 'Start a conversation and your messages will appear here.',
        ),
      ),
    );
  }
}
