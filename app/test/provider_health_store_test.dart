import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/providers/provider_health_store.dart';

void main() {
  test('accumulates success failure and average latency', () {
    final store = ProviderHealthStore();
    store.record('p', success: true, latencyMs: 100);
    store.record('p', success: false, latencyMs: 300);
    final health = store.health('p');
    expect(health.successes, 1);
    expect(health.failures, 1);
    expect(health.averageLatencyMs, 200);
  });
}
