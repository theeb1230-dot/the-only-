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
        final valid = result.sources.where(validator.isValid).toList(growable: false);
        if (valid.isNotEmpty) return ProviderResult(providerId: result.providerId, sources: valid);
      } catch (_) {
        // Failure is isolated to this provider; continue through ordered fallback.
      }
    }
    throw StateError('No valid provider stream available');
  }
}
