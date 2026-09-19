import 'package:shared_preferences/shared_preferences.dart';

import '../settings/provider_preferences.dart';
import 'health.dart';
import 'provider.dart';
import 'provider_health_store.dart';

class ProductProviderSelector {
  ProductProviderSelector({required this.health, required this.preferences});

  static const _prefix = 'the_only.provider.';
  final ProviderHealthStore health;
  final SharedPreferences preferences;

  List<MediaProvider> order(Iterable<MediaProvider> providers) {
    final enabled = providers.where((provider) => preferences.getBool('$_prefix${provider.id}.enabled') ?? true).toList(growable: false);
    enabled.sort((a, b) {
      final ap = preferences.getInt('$_prefix${a.id}.priority') ?? 0;
      final bp = preferences.getInt('$_prefix${b.id}.priority') ?? 0;
      final byPriority = bp.compareTo(ap);
      if (byPriority != 0) return byPriority;
      final byHealth = health.health(b.id).score.compareTo(health.health(a.id).score);
      return byHealth != 0 ? byHealth : a.id.compareTo(b.id);
    });
    return enabled;
  }

  List<ProviderPreference> snapshot(Iterable<MediaProvider> providers) => [
    for (final provider in order(providers))
      ProviderPreference(
        id: provider.id,
        enabled: true,
        priority: preferences.getInt('$_prefix${provider.id}.priority') ?? 0,
      ),
  ];
}
