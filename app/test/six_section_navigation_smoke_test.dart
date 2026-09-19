import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_only/core/data/persistent_library.dart';
import 'package:the_only/main.dart';

void main() {
  testWidgets('all enabled product sections navigate in one shell and library back preserves state', (tester) async {
    SharedPreferences.setMockInitialValues({'the_only.section.optional': true});
    final store = PersistentLibraryStore(await SharedPreferences.getInstance());
    await store.initialize();
    await tester.pumpWidget(TheOnlyApp(store: store));

    expect(find.byKey(const Key('cinema-screen')), findsOneWidget);

    await tester.tap(find.text('Live TV').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('live-tv-screen')), findsOneWidget);

    await tester.tap(find.text('Sources').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sources-screen')), findsOneWidget);

    await tester.tap(find.text('Resolvers').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('resolvers-screen')), findsOneWidget);

    await tester.tap(find.text('Tools / Providers').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('providers-screen')), findsOneWidget);

    await tester.tap(find.text('System Diagnostics').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('system-diagnostics-screen')), findsOneWidget);

    await tester.tap(find.byKey(const Key('library-button')));
    await tester.pumpAndSettle();
    expect(find.text('Library'), findsWidgets);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('system-diagnostics-screen')), findsOneWidget);
  });
}
