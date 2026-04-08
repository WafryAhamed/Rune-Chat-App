import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/service_providers.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_text_field.dart';
import '../widgets/gradient_background.dart';
import '../widgets/neon_button.dart';

class PrivacySecurityScreen extends ConsumerStatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  ConsumerState<PrivacySecurityScreen> createState() =>
      _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends ConsumerState<PrivacySecurityScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid passwords.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref
          .read(userServiceProvider)
          .changePassword(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
          );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully.')),
      );
      _currentPasswordController.clear();
      _newPasswordController.clear();
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password update failed.')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: GradientBackground(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Change Password',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 12),
                  GlassTextField(
                    controller: _currentPasswordController,
                    hintText: 'Current password',
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 10),
                  GlassTextField(
                    controller: _newPasswordController,
                    hintText: 'New password',
                    obscureText: true,
                    prefixIcon: Icons.password,
                  ),
                  const SizedBox(height: 14),
                  NeonButton(
                    label: _isLoading ? 'Updating...' : 'Update Password',
                    onPressed: _isLoading ? null : _changePassword,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Blocked users'),
                subtitle: const Text('Manage blocked accounts'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final blocked = await ref
                      .read(userServiceProvider)
                      .blockedUsers();
                  if (!context.mounted) {
                    return;
                  }

                  showDialog<void>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Blocked users'),
                      content: SizedBox(
                        width: 320,
                        child: blocked.isEmpty
                            ? const Text('No blocked users.')
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: blocked.length,
                                itemBuilder: (_, index) {
                                  final user = blocked[index];
                                  return ListTile(
                                    title: Text(user.username),
                                    subtitle: Text(user.email),
                                    trailing: TextButton(
                                      onPressed: () async {
                                        await ref
                                            .read(userServiceProvider)
                                            .unblockUser(user.id);
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: const Text('Unblock'),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: ListTile(
                leading: const Icon(Icons.devices_outlined),
                title: const Text('Session management'),
                subtitle: const Text('View and revoke active sessions'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSessions(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSessions(BuildContext context) async {
    final response = await ref
        .read(apiClientProvider)
        .dio
        .get<List<dynamic>>('/api/auth/sessions');
    if (!context.mounted) {
      return;
    }

    final sessions = response.data ?? const [];

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Active sessions'),
        content: SizedBox(
          width: 360,
          child: sessions.isEmpty
              ? const Text('No sessions found.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: sessions.length,
                  itemBuilder: (_, index) {
                    final map = sessions[index] as Map<String, dynamic>;
                    return ListTile(
                      title: Text('Session ${index + 1}'),
                      subtitle: Text(
                        'Expires: ${map['expiresAt'] ?? '-'}\nActive: ${map['isActive'] == true ? 'Yes' : 'No'}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final id = map['id']?.toString();
                          if (id == null) {
                            return;
                          }

                          await ref
                              .read(apiClientProvider)
                              .dio
                              .delete<void>('/api/auth/sessions/$id');
                          if (context.mounted) {
                            Navigator.pop(context);
                            _showSessions(context);
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
