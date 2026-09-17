import '../domain/models.dart';
import '../providers/provider.dart';

class SearchCoordinator {
  SearchCoordinator(this.providers);
  final Iterable<MediaProvider> providers;

  Future<List<MediaItem>> search(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return const [];
    final batches = await Future.wait(providers.map((p) => p.search(normalized)));
    final byId = <String, MediaItem>{};
    for (final batch in batches) {
      for (final item in batch) {
        byId.putIfAbsent('${item.kind.name}:${item.id}', () => item);
      }
    }
    return byId.values.toList(growable: false);
  }
}
