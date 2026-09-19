import '../../core/data/downloads.dart';
import '../../core/domain/download_policy.dart';
import '../../core/domain/models.dart';
import '../../core/providers/provider_registry.dart';
import '../../core/resolvers/resolver_coordinator.dart';

class SourcesController {
  SourcesController(
    this.registry, {
    required this.resolver,
    required this.downloads,
    this.providerTimeout = const Duration(seconds: 5),
  });

  final ProviderRegistry registry;
  final ResolverCoordinator resolver;
  final DownloadsRepository downloads;
  final Duration providerTimeout;

  List<String> get providerIds =>
      registry.all.map((provider) => provider.id).toList(growable: false);

  Future<List<MediaItem>> search(String query) async {
    final results = <String, MediaItem>{};
    for (final provider in registry.all) {
      try {
        for (final item in await provider.search(query).timeout(providerTimeout)) {
          results.putIfAbsent('${item.kind.name}:${item.id}', () => item);
        }
      } catch (_) {
        // A broken or hung provider must not make the shared Sources interface unavailable.
      }
    }
    return results.values.toList(growable: false);
  }

  Future<Map<String, List<StreamSource>>> sourcesByProvider(MediaItem item) async {
    final result = <String, List<StreamSource>>{};
    for (final provider in registry.all) {
      try {
        final providerResult =
            await provider.sourcesFor(item).timeout(providerTimeout);
        if (providerResult.sources.isNotEmpty) {
          result[provider.id] = List.unmodifiable(providerResult.sources);
        }
      } catch (_) {
        // Provider failure/timeout is isolated; other registered providers remain usable.
      }
    }
    return Map.unmodifiable(result);
  }

  Future<StreamSource?> resolveForWatch(
    MediaItem item,
    StreamSource source,
  ) async {
    final resolved = await resolver.resolve(source.uri);
    if (resolved.isEmpty) return null;
    return resolved.first;
  }

  Future<DownloadJob> download(MediaItem item, StreamSource source) async {
    if (!isDownloadable(source)) {
      throw StateError('Selected source is not directly downloadable');
    }
    final job = DownloadJob(
      id: '${item.kind.name}:${item.id}:${source.uri}',
      source: source,
      state: DownloadState.queued,
    );
    await downloads.enqueue(job);
    return job;
  }
}
