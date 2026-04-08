import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth_controller.dart';
import '../services/service_providers.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_text_field.dart';
import '../widgets/gradient_background.dart';
import '../widgets/neon_button.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  late final TextEditingController _avatarController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    _usernameController = TextEditingController(text: user?.username ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _avatarController = TextEditingController(text: user?.avatarUrl ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _saving = true);

    final updated = await ref
        .read(userServiceProvider)
        .updateProfile(
          username: _usernameController.text.trim(),
          bio: _bioController.text.trim(),
          avatarUrl: _avatarController.text.trim().isEmpty
              ? null
              : _avatarController.text.trim(),
        );

    ref.read(authControllerProvider.notifier).updateUser(updated);

    if (!mounted) {
      return;
    }

    setState(() => _saving = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: GradientBackground(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: GlassCard(
            child: Column(
              children: [
                GlassTextField(
                  controller: _usernameController,
                  hintText: 'Username',
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 12),
                GlassTextField(
                  controller: _bioController,
                  hintText: 'Bio',
                  prefixIcon: Icons.edit_note,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                GlassTextField(
                  controller: _avatarController,
                  hintText: 'Avatar URL',
                  prefixIcon: Icons.image_outlined,
                ),
                const SizedBox(height: 18),
                NeonButton(
                  label: _saving ? 'Saving...' : 'Save Changes',
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
