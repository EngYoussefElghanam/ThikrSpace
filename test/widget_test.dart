import 'package:flutter_test/flutter_test.dart';
import 'package:thikrspace_beta/core/app/app_shell.dart';

void main() {
  testWidgets('boot route initializes then navigates to dev home',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AppShell());

    expect(find.text('Booting...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Dev Home'), findsOneWidget);
    expect(find.text('Developer home ready'), findsOneWidget);
  });
}
