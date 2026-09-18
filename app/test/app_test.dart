import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_only/core/data/persistent_library.dart';
import 'package:the_only/main.dart';

void main() {
  testWidgets('renders unified shell with local sixth-section gate', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = PersistentLibraryStore(await SharedPreferences.getInstance());
    await store.initialize();

    await tester.pumpWidget(TheOnlyApp(store: store));
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
