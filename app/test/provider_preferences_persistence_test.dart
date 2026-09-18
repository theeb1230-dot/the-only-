import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_only/core/providers/legal_demo_provider.dart';
import 'package:the_only/core/providers/provider_health_store.dart';
import 'package:the_only/core/providers/provider_registry.dart';
import 'package:the_only/features/tools/providers_controller.dart';

void main() {
  test('provider enablement and priority survive controller recreation', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final registry = ProviderRegistry([LegalDemoProvider()]);
    final first = ProvidersController(registry, ProviderHealthStore(), const [], preferencesStore: preferences);

    first.setEnabled('legal-demo', false);
    first.setPriority('legal-demo', 7);
    await Future<void>.delayed(Duration.zero);

    final restored = ProvidersController(registry, ProviderHealthStore(), const [], preferencesStore: preferences);
    final state = restored.states().single;
    expect(state.enabled, isFalse);
    expect(state.priority, 7);
  });

  test('unknown provider preference writes fail closed', () {
    final registry = ProviderRegistry([LegalDemoProvider()]);
    final controller = ProvidersController(registry, ProviderHealthStore(), const []);
    expect(() => controller.setEnabled('missing', false), throwsArgumentError);
    expect(() => controller.setPriority('missing', 1), throwsArgumentError);
  });
}
