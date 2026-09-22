import '../domain/models.dart';
import '../domain/validation.dart';
import 'fallback.dart';
import 'health.dart';
import 'provider.dart';

class SafeProviderRunner {
  SafeProviderRunner({required this.providers, required this.health, required this.validator, this.timeout = const Duration(seconds: 8)});
  final Iterable<MediaProvider> providers;
  final Map<String, ProviderHealth> health;
  final StreamValidator validator;
  final Duration timeout;

  Future<ProviderResult> sourcesFor(MediaItem item) async {
    for (final provider in orderProviders(providers, health)) {
      try {
        final result = await provider.sourcesFor(item).timeout(timeout);
        // Provider identity is part of the trust boundary. A provider must not
        // attribute a result or an individual source to another registered
        // provider, otherwise health/ranking and diagnostics become misleading.
        if (result.providerId != provider.id) continue;
        final valid = result.sources
            .where((source) => source.providerId == provider.id && validator.isValid(source))
            .toList(growable: false);
        if (valid.isNotEmpty) return ProviderResult(providerId: provider.id, sources: valid);
      } catch (_) {
        // Failure is isolated to this provider; continue through ordered fallback.
      }
    }
    throw StateError('No valid provider stream available');
  }
}
