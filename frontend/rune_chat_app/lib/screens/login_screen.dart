import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/route_names.dart';
import '../core/utils/validators.dart';
import '../features/auth/auth_controller.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_text_field.dart';
import '../widgets/gradient_background.dart';
import '../widgets/neon_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref
        .read(authControllerProvider.notifier)
        .login(
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
                const SizedBox(height: 24),
                const Text(
                  'Welcome back',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34),
                ),
                const SizedBox(height: 26),
                GlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GlassTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.alternate_email,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 14),
                        GlassTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          obscureText: _obscure,
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                          validator: Validators.password,
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              RouteNames.forgotPassword,
                            ),
                            child: const Text('Forgot password?'),
                          ),
                        ),
                        if (authState.error != null) ...[
                          Text(
                            authState.error!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                          const SizedBox(height: 10),
                        ],
                        NeonButton(
                          label: authState.isLoading
                              ? 'Signing in...'
                              : 'Sign In',
                          onPressed: authState.isLoading ? null : _submit,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 8,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.g_mobiledata_rounded,
                                  size: 20,
                                ),
                                label: const Text('Google'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 8,
                                  ),
                                ),
                                icon: const Icon(Icons.apple, size: 20),
                                label: const Text('Apple'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, RouteNames.register),
                  child: const Text('ගිණුමක් නැතිද? එකතු කරන්න'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
