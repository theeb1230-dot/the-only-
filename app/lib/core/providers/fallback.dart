import 'health.dart';
import 'provider.dart';

List<MediaProvider> orderProviders(
  Iterable<MediaProvider> providers,
  Map<String, ProviderHealth> health,
) {
  final ordered = providers.toList(growable: false);
  ordered.sort((a, b) {
    final aScore = health[a.id]?.score ?? 0;
    final bScore = health[b.id]?.score ?? 0;
    final byHealth = bScore.compareTo(aScore);
    return byHealth != 0 ? byHealth : a.id.compareTo(b.id);
  });
  return ordered;
}
