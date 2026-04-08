import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_colors.dart';
import '../models/message_model.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({required this.message, super.key});

  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;
    final bubbleColor = isMine ? AppColors.userBubble : AppColors.aiBubble;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 290),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(24),
              topRight: const Radius.circular(24),
              bottomLeft: Radius.circular(isMine ? 24 : 8),
              bottomRight: Radius.circular(isMine ? 8 : 24),
            ),
          ),
          child: Column(
            crossAxisAlignment: isMine
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                message.content,
                style: TextStyle(
                  color: isMine ? AppColors.primaryDark : AppColors.softWhite,
                  fontSize: 15,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                DateFormat.Hm().format(message.sentAt.toLocal()),
                style: TextStyle(
                  color: isMine
                      ? AppColors.primaryDark.withValues(alpha: 0.7)
                      : AppColors.softWhite.withValues(alpha: 0.65),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
