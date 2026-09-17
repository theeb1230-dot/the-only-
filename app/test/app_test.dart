import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/main.dart';

void main() {
  testWidgets('renders one unified shell and hides optional section by default', (tester) async {
    await tester.pumpWidget(const TheOnlyApp());
    expect(find.text('The Only'), findsOneWidget);
    expect(find.text('Cinema'), findsWidgets);
    expect(find.text('Live TV'), findsOneWidget);
    expect(find.text('Sources'), findsOneWidget);
    expect(find.text('Resolvers'), findsOneWidget);
    expect(find.text('Tools'), findsOneWidget);
    expect(find.text('Optional'), findsNothing);
  });
}
