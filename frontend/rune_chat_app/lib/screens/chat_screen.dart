import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/route_names.dart';
import '../core/theme/app_colors.dart';
import '../features/chat/chat_controller.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_text_field.dart';
import '../widgets/glowing_mic_button.dart';
import '../widgets/gradient_background.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({required this.conversation, super.key});

  final ConversationModel conversation;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _typingDebounce;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      await ref
          .read(chatControllerProvider.notifier)
          .openConversation(widget.conversation.id);
      _jumpToBottom();
    });
  }

  @override
  void dispose() {
    _typingDebounce?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    ref
        .read(chatControllerProvider.notifier)
        .leaveConversation(widget.conversation.id);
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }

    _messageController.clear();
    await ref
        .read(chatControllerProvider.notifier)
        .sendMessage(
          conversationId: widget.conversation.id,
          content: text,
          type: ChatMessageType.text,
        );

    await ref
        .read(chatControllerProvider.notifier)
        .sendTyping(conversationId: widget.conversation.id, isTyping: false);

    _jumpToBottom();
  }

  void _handleTyping(String value) {
    ref
        .read(chatControllerProvider.notifier)
        .sendTyping(
          conversationId: widget.conversation.id,
          isTyping: value.trim().isNotEmpty,
        );

    _typingDebounce?.cancel();
    _typingDebounce = Timer(const Duration(milliseconds: 1200), () {
      ref
          .read(chatControllerProvider.notifier)
          .sendTyping(conversationId: widget.conversation.id, isTyping: false);
    });
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);
    final messages =
        chatState.messagesByConversation[widget.conversation.id] ?? const [];
    final isTyping = chatState.typingConversations.contains(
      widget.conversation.id,
    );

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.conversation.displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                Text(
                                  isTyping
                                      ? 'Typing...'
                                      : (widget.conversation.isOnline
                                            ? 'Online'
                                            : 'Offline'),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              RouteNames.chatInfo,
                              arguments: widget.conversation,
                            ),
                            icon: const Icon(Icons.info_outline),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: messages.length,
                  itemBuilder: (_, index) {
                    final message = messages[index];
                    if (!message.isMine && !message.isSeen) {
                      ref
                          .read(chatControllerProvider.notifier)
                          .markSeen(message.id);
                    }

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 260),
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, (1 - value) * 10),
                          child: child,
                        ),
                      ),
                      child: ChatBubble(message: message),
                    );
                  },
                ),
              ),
              if (isTyping)
                const Padding(
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Typing…',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: GlassTextField(
                          controller: _messageController,
                          hintText: 'Type your message',
                          prefixIcon: Icons.emoji_emotions_outlined,
                          onChanged: _handleTyping,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GlowingMicButton(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Voice recorder opening...'),
                          ),
                        );
                        Navigator.pushNamed(context, RouteNames.voiceMessage);
                      },
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton.small(
                      backgroundColor: AppColors.accentGreen,
                      foregroundColor: AppColors.primaryDark,
                      onPressed: _sendMessage,
                      child: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
