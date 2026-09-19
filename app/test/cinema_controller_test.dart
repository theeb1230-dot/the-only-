import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/data/cache_policy.dart';
import 'package:the_only/core/data/in_memory_downloads.dart';
import 'package:the_only/core/data/in_memory_library.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/domain/play_request.dart';
import 'package:the_only/core/providers/provider.dart';
import 'package:the_only/features/cinema/cinema_controller.dart';

class CinemaFixtureProvider implements MediaProvider {
  int sourceCalls=0;
  @override String get id => 'fixture';
  @override Future<List<MediaItem>> search(String query) async => const [
    MediaItem(id: 'm1', title: 'Movie', kind: MediaKind.movie),
    MediaItem(id: 'l1', title: 'Live', kind: MediaKind.live),
  ];
  @override Future<ProviderResult> sourcesFor(MediaItem item) async {
    sourceCalls++;
    return ProviderResult(providerId: id, sources: [
      StreamSource(uri: Uri.parse('https://fixture.test/movie-720.mp4'), protocol: StreamProtocol.mp4, providerId: id, quality: '720p'),
      StreamSource(uri: Uri.parse('http://unsafe.test/movie.mp4'), protocol: StreamProtocol.mp4, providerId: id, quality: '2160p'),
      StreamSource(uri: Uri.parse('https://fixture.test/movie-1080.mp4'), protocol: StreamProtocol.mp4, providerId: id, quality: '1080p'),
    ]);
  }
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
    final source = (await controller.sources(movie)).first;
    expect(source.quality,'1080p');
    final job = await controller.download(movie, source);
    expect(job.state.name, 'queued');
    expect((await downloads.all()).single.id, job.id);
  });

  test('Cinema filters unsafe streams, ranks quality, and reuses fresh source cache', () async {
    final provider=CinemaFixtureProvider();
    var clock=DateTime.utc(2026,9,19,18);
    final controller=CinemaController(
      providers:[provider],
      favorites:MemoryFavoritesRepository(),
      history:MemoryHistoryRepository(),
      downloads:MemoryDownloadsRepository(),
      cachePolicy:const CachePolicy(streamTtl:Duration(minutes:3)),
      now:()=>clock,
    );
    const movie=MediaItem(id:'m1',title:'Movie',kind:MediaKind.movie);
    final first=await controller.sources(movie);
    expect(first.map((e)=>e.quality),['1080p','720p']);
    expect(provider.sourceCalls,1);
    await controller.sources(movie);
    expect(provider.sourceCalls,1);
    clock=clock.add(const Duration(minutes:4));
    await controller.sources(movie);
    expect(provider.sourceCalls,2);
  });
}
