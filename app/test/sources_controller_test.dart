import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/providers/provider.dart';
import 'package:the_only/core/providers/provider_registry.dart';
import 'package:the_only/features/sources/sources_controller.dart';

class FixtureSourceProvider implements MediaProvider {
  FixtureSourceProvider(this.id, {this.fail = false});
  @override final String id;
  final bool fail;
  @override Future<List<MediaItem>> search(String query) async {
    if (fail) throw StateError('fixture failure');
    return [MediaItem(id: '42', title: query, kind: MediaKind.movie)];
  }
  @override Future<ProviderResult> sourcesFor(MediaItem item) async {
    if (fail) throw StateError('fixture failure');
    return ProviderResult(providerId: id, sources: [
      StreamSource(uri: Uri.parse('https://fixture.test/$id/${item.id}.mp4'), protocol: StreamProtocol.mp4, providerId: id),
    ]);
  }
}

void main() {
  test('Sources uses registry and isolates failing providers', () async {
    final registry = ProviderRegistry([FixtureSourceProvider('broken', fail: true), FixtureSourceProvider('licensed-fixture')]);
    final controller = SourcesController(registry);
    expect(controller.providerIds, containsAll(['broken', 'licensed-fixture']));
    final results = await controller.search('Example');
    expect(results.single.title, 'Example');
    final grouped = await controller.sourcesByProvider(results.single);
    expect(grouped.keys, ['licensed-fixture']);
    expect(grouped['licensed-fixture']!.single.protocol, StreamProtocol.mp4);
  });
}
