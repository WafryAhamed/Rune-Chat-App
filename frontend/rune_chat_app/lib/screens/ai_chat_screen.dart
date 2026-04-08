import 'package:flutter/material.dart';

import '../widgets/chat_bubble.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_text_field.dart';
import '../widgets/gradient_background.dart';
import '../models/message_model.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final _messages = <MessageModel>[
    MessageModel(
      id: 'ai-1',
      conversationId: 'ai',
      senderId: 'ai',
      senderName: 'Rune AI',
      content: 'Hi! Ask me anything and I will help with smart replies.',
      type: ChatMessageType.ai,
      sentAt: DateTime.now(),
      isSeen: true,
      isMine: false,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _messages.add(
        MessageModel(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          conversationId: 'ai',
          senderId: 'me',
          senderName: 'You',
          content: text,
          type: ChatMessageType.text,
          sentAt: DateTime.now(),
          isSeen: true,
          isMine: true,
        ),
      );

      _messages.add(
        MessageModel(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          conversationId: 'ai',
          senderId: 'ai',
          senderName: 'Rune AI',
          content: 'Smart reply: "$text" sounds great. Want me to refine it?',
          type: ChatMessageType.ai,
          sentAt: DateTime.now(),
          isSeen: true,
          isMine: false,
        ),
      );
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Chat')),
      body: GradientBackground(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (_, index) =>
                    ChatBubble(message: _messages[index]),
              ),
            ),
            GlassCard(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: GlassTextField(
                      controller: _controller,
                      hintText: 'Message AI...',
                    ),
                  ),
                  IconButton(onPressed: _send, icon: const Icon(Icons.send)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
