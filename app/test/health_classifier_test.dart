import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/provider_status.dart';
import 'package:the_only/core/providers/health.dart';
import 'package:the_only/core/providers/health_classifier.dart';

void main() {
  test('classifies unknown offline and healthy states', () {
    expect(classifyHealth(const ProviderHealth(successes: 0, failures: 0, averageLatencyMs: 0)), ProviderState.unknown);
    expect(classifyHealth(const ProviderHealth(successes: 0, failures: 2, averageLatencyMs: 10)), ProviderState.offline);
    expect(classifyHealth(const ProviderHealth(successes: 10, failures: 0, averageLatencyMs: 10)), ProviderState.healthy);
  });
}
