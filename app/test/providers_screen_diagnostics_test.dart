import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/providers/legal_demo_provider.dart';
import 'package:the_only/core/providers/provider.dart';
import 'package:the_only/core/providers/provider_health_store.dart';
import 'package:the_only/core/providers/provider_registry.dart';
import 'package:the_only/features/tools/providers_controller.dart';
import 'package:the_only/features/tools/providers_screen.dart';

class FailingProvider implements MediaProvider {
  @override String get id => 'failing';
  @override Future<List<MediaItem>> search(String query) async => throw StateError('offline');
  @override Future<ProviderResult> sourcesFor(MediaItem item) async => throw StateError('offline');
}

void main() {
  testWidgets('current provider probe failure is surfaced after historical success', (tester) async {
    final health = ProviderHealthStore();
    final controller = ProvidersController(ProviderRegistry([FailingProvider()]), health, const []);
    controller.recordProbe('failing', success: true, latencyMs: 1);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: ProvidersScreen(controller: controller))));
    await tester.tap(find.byKey(const Key('provider-probe-failing')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('providers-error')), findsOneWidget);
    expect(find.text('Provider health probe failed safely'), findsOneWidget);
  });
  testWidgets('Tools / Providers exposes registered provider diagnostics', (tester) async {
    final controller = ProvidersController(
      ProviderRegistry([LegalDemoProvider()]),
      ProviderHealthStore(),
      const [],
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: ProvidersScreen(controller: controller))),
    );

    expect(find.byKey(const Key('providers-list')), findsOneWidget);
    expect(find.byKey(const Key('provider-legal-demo')), findsOneWidget);
    expect(find.textContaining('Health 0.00'), findsOneWidget);

    await tester.tap(find.byKey(const Key('provider-probe-legal-demo')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Health 1.00'), findsOneWidget);
    expect(find.byKey(const Key('providers-error')), findsNothing);

    controller.recordProbe('legal-demo', success: false, latencyMs: 1);
    controller.recordProbe('legal-demo', success: false, latencyMs: 1);
    await tester.tap(find.byKey(const Key('provider-probe-legal-demo')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('providers-error')), findsNothing);
  });
}
