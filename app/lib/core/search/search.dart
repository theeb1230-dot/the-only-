import '../domain/models.dart';
import '../providers/provider.dart';

class SearchCoordinator {
  SearchCoordinator(
    this.providers, {
    this.providerTimeout = const Duration(seconds: 5),
  });

  final Iterable<MediaProvider> providers;
  final Duration providerTimeout;

  Future<List<MediaItem>> search(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return const [];

    final batches = await Future.wait(
      providers.map((provider) async {
        try {
          return await provider.search(normalized).timeout(providerTimeout);
        } catch (_) {
          // Search is a shared product surface: one slow/broken provider must
          // not hide healthy providers or leave the UI waiting forever.
          return const <MediaItem>[];
        }
      }),
    );

    final byId = <String, MediaItem>{};
    for (final batch in batches) {
      for (final item in batch) {
        byId.putIfAbsent('${item.kind.name}:${item.id}', () => item);
      }
    }
    return byId.values.toList(growable: false);
  }
}
