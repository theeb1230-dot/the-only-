import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/providers/legal_demo_provider.dart';
import 'package:the_only/core/providers/provider_health_store.dart';
import 'package:the_only/core/providers/provider_registry.dart';
import 'package:the_only/features/tools/providers_controller.dart';
import 'package:the_only/features/tools/providers_screen.dart';

void main() {
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
