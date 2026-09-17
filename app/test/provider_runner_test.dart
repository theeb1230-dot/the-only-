import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/providers/health.dart';
import 'package:the_only/core/providers/provider.dart';
import 'package:the_only/core/providers/provider_runner.dart';

class FixtureProvider implements MediaProvider {
  FixtureProvider(this.id, this.result);
  @override final String id;
  final ProviderResult result;
  @override Future<List<MediaItem>> search(String query) async => const [];
  @override Future<ProviderResult> sourcesFor(MediaItem item) async => result;
}

void main() {
  test('falls back when higher ranked provider has no sources', () async {
    const item = MediaItem(id: '1', title: 'One', kind: MediaKind.movie);
    final empty = FixtureProvider('empty', const ProviderResult(providerId: 'empty', sources: []));
    final source = StreamSource(uri: Uri.parse('https://example.test/a.m3u8'), protocol: StreamProtocol.hls, providerId: 'good');
    final good = FixtureProvider('good', ProviderResult(providerId: 'good', sources: [source]));
    final runner = ProviderRunner(providers: [empty, good], health: {
      'empty': const ProviderHealth(successes: 10, failures: 0, averageLatencyMs: 10),
      'good': const ProviderHealth(successes: 5, failures: 1, averageLatencyMs: 100),
    });
    expect((await runner.sourcesFor(item)).providerId, 'good');
  });
}
