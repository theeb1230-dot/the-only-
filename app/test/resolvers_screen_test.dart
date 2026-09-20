import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/domain/validation.dart';
import 'package:the_only/core/resolvers/resolver.dart';
import 'package:the_only/core/resolvers/resolver_coordinator.dart';
import 'package:the_only/core/resolvers/resolver_registry.dart';
import 'package:the_only/core/security/url_policy.dart';
import 'package:the_only/features/resolvers/resolvers_controller.dart';
import 'package:the_only/features/resolvers/resolvers_screen.dart';

class FixtureResolver implements StreamResolver {
  @override String get id => 'fixture-resolver';
  @override bool supports(Uri uri) => uri.host == 'example.invalid';
  @override Future<List<StreamSource>> resolve(Uri uri) async => [
    StreamSource(uri: Uri.parse('https://example.invalid/video.mp4'), protocol: StreamProtocol.mp4, providerId: id, quality: '1080p'),
    StreamSource(uri: Uri.parse('https://example.invalid/embed'), protocol: StreamProtocol.embed, providerId: id, quality: 'Embed'),
  ];
}

class ThrowingResolver implements StreamResolver {
  @override String get id => 'throwing-resolver';
  @override bool supports(Uri uri) => true;
  @override Future<List<StreamSource>> resolve(Uri uri) async => throw StateError('fixture failure');
}

ResolversController fixtureController() {
  final registry = ResolverRegistry([FixtureResolver()]);
  return ResolversController(registry, ResolverCoordinator(registry, const StreamValidator(UrlPolicy())));
}

void main() {
  testWidgets('Resolver shows support and keeps direct Download separate from Watch', (tester) async {
    final controller = fixtureController();
    var watches = 0; var downloads = 0;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: ResolversScreen(controller: controller, onWatch: (_) async => watches++, onDownload: (_) async => downloads++))));
    await tester.enterText(find.byKey(const Key('resolver-uri')), 'https://example.invalid/page'); await tester.tap(find.byKey(const Key('resolver-run'))); await tester.pumpAndSettle();
    expect(find.text('Supported'), findsOneWidget); expect(find.byKey(const Key('resolver-result-0')), findsOneWidget); expect(find.byKey(const Key('resolver-result-1')), findsOneWidget);
    expect(find.byKey(const Key('resolver-download-0')), findsOneWidget); expect(find.byKey(const Key('resolver-download-1')), findsNothing);
    await tester.tap(find.byKey(const Key('resolver-watch-1'))); await tester.pump(); expect(watches, 1); expect(downloads, 0);
    await tester.tap(find.byKey(const Key('resolver-download-0'))); await tester.pump(); expect(downloads, 1);
  });
  testWidgets('Resolver failure clears loading and exposes safe error', (tester) async {
    final registry = ResolverRegistry([ThrowingResolver()]);
    final controller = ResolversController(registry, ResolverCoordinator(registry, const StreamValidator(UrlPolicy())));
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: ResolversScreen(controller: controller))));
    await tester.enterText(find.byKey(const Key('resolver-uri')), 'https://example.invalid/page'); await tester.tap(find.byKey(const Key('resolver-run'))); await tester.pumpAndSettle();
    expect(find.byKey(const Key('resolver-error')), findsOneWidget);
    expect(find.byKey(const Key('resolver-loading')), findsNothing);
    expect(find.byKey(const Key('resolver-result-0')), findsNothing);
  });
  testWidgets('Resolver reports unsupported URI without resolving', (tester) async {
    final controller = fixtureController();
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: ResolversScreen(controller: controller))));
    await tester.enterText(find.byKey(const Key('resolver-uri')), 'https://unsupported.invalid/page'); await tester.tap(find.byKey(const Key('resolver-run'))); await tester.pump();
    expect(find.text('Unsupported'), findsOneWidget); expect(find.byKey(const Key('resolver-result-0')), findsNothing);
  });
}
