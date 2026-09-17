import 'health.dart';

class ProviderHealthStore {
  final Map<String, int> _success = {};
  final Map<String, int> _failure = {};
  final Map<String, int> _latencyTotal = {};
  final Map<String, int> _latencySamples = {};

  void record(String id, {required bool success, required int latencyMs}) {
    final bucket = success ? _success : _failure;
    bucket[id] = (bucket[id] ?? 0) + 1;
    _latencyTotal[id] = (_latencyTotal[id] ?? 0) + latencyMs.clamp(0, 1 << 30);
    _latencySamples[id] = (_latencySamples[id] ?? 0) + 1;
  }

  ProviderHealth health(String id) {
    final samples = _latencySamples[id] ?? 0;
    return ProviderHealth(
      successes: _success[id] ?? 0,
      failures: _failure[id] ?? 0,
      averageLatencyMs: samples == 0 ? 0 : (_latencyTotal[id]! ~/ samples),
    );
  }
}
