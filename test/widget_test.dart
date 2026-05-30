import 'package:flutter_test/flutter_test.dart';

import 'package:nail_timer/main.dart';

void main() {
  testWidgets('shows wizard step one on launch', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      NailTimerApp(initial: AppStateSnapshot.empty()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Manicure Masterpiece'), findsOneWidget);
    expect(find.text('Set the foundation'), findsOneWidget);
    expect(find.text('All the same'), findsOneWidget);
    expect(find.text('Per nail'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
