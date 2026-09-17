import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/providers/provider.dart';
import 'package:the_only/core/providers/provider_health_store.dart';
import 'package:the_only/core/providers/provider_registry.dart';
import 'package:the_only/core/settings/provider_preferences.dart';
import 'package:the_only/features/tools/providers_controller.dart';

class ToolFixtureProvider implements MediaProvider {
  ToolFixtureProvider(this.id);
  @override final String id;
  @override Future<List<MediaItem>> search(String query) async => const [];
  @override Future<ProviderResult> sourcesFor(MediaItem item) async => ProviderResult(providerId: id, sources: const []);
}

void main() {
  test('Tools manages enablement priority and health without duplicating registry', () {
    final registry = ProviderRegistry([ToolFixtureProvider('alpha'), ToolFixtureProvider('beta')]);
    final health = ProviderHealthStore();
    final controller = ProvidersController(registry, health, const [
      ProviderPreference(id: 'alpha', priority: 1),
      ProviderPreference(id: 'beta', priority: 5),
    ]);

    controller.recordProbe('alpha', success: true, latencyMs: 50);
    controller.recordProbe('beta', success: false, latencyMs: 900);
    expect(controller.states().first.id, 'beta');

    controller.setEnabled('beta', false);
    expect(controller.states().first.id, 'alpha');
    expect(controller.states().last.enabled, isFalse);

    controller.setPriority('alpha', 10);
    expect(controller.states().first.priority, 10);
    expect(controller.states().first.health.successes, 1);
  });

  test('Tools rejects probes for providers outside shared registry', () {
    final controller = ProvidersController(ProviderRegistry(const []), ProviderHealthStore(), const []);
    expect(() => controller.recordProbe('missing', success: true, latencyMs: 1), throwsArgumentError);
  });
}
