import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/providers/provider.dart';
import 'package:the_only/core/search/search.dart';

class SearchProvider implements MediaProvider {
  SearchProvider(this.id, this.items, {this.error, this.delay = Duration.zero});
  @override
  final String id;
  final List<MediaItem> items;
  final Object? error;
  final Duration delay;

  @override
  Future<List<MediaItem>> search(String query) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (error != null) throw error!;
    return items;
  }

  @override
  Future<ProviderResult> sourcesFor(MediaItem item) async =>
      ProviderResult(providerId: id, sources: const []);
}

void main() {
  test('aggregates providers and removes duplicate media identities', () async {
    const item = MediaItem(id: '1', title: 'One', kind: MediaKind.movie);
    final coordinator = SearchCoordinator([
      SearchProvider('a', [item]),
      SearchProvider('b', [item]),
    ]);
    expect((await coordinator.search('one')).length, 1);
    expect(await coordinator.search('   '), isEmpty);
  });

  test('broken provider does not hide healthy provider results', () async {
    const item = MediaItem(id: 'healthy', title: 'Healthy', kind: MediaKind.movie);
    final coordinator = SearchCoordinator([
      SearchProvider('broken', const [], error: StateError('offline')),
      SearchProvider('healthy', const [item]),
    ]);
    expect(await coordinator.search('healthy'), const [item]);
  });

  test('slow provider times out without hanging shared search', () async {
    const item = MediaItem(id: 'fast', title: 'Fast', kind: MediaKind.movie);
    final coordinator = SearchCoordinator(
      [
        SearchProvider('slow', const [], delay: const Duration(seconds: 1)),
        SearchProvider('fast', const [item]),
      ],
      providerTimeout: const Duration(milliseconds: 20),
    );

    final stopwatch = Stopwatch()..start();
    final result = await coordinator.search('fast');
    stopwatch.stop();

    expect(result, const [item]);
    expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 500)));
  });
}
