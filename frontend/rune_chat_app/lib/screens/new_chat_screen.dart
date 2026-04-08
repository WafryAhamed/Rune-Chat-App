import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/route_names.dart';
import '../features/chat/chat_controller.dart';
import '../services/service_providers.dart';
import '../widgets/avatar_status.dart';
import '../widgets/gradient_background.dart';

class NewChatScreen extends ConsumerStatefulWidget {
  const NewChatScreen({super.key});

  @override
  ConsumerState<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends ConsumerState<NewChatScreen> {
  final _searchController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userService = ref.watch(userServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('New Chat')),
      body: GradientBackground(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder(
                future: userService.searchUsers(_searchController.text.trim()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      _loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data ?? const [];
                  if (users.isEmpty) {
                    return const Center(child: Text('No users found.'));
                  }

                  return ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (context, index) =>
                        const Divider(color: Colors.white24),
                    itemBuilder: (_, index) {
                      final user = users[index];
                      return ListTile(
                        leading: AvatarStatus(
                          name: user.username,
                          avatarUrl: user.avatarUrl,
                          isOnline: user.isOnline,
                        ),
                        title: Text(user.username),
                        subtitle: Text(user.email),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          setState(() => _loading = true);
                          final conversation = await ref
                              .read(chatControllerProvider.notifier)
                              .startConversation(user.id);
                          setState(() => _loading = false);

                          if (conversation == null || !context.mounted) {
                            return;
                          }

                          Navigator.pushNamed(
                            context,
                            RouteNames.chat,
                            arguments: conversation,
                          );
                        },
                      );
                    },
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
