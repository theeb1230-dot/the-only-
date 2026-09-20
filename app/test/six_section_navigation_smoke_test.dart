import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_only/core/data/persistent_library.dart';
import 'package:the_only/main.dart';

Future<void> tapDestination(WidgetTester tester, String label) async {
  final destination = find.text(label).last;
  expect(destination, findsOneWidget, reason: 'Missing navigation destination: $label');
  await tester.tap(destination);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'all enabled product sections navigate in one shell and library back preserves state',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'the_only.section.enabled.optional': true,
      });
      final store = PersistentLibraryStore(
        await SharedPreferences.getInstance(),
      );
      await store.initialize();
      await tester.pumpWidget(TheOnlyApp(store: store));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('cinema-screen')), findsOneWidget);
      await tapDestination(tester, 'البث المباشر');
      expect(find.byKey(const Key('live-tv-screen')), findsOneWidget);
      await tapDestination(tester, 'المصادر');
      expect(find.byKey(const Key('sources-screen')), findsOneWidget);
      await tapDestination(tester, 'المحللات');
      expect(find.byKey(const Key('resolvers-screen')), findsOneWidget);
      await tapDestination(tester, 'المزودون');
      expect(find.byKey(const Key('providers-list')), findsOneWidget);
      expect(find.byKey(const Key('provider-legal-demo')), findsOneWidget);
      await tapDestination(tester, 'تشخيص النظام');
      expect(find.byKey(const Key('system-diagnostics-screen')), findsOneWidget);

      final libraryButton = tester.widget<IconButton>(
        find.byKey(const Key('library-button')),
      );
      libraryButton.onPressed?.call();
      await tester.pumpAndSettle();
      expect(find.text('المكتبة'), findsWidgets);
      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('system-diagnostics-screen')), findsOneWidget);
    },
  );
}
