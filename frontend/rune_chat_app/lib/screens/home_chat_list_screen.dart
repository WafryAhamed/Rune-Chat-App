import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/constants/route_names.dart';
import '../features/auth/auth_controller.dart';
import '../features/chat/chat_controller.dart';
import '../models/conversation_model.dart';
import '../widgets/avatar_status.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_background.dart';

class HomeChatListScreen extends ConsumerStatefulWidget {
  const HomeChatListScreen({super.key});

  @override
  ConsumerState<HomeChatListScreen> createState() => _HomeChatListScreenState();
}

class _HomeChatListScreenState extends ConsumerState<HomeChatListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref.read(chatControllerProvider.notifier).loadConversations(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final chatState = ref.watch(chatControllerProvider);
    final query = _searchController.text.trim().toLowerCase();

    final items = chatState.conversations.where((conversation) {
      if (query.isEmpty) {
        return true;
      }

      return conversation.displayName.toLowerCase().contains(query) ||
          (conversation.lastMessage?.toLowerCase().contains(query) ?? false);
    }).toList();

    return Scaffold(
      body: GradientBackground(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: SafeArea(
          child: Column(
            children: [
              GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${authState.user?.username ?? 'User'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 23,
                            ),
                          ),
                          const Text(
                            'Your Lanka chat world is live.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, RouteNames.globalSearch),
                      icon: const Icon(Icons.search),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        RouteNames.notifications,
                      ),
                      icon: const Icon(Icons.notifications_none_rounded),
                    ),
                    IconButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, RouteNames.settings),
                      icon: const Icon(Icons.settings_outlined),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'සන්නිවේදන ලංගී...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: chatState.isLoadingConversations
                    ? const Center(child: CircularProgressIndicator())
                    : items.isEmpty
                    ? const EmptyStateView(
                        title: 'වැ අගය සන්නිවේදන ගෝන්ම නැතී',
                        subtitle: '+ සුැඳ ලංගී නරන සන්නිවේදන ඇරඹු කරන්න.',
                        icon: Icons.chat_bubble_outline,
                      )
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, index) =>
                            _ConversationTile(conversation: items[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, RouteNames.newChat),
        child: const Icon(Icons.add_comment_outlined),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black.withValues(alpha: 0.2),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
            label: 'AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, RouteNames.aiChat);
          } else if (index == 2) {
            Navigator.pushNamed(context, RouteNames.profile);
          }
        },
      ),
    );
  }
}

class _ConversationTile extends ConsumerWidget {
  const _ConversationTile({required this.conversation});

  final ConversationModel conversation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      onTap: () {
        ref
            .read(chatControllerProvider.notifier)
            .openConversation(conversation.id);
        Navigator.pushNamed(context, RouteNames.chat, arguments: conversation);
      },
      child: Row(
        children: [
          AvatarStatus(
            name: conversation.displayName,
            avatarUrl: conversation.avatarUrl,
            isOnline: conversation.isOnline,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  conversation.lastMessage ?? 'No messages yet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                conversation.lastMessageAt != null
                    ? DateFormat.Hm().format(
                        conversation.lastMessageAt!.toLocal(),
                      )
                    : '--:--',
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
              if (conversation.unreadCount > 0) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Text(
                    conversation.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
