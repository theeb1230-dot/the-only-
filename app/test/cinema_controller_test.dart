import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/data/in_memory_downloads.dart';
import 'package:the_only/core/data/in_memory_library.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/domain/play_request.dart';
import 'package:the_only/core/providers/provider.dart';
import 'package:the_only/features/cinema/cinema_controller.dart';

class CinemaFixtureProvider implements MediaProvider {
  @override String get id => 'fixture';
  @override Future<List<MediaItem>> search(String query) async => const [
    MediaItem(id: 'm1', title: 'Movie', kind: MediaKind.movie),
    MediaItem(id: 'l1', title: 'Live', kind: MediaKind.live),
  ];
  @override Future<ProviderResult> sourcesFor(MediaItem item) async => ProviderResult(providerId: id, sources: [
    StreamSource(uri: Uri.parse('https://fixture.test/movie.mp4'), protocol: StreamProtocol.mp4, providerId: id, quality: '1080p'),
  ]);
}

void main() {
  test('Cinema uses shared services and explicit watch/download actions', () async {
    final favorites = MemoryFavoritesRepository();
    final history = MemoryHistoryRepository();
    final downloads = MemoryDownloadsRepository();
    final controller = CinemaController(providers: [CinemaFixtureProvider()], favorites: favorites, history: history, downloads: downloads);
    final results = await controller.search('movie');
    expect(results.length, 1);
    final movie = results.single;
    await controller.favorite(movie);
    expect((await favorites.all()).single.id, 'm1');
    expect((await controller.watch(movie)).action, MediaAction.watch);
    expect((await history.all()).single.item.id, 'm1');
    final source = (await controller.sources(movie)).single;
    final job = await controller.download(movie, source);
    expect(job.state.name, 'queued');
    expect((await downloads.all()).single.id, job.id);
  });
}
