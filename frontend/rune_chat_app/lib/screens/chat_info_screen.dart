import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/conversation_model.dart';
import '../services/service_providers.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_background.dart';

class ChatInfoScreen extends ConsumerWidget {
  const ChatInfoScreen({required this.conversation, super.key});

  final ConversationModel conversation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatService = ref.watch(chatServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Chat Info')),
      body: GradientBackground(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder(
          future: chatService.getChatInfo(conversation.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final info = snapshot.data;
            if (info == null) {
              return const Center(child: Text('No info available.'));
            }

            return ListView(
              children: [
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Members: ${info.members.length}'),
                      Text('Total messages: ${info.totalMessages}'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Members',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final member in info.members)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.person_outline),
                          title: Text(member),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
