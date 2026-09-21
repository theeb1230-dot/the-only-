import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_only/core/data/downloads.dart';
import 'package:the_only/core/data/library.dart';
import 'package:the_only/core/data/persistent_library.dart';
import 'package:the_only/core/domain/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('persists favorites history and downloads across repository recreation', () async {
    final preferences = await SharedPreferences.getInstance();
    final store = PersistentLibraryStore(preferences);
    await store.initialize();

    final favorites = PersistentFavoritesRepository(store);
    final history = PersistentHistoryRepository(store);
    final downloads = PersistentDownloadsRepository(store);
    const item = MediaItem(
      id: 'movie-1',
      title: 'Persistent Movie',
      kind: MediaKind.movie,
      posterUrl: 'https://images.example.test/poster.jpg',
      backdropUrl: 'https://images.example.test/backdrop.jpg',
      overview: 'Persistent metadata must survive app recreation.',
      year: 2026,
      rating: 8.4,
    );
    final source = StreamSource(
      uri: Uri.parse('https://cdn.example.test/movie.mp4'),
      protocol: StreamProtocol.mp4,
      providerId: 'legal',
      quality: '1080p',
    );

    await favorites.add(item);
    await history.save(HistoryEntry(
      item: item,
      position: const Duration(seconds: 73),
      updatedAt: DateTime.utc(2026, 9, 18, 10, 30),
    ));
    await downloads.enqueue(
      DownloadJob(
        id: 'download-1',
        source: source,
        state: DownloadState.queued,
      ),
    );

    final recreated = PersistentLibraryStore(
      await SharedPreferences.getInstance(),
    );
    await recreated.initialize();

    final savedFavorites = await PersistentFavoritesRepository(recreated).all();
    final savedHistory = await PersistentHistoryRepository(recreated).all();
    final savedDownloads = await PersistentDownloadsRepository(recreated).all();

    expect(savedFavorites.single.id, 'movie-1');
    expect(savedFavorites.single.posterUrl, item.posterUrl);
    expect(savedFavorites.single.backdropUrl, item.backdropUrl);
    expect(savedFavorites.single.overview, item.overview);
    expect(savedFavorites.single.year, 2026);
    expect(savedFavorites.single.rating, 8.4);
    expect(savedHistory.single.position, const Duration(seconds: 73));
    expect(savedHistory.single.item.posterUrl, item.posterUrl);
    expect(savedDownloads.single.source.uri, source.uri);
    expect(savedDownloads.single.state, DownloadState.queued);
  });

  test('deduplicates favorites, history and download jobs by stable id', () async {
    final store = PersistentLibraryStore(await SharedPreferences.getInstance());
    await store.initialize();
    final favorites = PersistentFavoritesRepository(store);
    final history = PersistentHistoryRepository(store);
    final downloads = PersistentDownloadsRepository(store);
    const first = MediaItem(id: 'same', title: 'Old', kind: MediaKind.movie);
    const replacement = MediaItem(id: 'same', title: 'New', kind: MediaKind.movie);
    final source = StreamSource(
      uri: Uri.parse('https://cdn.example.test/a.mp4'),
      protocol: StreamProtocol.mp4,
      providerId: 'legal',
    );

    await favorites.add(first);
    await favorites.add(replacement);
    await history.save(HistoryEntry(
      item: first,
      position: Duration.zero,
      updatedAt: DateTime.utc(2026),
    ));
    await history.save(HistoryEntry(
      item: replacement,
      position: const Duration(seconds: 9),
      updatedAt: DateTime.utc(2026, 1, 2),
    ));
    await downloads.enqueue(
      DownloadJob(id: 'same-job', source: source, state: DownloadState.queued),
    );
    await downloads.enqueue(
      DownloadJob(id: 'same-job', source: source, state: DownloadState.paused),
    );

    expect((await favorites.all()), hasLength(1));
    expect((await favorites.all()).single.title, 'New');
    expect((await history.all()), hasLength(1));
    expect((await history.all()).single.position, const Duration(seconds: 9));
    expect((await downloads.all()), hasLength(1));
    expect((await downloads.all()).single.state, DownloadState.paused);
  });

  test('corrupt collection fails closed without crashing', () async {
    SharedPreferences.setMockInitialValues({
      'the_only.storage.schema': 1,
      'the_only.v1.favorites': '{not-json',
    });
    final store = PersistentLibraryStore(await SharedPreferences.getInstance());
    await store.initialize();
    expect(await PersistentFavoritesRepository(store).all(), isEmpty);
  });

  test('migrates schema v1 to current version without losing collections', () async {
    SharedPreferences.setMockInitialValues({
      'the_only.storage.schema': 1,
      'the_only.v1.favorites':
          '[{"id":"kept","title":"Kept Movie","kind":"movie"}]',
    });
    final preferences = await SharedPreferences.getInstance();
    final store = PersistentLibraryStore(preferences);

    await store.initialize();

    expect(
      preferences.getInt('the_only.storage.schema'),
      PersistentLibraryStore.schemaVersion,
    );
    final favorites = await PersistentFavoritesRepository(store).all();
    expect(favorites.single.id, 'kept');
    expect(favorites.single.title, 'Kept Movie');
    expect(favorites.single.posterUrl, isNull);
  });

  test('future storage schema fails closed', () async {
    SharedPreferences.setMockInitialValues({'the_only.storage.schema': 999});
    final store = PersistentLibraryStore(await SharedPreferences.getInstance());
    await expectLater(store.initialize(), throwsStateError);
  });
}
