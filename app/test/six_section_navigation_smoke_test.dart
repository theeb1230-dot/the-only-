import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_only/core/data/persistent_library.dart';
import 'package:the_only/main.dart';

Future<void> tapDestination(WidgetTester tester, String label) async {
  final navFinder = find.byType(NavigationBar);
  expect(navFinder, findsOneWidget);
  final nav = tester.widget<NavigationBar>(navFinder);
  final index = nav.destinations.indexWhere((destination) => destination.label == label);
  expect(index, greaterThanOrEqualTo(0), reason: 'Missing navigation destination: $label');
  nav.onDestinationSelected?.call(index);
  await tester.pump();
}

void main() {
  testWidgets('all enabled product sections navigate in one shell and library back preserves state', (tester) async {
    SharedPreferences.setMockInitialValues({'the_only.section.optional': true});
    final store = PersistentLibraryStore(await SharedPreferences.getInstance());
    await store.initialize();
    await tester.pumpWidget(TheOnlyApp(store: store));
    await tester.pump();

    expect(find.byKey(const Key('cinema-screen')), findsOneWidget);
    await tapDestination(tester, 'Live TV');
    expect(find.byKey(const Key('live-tv-screen')), findsOneWidget);
    await tapDestination(tester, 'Sources');
    expect(find.byKey(const Key('sources-screen')), findsOneWidget);
    await tapDestination(tester, 'Resolvers');
    expect(find.byKey(const Key('resolvers-screen')), findsOneWidget);
    await tapDestination(tester, 'Tools / Providers');
    expect(find.byKey(const Key('providers-list')), findsOneWidget);
    expect(find.byKey(const Key('provider-legal-demo')), findsOneWidget);
    await tapDestination(tester, 'System Diagnostics');
    expect(find.byKey(const Key('system-diagnostics-screen')), findsOneWidget);

    await tester.tap(find.byKey(const Key('library-button')));
    await tester.pumpAndSettle();
    expect(find.text('Library'), findsWidgets);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('system-diagnostics-screen')), findsOneWidget);
  });
}
