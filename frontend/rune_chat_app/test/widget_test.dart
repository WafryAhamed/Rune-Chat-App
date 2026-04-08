//

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rune_chat_app/main.dart';

void main() {
  testWidgets('renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RuneChatApp()));

    expect(find.text('Rune Chat'), findsOneWidget);
  });
}
