import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/data/downloads.dart';
import 'package:the_only/core/data/library.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/domain/validation.dart';
import 'package:the_only/core/providers/provider.dart';
import 'package:the_only/core/resolvers/direct_media_resolver.dart';
import 'package:the_only/core/resolvers/resolver_coordinator.dart';
import 'package:the_only/core/resolvers/resolver_registry.dart';
import 'package:the_only/core/security/url_policy.dart';
import 'package:the_only/features/cinema/cinema_controller.dart';
import 'package:the_only/features/cinema/cinema_screen.dart';

class FixtureProvider implements MediaProvider {
  @override
  String get id => 'fixture';

  @override
  Future<List<MediaItem>> search(String query) async => const [MediaItem(id: 'movie-1', title: 'Fixture Movie', kind: MediaKind.movie)];

  @override
  Future<ProviderResult> sourcesFor(MediaItem item) async => ProviderResult(providerId: id, sources: [
    StreamSource(uri: Uri.parse('https://example.invalid/fixture.mp4'), protocol: StreamProtocol.mp4, providerId: id, quality: '1080p'),
  ]);
}

class FixtureFavorites implements FavoritesRepository {
  final items = <MediaItem>[];
  @override Future<List<MediaItem>> all() async => items;
  @override Future<void> add(MediaItem item) async => items.add(item);
  @override Future<void> remove(String mediaId) async => items.removeWhere((item) => item.id == mediaId);
}

class FixtureHistory implements HistoryRepository {
  final entries = <HistoryEntry>[];
  @override Future<List<HistoryEntry>> all() async => entries;
  @override Future<void> save(HistoryEntry entry) async => entries.add(entry);
}

class FixtureDownloads implements DownloadsRepository {
  final jobs = <DownloadJob>[];
  @override Future<List<DownloadJob>> all() async => jobs;
  @override Future<void> enqueue(DownloadJob job) async => jobs.add(job);
  @override Future<void> update(DownloadJob job) async { jobs.removeWhere((item) => item.id == job.id); jobs.add(job); }
  @override Future<void> remove(String id) async => jobs.removeWhere((job) => job.id == id);
}

void main() {
  testWidgets('Cinema exposes separate resolver-backed Watch and Download actions', (tester) async {
    final favorites = FixtureFavorites();
    final history = FixtureHistory();
    final downloads = FixtureDownloads();
    final registry = ResolverRegistry(const [DirectMediaResolver()]);
    final controller = CinemaController(
      providers: [FixtureProvider()],
      favorites: favorites,
      history: history,
      downloads: downloads,
      resolver: ResolverCoordinator(registry, const StreamValidator(UrlPolicy())),
    );
    StreamSource? launched;

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: CinemaScreen(
      controller: controller,
      playerLauncher: (_, __, source) async { launched = source; },
    ))));
    await tester.enterText(find.byKey(const Key('cinema-search-field')), 'fixture');
    await tester.tap(find.byKey(const Key('cinema-search-button')));
    await tester.pumpAndSettle();
    expect(find.text('Fixture Movie'), findsOneWidget);\n    expect(find.byKey(const Key('cinema-loading')), findsNothing);\n    expect(find.byKey(const Key('cinema-error')), findsNothing);\n    expect(find.byKey(const Key('cinema-empty')), findsNothing);

    await tester.tap(find.byKey(const Key('cinema-favorite-movie-1')));
    await tester.pump();
    expect(favorites.items, hasLength(1));

    await tester.tap(find.byKey(const Key('cinema-item-movie-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('cinema-watch-0')), findsOneWidget);
    expect(find.byKey(const Key('cinema-download-0')), findsOneWidget);

    await tester.tap(find.byKey(const Key('cinema-watch-0')));
    await tester.pumpAndSettle();
    expect(history.entries, hasLength(1));
    expect(launched, isNotNull);
    expect(launched!.protocol, StreamProtocol.mp4);
    expect(downloads.jobs, isEmpty, reason: 'Watch must never implicitly queue a download');

    await tester.tap(find.byKey(const Key('cinema-download-0')));
    await tester.pumpAndSettle();
    expect(downloads.jobs, hasLength(1));
    expect(history.entries, hasLength(1), reason: 'Download must remain independent from Watch/history');
    expect(find.text('Download queued'), findsOneWidget);
  });
}
