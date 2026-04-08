import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/service_providers.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_background.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final service = ref.watch(notificationServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: GradientBackground(
        padding: const EdgeInsets.all(14),
        child: FutureBuilder(
          future: service.getNotifications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = snapshot.data ?? const [];
            if (items.isEmpty) {
              return const Center(child: Text('No notifications available.'));
            }

            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final item = items[index];
                return GlassCard(
                  child: ListTile(
                    onTap: () async {
                      await service.markAsRead(item.id);
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    leading: Icon(
                      item.isRead
                          ? Icons.notifications_none
                          : Icons.notifications_active,
                    ),
                    title: Text(item.title),
                    subtitle: Text(item.body),
                    trailing: Text(
                      '${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
