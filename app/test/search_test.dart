import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/providers/provider.dart';
import 'package:the_only/core/search/search.dart';

class SearchProvider implements MediaProvider {
  SearchProvider(this.id, this.items);
  @override
  final String id;
  final List<MediaItem> items;
  @override
  Future<List<MediaItem>> search(String query) async => items;
  @override
  Future<ProviderResult> sourcesFor(MediaItem item) async => ProviderResult(providerId: id, sources: const []);
}

void main() {
  test('aggregates providers and removes duplicate media identities', () async {
    const item = MediaItem(id: '1', title: 'One', kind: MediaKind.movie);
    final coordinator = SearchCoordinator([SearchProvider('a', [item]), SearchProvider('b', [item])]);
    expect((await coordinator.search('one')).length, 1);
    expect(await coordinator.search('   '), isEmpty);
  });
}
