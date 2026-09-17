import '../domain/provider_status.dart';
import 'health.dart';

ProviderState classifyHealth(ProviderHealth health) {
  final total = health.successes + health.failures;
  if (total == 0) return ProviderState.unknown;
  if (health.successes == 0) return ProviderState.offline;
  if (health.score >= 0.75) return ProviderState.healthy;
  return ProviderState.degraded;
}
