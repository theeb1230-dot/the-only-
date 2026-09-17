class ProviderHealth {
  const ProviderHealth({
    required this.successes,
    required this.failures,
    required this.averageLatencyMs,
  });

  final int successes;
  final int failures;
  final int averageLatencyMs;

  double get score {
    final total = successes + failures;
    if (total == 0) return 0;
    final reliability = successes / total;
    final latencyFactor = 1 / (1 + (averageLatencyMs / 1000));
    return reliability * 0.8 + latencyFactor * 0.2;
  }
}
