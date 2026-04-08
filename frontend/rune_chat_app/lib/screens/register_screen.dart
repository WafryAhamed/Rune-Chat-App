import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/route_names.dart';
import '../core/utils/validators.dart';
import '../features/auth/auth_controller.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_text_field.dart';
import '../widgets/gradient_background.dart';
import '../widgets/neon_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref
        .read(authControllerProvider.notifier)
        .register(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, RouteNames.home, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: GradientBackground(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Create account',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                ),
                const SizedBox(height: 24),
                GlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        GlassTextField(
                          controller: _usernameController,
                          hintText: 'Username',
                          prefixIcon: Icons.person_outline,
                          validator: (value) =>
                              Validators.requiredText(value, field: 'Username'),
                        ),
                        const SizedBox(height: 12),
                        GlassTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 12),
                        GlassTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          obscureText: _obscurePassword,
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                          validator: Validators.password,
                        ),
                        const SizedBox(height: 12),
                        GlassTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm Password',
                          obscureText: _obscureConfirm,
                          prefixIcon: Icons.lock_reset,
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                          validator: (value) => Validators.confirmPassword(
                            value,
                            _passwordController.text,
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (authState.error != null) ...[
                          Text(
                            authState.error!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                          const SizedBox(height: 10),
                        ],
                        NeonButton(
                          label: authState.isLoading
                              ? 'Creating...'
                              : 'Create Account',
                          onPressed: authState.isLoading ? null : _submit,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, RouteNames.login),
                  child: const Text('Already have an account? Sign in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
