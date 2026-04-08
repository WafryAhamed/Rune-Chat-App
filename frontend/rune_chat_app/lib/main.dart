import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/route_names.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/theme_controller.dart';

void main() {
  runApp(const ProviderScope(child: RuneChatApp()));
}

class RuneChatApp extends ConsumerWidget {
  const RuneChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeControllerProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(isDark),
      initialRoute: RouteNames.splash,
      onGenerateRoute: AppRouter.generate,
    );
  }
}
