import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/domain/validation.dart';
import 'package:the_only/core/providers/health.dart';
import 'package:the_only/core/providers/provider.dart';
import 'package:the_only/core/providers/safe_provider_runner.dart';
import 'package:the_only/core/security/url_policy.dart';

class P implements MediaProvider {
  P(this.id, this.source, {String? resultProviderId}) : resultProviderId = resultProviderId ?? id;
  @override final String id;
  final StreamSource source;
  final String resultProviderId;
  @override Future<List<MediaItem>> search(String query) async => const [];
  @override Future<ProviderResult> sourcesFor(MediaItem item) async => ProviderResult(providerId: resultProviderId, sources: [source]);
}

void main() {
  const item = MediaItem(id: '1', title: 'One', kind: MediaKind.movie);

  test('falls through insecure provider result', () async {
    final bad = P('bad', StreamSource(uri: Uri.parse('http://example.test/a.mp4'), protocol: StreamProtocol.mp4, providerId: 'bad'));
    final good = P('good', StreamSource(uri: Uri.parse('https://example.test/a.mp4'), protocol: StreamProtocol.mp4, providerId: 'good'));
    final runner = SafeProviderRunner(providers: [bad, good], health: {
      'bad': const ProviderHealth(successes: 10, failures: 0, averageLatencyMs: 1),
      'good': const ProviderHealth(successes: 5, failures: 0, averageLatencyMs: 50),
    }, validator: const StreamValidator(UrlPolicy()));
    expect((await runner.sourcesFor(item)).providerId, 'good');
  });

  test('falls through a result that spoofs another provider identity', () async {
    final spoofed = P(
      'bad',
      StreamSource(uri: Uri.parse('https://example.test/spoof.mp4'), protocol: StreamProtocol.mp4, providerId: 'bad'),
      resultProviderId: 'good',
    );
    final good = P('good', StreamSource(uri: Uri.parse('https://example.test/good.mp4'), protocol: StreamProtocol.mp4, providerId: 'good'));
    final runner = SafeProviderRunner(
      providers: [spoofed, good],
      health: {
        'bad': const ProviderHealth(successes: 10, failures: 0, averageLatencyMs: 1),
        'good': const ProviderHealth(successes: 5, failures: 0, averageLatencyMs: 50),
      },
      validator: const StreamValidator(UrlPolicy()),
    );
    final result = await runner.sourcesFor(item);
    expect(result.providerId, 'good');
    expect(result.sources.single.uri.path, '/good.mp4');
  });

  test('drops a source that spoofs another provider identity', () async {
    final spoofed = P('bad', StreamSource(uri: Uri.parse('https://example.test/spoof.mp4'), protocol: StreamProtocol.mp4, providerId: 'good'));
    final good = P('good', StreamSource(uri: Uri.parse('https://example.test/good.mp4'), protocol: StreamProtocol.mp4, providerId: 'good'));
    final runner = SafeProviderRunner(
      providers: [spoofed, good],
      health: {
        'bad': const ProviderHealth(successes: 10, failures: 0, averageLatencyMs: 1),
        'good': const ProviderHealth(successes: 5, failures: 0, averageLatencyMs: 50),
      },
      validator: const StreamValidator(UrlPolicy()),
    );
    final result = await runner.sourcesFor(item);
    expect(result.providerId, 'good');
    expect(result.sources.single.uri.path, '/good.mp4');
  });
}
