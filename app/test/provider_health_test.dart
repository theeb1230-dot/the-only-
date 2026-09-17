import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/providers/health.dart';

void main() {
  test('reliable fast provider scores above failing slow provider', () {
    const healthy = ProviderHealth(successes: 9, failures: 1, averageLatencyMs: 200);
    const unhealthy = ProviderHealth(successes: 2, failures: 8, averageLatencyMs: 2000);
    expect(healthy.score, greaterThan(unhealthy.score));
  });

  test('provider with no observations has zero score', () {
    const unknown = ProviderHealth(successes: 0, failures: 0, averageLatencyMs: 0);
    expect(unknown.score, 0);
  });
}
