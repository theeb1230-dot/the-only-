import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/providers/fallback.dart';
import 'package:the_only/core/providers/health.dart';
import 'package:the_only/core/providers/provider.dart';

class FakeProvider implements MediaProvider {
  FakeProvider(this.id);
  @override
  final String id;
  @override
  Future<List<MediaItem>> search(String query) async => const [];
  @override
  Future<ProviderResult> sourcesFor(MediaItem item) async => ProviderResult(providerId: id, sources: const []);
}

void main() {
  test('orders providers by health score', () {
    final slow = FakeProvider('slow');
    final fast = FakeProvider('fast');
    final result = orderProviders([slow, fast], {
      'slow': const ProviderHealth(successes: 5, failures: 5, averageLatencyMs: 1500),
      'fast': const ProviderHealth(successes: 9, failures: 1, averageLatencyMs: 100),
    });
    expect(result.first.id, 'fast');
  });
}
