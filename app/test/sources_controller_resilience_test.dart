import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/data/in_memory_downloads.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/domain/validation.dart';
import 'package:the_only/core/providers/provider.dart';
import 'package:the_only/core/providers/provider_registry.dart';
import 'package:the_only/core/resolvers/resolver_coordinator.dart';
import 'package:the_only/core/resolvers/resolver_registry.dart';
import 'package:the_only/core/security/url_policy.dart';
import 'package:the_only/features/sources/sources_controller.dart';

class _Provider implements MediaProvider {
  _Provider(this.id, {this.delay = Duration.zero, this.items = const []});

  @override
  final String id;
  final Duration delay;
  final List<MediaItem> items;

  @override
  Future<List<MediaItem>> search(String query) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    return items;
  }

  @override
  Future<ProviderResult> sourcesFor(MediaItem item) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    return ProviderResult(providerId: id, sources: const []);
  }
}

void main() {
  SourcesController controller(List<MediaProvider> providers) => SourcesController(
        ProviderRegistry(providers),
        resolver: ResolverCoordinator(
          ResolverRegistry(const []),
          const StreamValidator(UrlPolicy()),
        ),
        downloads: MemoryDownloadsRepository(),
        providerTimeout: const Duration(milliseconds: 20),
      );

  test('hung provider does not hide healthy Sources search results', () async {
    const item = MediaItem(id: 'ok', title: 'Healthy', kind: MediaKind.movie);
    final stopwatch = Stopwatch()..start();
    final result = await controller([
      _Provider('slow', delay: const Duration(seconds: 1)),
      _Provider('healthy', items: const [item]),
    ]).search('healthy');
    stopwatch.stop();

    expect(result, const [item]);
    expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 500)));
  });

  test('hung source discovery is bounded instead of hanging Sources UI', () async {
    const item = MediaItem(id: '1', title: 'One', kind: MediaKind.movie);
    final stopwatch = Stopwatch()..start();
    final result = await controller([
      _Provider('slow', delay: const Duration(seconds: 1)),
    ]).sourcesByProvider(item);
    stopwatch.stop();

    expect(result, isEmpty);
    expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 500)));
  });
}
