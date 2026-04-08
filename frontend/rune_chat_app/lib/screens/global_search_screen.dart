import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/service_providers.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_background.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatService = ref.watch(chatServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Global Search')),
      body: GradientBackground(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search chats/users/messages',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder(
                future: _searchController.text.trim().isEmpty
                    ? Future.value(const [])
                    : chatService.searchConversations(
                        _searchController.text.trim(),
                      ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final results = snapshot.data ?? const [];
                  if (results.isEmpty) {
                    return const Center(child: Text('No matching results.'));
                  }

                  return ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final item = results[index];
                      return GlassCard(
                        child: ListTile(
                          leading: const Icon(Icons.chat_bubble_outline),
                          title: Text(item.displayName),
                          subtitle: Text(
                            item.lastMessage ?? 'No message preview',
                          ),
                        ),
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
