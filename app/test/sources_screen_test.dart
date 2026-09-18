import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/data/in_memory_downloads.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/domain/validation.dart';
import 'package:the_only/core/providers/provider.dart';
import 'package:the_only/core/providers/provider_registry.dart';
import 'package:the_only/core/resolvers/direct_media_resolver.dart';
import 'package:the_only/core/resolvers/resolver_coordinator.dart';
import 'package:the_only/core/resolvers/resolver_registry.dart';
import 'package:the_only/core/security/url_policy.dart';
import 'package:the_only/features/sources/sources_controller.dart';
import 'package:the_only/features/sources/sources_screen.dart';

class ScreenSourceProvider implements MediaProvider {
  ScreenSourceProvider(this.id, {this.fail = false});

  @override
  final String id;
  final bool fail;

  @override
  Future<List<MediaItem>> search(String query) async {
    if (fail) throw StateError('fixture failure');
    return const [
      MediaItem(
        id: 'fixture',
        title: 'Fixture Source Movie',
        kind: MediaKind.movie,
      ),
    ];
  }

  @override
  Future<ProviderResult> sourcesFor(MediaItem item) async {
    if (fail) throw StateError('fixture failure');
    return ProviderResult(
      providerId: id,
      sources: [
        StreamSource(
          uri: Uri.parse('https://example.com/source.mp4'),
          protocol: StreamProtocol.mp4,
          providerId: id,
          quality: '1080p',
        ),
        StreamSource(
          uri: Uri.parse('https://example.com/embed'),
          protocol: StreamProtocol.embed,
          providerId: id,
          quality: 'Embed',
        ),
      ],
    );
  }
}

void main() {
  testWidgets(
    'Sources resolves Watch and keeps direct Download separate',
    (tester) async {
      final downloads = MemoryDownloadsRepository();
      final resolver = ResolverCoordinator(
        ResolverRegistry(const [DirectMediaResolver()]),
        const StreamValidator(UrlPolicy()),
      );
      final controller = SourcesController(
        ProviderRegistry([
          ScreenSourceProvider('broken', fail: true),
          ScreenSourceProvider('fixture'),
        ]),
        resolver: resolver,
        downloads: downloads,
      );
      var watches = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourcesScreen(
              controller: controller,
              playerLauncher: (context, item, source) async {
                expect(item.id, 'fixture');
                expect(source.uri.toString(), 'https://example.com/source.mp4');
                watches++;
              },
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('sources-search-field')),
        'movie',
      );
      await tester.tap(find.byKey(const Key('sources-search-button')));
      await tester.pumpAndSettle();
      expect(find.text('Fixture Source Movie'), findsOneWidget);
      await tester.tap(find.byKey(const Key('sources-item-fixture')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('sources-download-fixture-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('sources-download-fixture-1')),
        findsNothing,
        reason: 'Embed is not a direct downloadable source',
      );

      await tester.tap(find.byKey(const Key('sources-watch-fixture-0')));
      await tester.pumpAndSettle();
      expect(watches, 1);
      expect(await downloads.all(), isEmpty);

      await tester.tap(find.byKey(const Key('sources-download-fixture-0')));
      await tester.pumpAndSettle();
      expect(watches, 1);
      expect(await downloads.all(), hasLength(1));
    },
  );
}
