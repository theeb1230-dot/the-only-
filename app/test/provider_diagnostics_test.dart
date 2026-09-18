import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/providers/legal_demo_provider.dart';
import 'package:the_only/core/providers/provider_health_store.dart';
import 'package:the_only/core/providers/provider_registry.dart';
import 'package:the_only/features/tools/providers_controller.dart';

void main() {
  test('provider diagnostic probe records a bounded real provider result', () async {
    final registry = ProviderRegistry([LegalDemoProvider()]);
    final controller = ProvidersController(
      registry,
      ProviderHealthStore(),
      const [],
    );

    final health = await controller.probe('legal-demo');

    expect(health.successes, 1);
    expect(health.failures, 0);
    expect(health.averageLatencyMs, greaterThanOrEqualTo(0));
  });

  test('provider diagnostic probe fails closed for unknown provider', () async {
    final controller = ProvidersController(
      ProviderRegistry([LegalDemoProvider()]),
      ProviderHealthStore(),
      const [],
    );

    await expectLater(controller.probe('missing'), throwsArgumentError);
  });
}
