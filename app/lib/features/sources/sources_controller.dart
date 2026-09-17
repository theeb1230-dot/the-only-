import '../../core/domain/models.dart';
import '../../core/providers/provider_registry.dart';

class SourcesController {
  SourcesController(this.registry);
  final ProviderRegistry registry;

  List<String> get providerIds => registry.all.map((provider) => provider.id).toList(growable: false);

  Future<List<MediaItem>> search(String query) async {
    final results = <String, MediaItem>{};
    for (final provider in registry.all) {
      try {
        for (final item in await provider.search(query)) {
          results.putIfAbsent('${item.kind.name}:${item.id}', () => item);
        }
      } catch (_) {
        // A broken provider must not make the shared Sources interface unavailable.
      }
    }
    return results.values.toList(growable: false);
  }

  Future<Map<String, List<StreamSource>>> sourcesByProvider(MediaItem item) async {
    final result = <String, List<StreamSource>>{};
    for (final provider in registry.all) {
      try {
        final providerResult = await provider.sourcesFor(item);
        if (providerResult.sources.isNotEmpty) {
          result[provider.id] = List.unmodifiable(providerResult.sources);
        }
      } catch (_) {
        // Provider failure is isolated; other registered providers remain usable.
      }
    }
    return Map.unmodifiable(result);
  }
}
