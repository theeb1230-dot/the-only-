import 'package:shared_preferences/shared_preferences.dart';

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
  ProvidersController(
    this.registry,
    this.healthStore,
    Iterable<ProviderPreference> preferences, {
    this.preferencesStore,
  }) : _preferences = {for (final preference in preferences) preference.id: preference} {
    for (final provider in registry.all) {
      final id = provider.id;
      final fallback = _preferences[id] ?? ProviderPreference(id: id);
      _preferences[id] = ProviderPreference(
        id: id,
        enabled: preferencesStore?.getBool(_enabledKey(id)) ?? fallback.enabled,
        priority: preferencesStore?.getInt(_priorityKey(id)) ?? fallback.priority,
      );
    }
  }

  static const _prefix = 'the_only.provider.';
  final ProviderRegistry registry;
  final ProviderHealthStore healthStore;
  final SharedPreferences? preferencesStore;
  final Map<String, ProviderPreference> _preferences;

  static String _enabledKey(String id) => '$_prefix$id.enabled';
  static String _priorityKey(String id) => '$_prefix$id.priority';

  List<ProviderToolState> states() {
    final values = registry.all.map((provider) {
      final preference = _preferences[provider.id] ?? ProviderPreference(id: provider.id);
      return ProviderToolState(id: provider.id, enabled: preference.enabled, priority: preference.priority, health: healthStore.health(provider.id));
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
    if (registry.byId(id) == null) throw ArgumentError.value(id, 'id', 'unknown provider');
    final current = _preferences[id] ?? ProviderPreference(id: id);
    _preferences[id] = current.copyWith(enabled: enabled);
    preferencesStore?.setBool(_enabledKey(id), enabled);
  }

  void setPriority(String id, int priority) {
    if (registry.byId(id) == null) throw ArgumentError.value(id, 'id', 'unknown provider');
    final current = _preferences[id] ?? ProviderPreference(id: id);
    _preferences[id] = current.copyWith(priority: priority);
    preferencesStore?.setInt(_priorityKey(id), priority);
  }

  Future<ProviderHealth> probe(String id) async {
    final provider = registry.byId(id);
    if (provider == null) throw ArgumentError.value(id, 'id', 'unknown provider');
    final started = DateTime.now();
    var success = false;
    try {
      await provider.search('').timeout(const Duration(seconds: 5));
      success = true;
    } catch (_) {
      success = false;
    }
    final latencyMs = DateTime.now().difference(started).inMilliseconds;
    healthStore.record(id, success: success, latencyMs: latencyMs);
    return healthStore.health(id);
  }

  void recordProbe(String id, {required bool success, required int latencyMs}) {
    if (registry.byId(id) == null) throw ArgumentError.value(id, 'id', 'unknown provider');
    healthStore.record(id, success: success, latencyMs: latencyMs);
  }
}
