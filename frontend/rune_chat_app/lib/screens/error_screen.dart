import 'package:flutter/material.dart';

import '../core/constants/route_names.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/gradient_background.dart';
import '../widgets/neon_button.dart';

class ErrorScreenArgs {
  const ErrorScreenArgs({
    required this.message,
    this.retryRoute = RouteNames.home,
  });

  final String message;
  final String retryRoute;
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, this.args});

  final ErrorScreenArgs? args;

  @override
  Widget build(BuildContext context) {
    final data =
        args ??
        const ErrorScreenArgs(
          message: 'Something went wrong. Please try again.',
        );

    return Scaffold(
      body: GradientBackground(
        child: EmptyStateView(
          icon: Icons.error_outline,
          title: 'Oops',
          subtitle: data.message,
          action: NeonButton(
            label: 'Retry',
            onPressed: () =>
                Navigator.pushReplacementNamed(context, data.retryRoute),
          ),
        ),
      ),
    );
  }
}
