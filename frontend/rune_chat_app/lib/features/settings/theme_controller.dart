import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeControllerProvider = StateNotifierProvider<ThemeController, bool>((
  ref,
) {
  return ThemeController();
});

class ThemeController extends StateNotifier<bool> {
  ThemeController() : super(true);

  void toggleTheme(bool isDark) => state = isDark;
}
