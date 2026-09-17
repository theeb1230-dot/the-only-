import '../../core/providers/health.dart';
import '../../core/providers/provider_health_store.dart';
import '../../core/providers/provider_registry.dart';
import '../../core/settings/provider_preferences.dart';

class ProviderToolState {
  const ProviderToolState({required this.id, required this.enabled, required this.priority, required this.health});
  final String id;
  final bool enabled;
  final int priority;
  final ProviderHealth health;
}

class ProvidersController {
  ProvidersController(this.registry, this.healthStore, Iterable<ProviderPreference> preferences)
      : _preferences = {for (final preference in preferences) preference.id: preference};

  final ProviderRegistry registry;
  final ProviderHealthStore healthStore;
  final Map<String, ProviderPreference> _preferences;

  List<ProviderToolState> states() {
    final values = registry.all.map((provider) {
      final preference = _preferences[provider.id] ?? ProviderPreference(id: provider.id);
      return ProviderToolState(
        id: provider.id,
        enabled: preference.enabled,
        priority: preference.priority,
        health: healthStore.health(provider.id),
      );
    }).toList();
    values.sort((a, b) {
      if (a.enabled != b.enabled) return a.enabled ? -1 : 1;
      final byPriority = b.priority.compareTo(a.priority);
      if (byPriority != 0) return byPriority;
      final byHealth = b.health.score.compareTo(a.health.score);
      return byHealth != 0 ? byHealth : a.id.compareTo(b.id);
    });
    return List.unmodifiable(values);
  }

  void setEnabled(String id, bool enabled) {
    final current = _preferences[id] ?? ProviderPreference(id: id);
    _preferences[id] = current.copyWith(enabled: enabled);
  }

  void setPriority(String id, int priority) {
    final current = _preferences[id] ?? ProviderPreference(id: id);
    _preferences[id] = current.copyWith(priority: priority);
  }

  void recordProbe(String id, {required bool success, required int latencyMs}) {
    if (registry.byId(id) == null) throw ArgumentError.value(id, 'id', 'unknown provider');
    healthStore.record(id, success: success, latencyMs: latencyMs);
  }
}
