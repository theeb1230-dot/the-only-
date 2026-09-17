import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/main.dart';

void main() {
  testWidgets('renders one unified shell and locally gates sixth section', (tester) async {
    await tester.pumpWidget(const TheOnlyApp());
    expect(find.text('The Only'), findsOneWidget);
    expect(find.text('Cinema'), findsWidgets);
    expect(find.text('Live TV'), findsOneWidget);
    expect(find.text('Sources'), findsOneWidget);
    expect(find.text('Resolvers'), findsOneWidget);
    expect(find.text('Tools / Providers'), findsOneWidget);
    expect(find.text('Optional'), findsNothing);

    await tester.tap(find.byKey(const Key('settings-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('section-optional')), findsOneWidget);
    await tester.tap(find.byKey(const Key('section-optional')));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Optional'), findsOneWidget);
  });
}
