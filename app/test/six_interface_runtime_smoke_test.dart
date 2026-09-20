import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_only/core/data/in_memory_downloads.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/domain/validation.dart';
import 'package:the_only/core/providers/legal_demo_provider.dart';
import 'package:the_only/core/providers/provider_health_store.dart';
import 'package:the_only/core/providers/provider_registry.dart';
import 'package:the_only/core/resolvers/direct_media_resolver.dart';
import 'package:the_only/core/resolvers/resolver_coordinator.dart';
import 'package:the_only/core/resolvers/resolver_registry.dart';
import 'package:the_only/core/security/url_policy.dart';
import 'package:the_only/features/resolvers/resolvers_controller.dart';
import 'package:the_only/features/resolvers/resolvers_screen.dart';
import 'package:the_only/features/sources/sources_controller.dart';
import 'package:the_only/features/sources/sources_screen.dart';
import 'package:the_only/features/system_diagnostics/system_diagnostics_controller.dart';
import 'package:the_only/features/system_diagnostics/system_diagnostics_screen.dart';
import 'package:the_only/features/tools/providers_controller.dart';
import 'package:the_only/features/tools/providers_screen.dart';

final class _SnapshotProvider implements SystemSnapshotProvider {
  @override
  Future<SystemSnapshot> capture() async => SystemSnapshot(
        operatingSystem: 'test-os',
        operatingSystemVersion: '1',
        logicalProcessors: 4,
        localeName: 'en_US',
        appUptime: const Duration(seconds: 3),
        capturedAt: DateTime.utc(2026, 9, 19),
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Sources uses legal runtime provider and keeps Watch and Download separate', (tester) async {
    final downloads = MemoryDownloadsRepository();
    final resolver = ResolverCoordinator(
      ResolverRegistry(const [DirectMediaResolver()]),
      const StreamValidator(UrlPolicy()),
    );
    final controller = SourcesController(
      ProviderRegistry([LegalDemoProvider()]),
      resolver: resolver,
      downloads: downloads,
    );
    StreamSource? watched;

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SourcesScreen(
      controller: controller,
      playerLauncher: (_, __, source) async => watched = source,
    ))));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('sources-search-field')), 'Bunny');
    await tester.tap(find.byKey(const Key('sources-search-button')));
    await tester.pumpAndSettle();
    expect(find.text('Big Buck Bunny'), findsOneWidget);
    expect(find.byKey(const Key('sources-loading')), findsNothing);
    expect(find.byKey(const Key('sources-error')), findsNothing);
    await tester.tap(find.byKey(const Key('sources-item-big-buck-bunny')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sources-watch-legal-demo-0')), findsOneWidget);
    expect(find.byKey(const Key('sources-download-legal-demo-0')), findsOneWidget);

    final watch = find.byKey(const Key('sources-watch-legal-demo-0'));
    await tester.ensureVisible(watch);
    await tester.tap(watch);
    await tester.pumpAndSettle();
    expect(watched?.uri.host, 'commondatastorage.googleapis.com');
    expect(await downloads.all(), isEmpty);

    final download = find.byKey(const Key('sources-download-legal-demo-0'));
    await tester.ensureVisible(download);
    await tester.tap(download);
    await tester.pumpAndSettle();
    expect(await downloads.all(), hasLength(1));
  });

  testWidgets('Resolvers diagnostics exercises the same direct resolver contract used by Watch paths', (tester) async {
    final registry = ResolverRegistry(const [DirectMediaResolver()]);
    final coordinator = ResolverCoordinator(registry, const StreamValidator(UrlPolicy()));
    StreamSource? watched;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: ResolversScreen(
      controller: ResolversController(registry, coordinator),
      onWatch: (source) async => watched = source,
    ))));
    await tester.enterText(
      find.byKey(const Key('resolver-uri')),
      'https://mdn.github.io/shared-assets/videos/flower.mp4',
    );
    await tester.tap(find.byKey(const Key('resolver-run')));
    await tester.pumpAndSettle();
    expect(find.text('مدعوم'), findsOneWidget);
    expect(find.byKey(const Key('resolver-result-0')), findsOneWidget);
    expect(find.byKey(const Key('resolver-loading')), findsNothing);
    expect(find.byKey(const Key('resolver-error')), findsNothing);
    await tester.tap(find.byKey(const Key('resolver-watch-0')));
    await tester.pumpAndSettle();
    expect(watched?.protocol, StreamProtocol.mp4);
    expect(watched?.uri.host, 'mdn.github.io');
  });

  testWidgets('Tools Providers exposes registered legal provider, probe health, and persistent preferences', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final registry = ProviderRegistry([LegalDemoProvider()]);
    final health = ProviderHealthStore();
    final controller = ProvidersController(registry, health, const [], preferencesStore: preferences);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: ProvidersScreen(controller: controller))));
    expect(find.byKey(const Key('provider-legal-demo')), findsOneWidget);
    expect(find.byKey(const Key('providers-empty')), findsNothing);
    expect(find.byKey(const Key('providers-error')), findsNothing);
    expect(health.health('legal-demo').successes, 0);
    await tester.tap(find.byKey(const Key('provider-probe-legal-demo')));
    await tester.pumpAndSettle();
    expect(health.health('legal-demo').successes, 1);
    expect(health.health('legal-demo').failures, 0);
    expect(health.health('legal-demo').score, greaterThan(0));
    await tester.tap(find.byKey(const Key('provider-enabled-legal-demo')));
    await tester.pumpAndSettle();
    expect(preferences.getBool('the_only.provider.legal-demo.enabled'), isFalse);
  });

  testWidgets('Sixth clean-room interface renders local diagnostics and refreshes without telemetry dependency', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SystemDiagnosticsScreen(
      controller: SystemDiagnosticsController(_SnapshotProvider()),
    ))));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('system-diagnostics-screen')), findsOneWidget);
    expect(find.text('معلومات الجهاز المحلية فقط. لا يتم رفع أي بيانات تشخيصية.'), findsOneWidget);
    expect(find.text('test-os'), findsOneWidget);
    expect(find.byKey(const Key('system-diagnostics-loading')), findsNothing);
    expect(find.byKey(const Key('system-diagnostics-error')), findsNothing);
    expect(find.byKey(const Key('system-diagnostics-empty')), findsNothing);
    expect(find.text('4'), findsOneWidget);
    await tester.tap(find.byKey(const Key('system-diagnostics-refresh')));
    await tester.pumpAndSettle();
    expect(find.text('test-os'), findsOneWidget);
  });
}
