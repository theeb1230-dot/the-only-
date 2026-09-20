import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/providers/provider.dart';
import 'package:the_only/core/providers/provider_health_store.dart';
import 'package:the_only/core/providers/provider_registry.dart';
import 'package:the_only/core/settings/provider_preferences.dart';
import 'package:the_only/features/tools/providers_controller.dart';
import 'package:the_only/features/tools/providers_screen.dart';

class ScreenFixtureProvider implements MediaProvider {
  ScreenFixtureProvider(this.id);
  @override final String id;
  @override Future<List<MediaItem>> search(String query) async => const [];
  @override Future<ProviderResult> sourcesFor(MediaItem item) async => ProviderResult(providerId: id, sources: const []);
}

void main() {
  testWidgets('Tools UI exposes shared provider state and controls', (tester) async {
    final registry = ProviderRegistry([ScreenFixtureProvider('alpha'), ScreenFixtureProvider('beta')]);
    final health = ProviderHealthStore();
    health.record('alpha', success: true, latencyMs: 40);
    final controller = ProvidersController(registry, health, const [
      ProviderPreference(id: 'alpha', priority: 3),
      ProviderPreference(id: 'beta', priority: 1),
    ]);

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: ProvidersScreen(controller: controller))));
    expect(find.byKey(const Key('providers-list')), findsOneWidget);
    expect(find.text('alpha'), findsOneWidget);
    expect(find.textContaining('الصحة'), findsNWidgets(2));

    await tester.tap(find.byKey(const Key('provider-enabled-alpha')));
    await tester.pump();
    expect(controller.states().where((state) => state.id == 'alpha').single.enabled, isFalse);

    await tester.tap(find.byKey(const Key('provider-priority-up-beta')));
    await tester.pump();
    expect(controller.states().where((state) => state.id == 'beta').single.priority, 2);
  });

  testWidgets('Tools UI has deterministic empty state', (tester) async {
    final controller = ProvidersController(ProviderRegistry(const []), ProviderHealthStore(), const []);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: ProvidersScreen(controller: controller))));
    expect(find.byKey(const Key('providers-empty')), findsOneWidget);
  });
}
