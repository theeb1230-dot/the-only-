import 'dart:async';
import '../domain/models.dart';
import 'fallback.dart';
import 'health.dart';
import 'provider.dart';

class ProviderRunner {
  ProviderRunner({required this.providers, required this.health, this.timeout = const Duration(seconds: 8)});
  final Iterable<MediaProvider> providers;
  final Map<String, ProviderHealth> health;
  final Duration timeout;

  Future<ProviderResult> sourcesFor(MediaItem item) async {
    Object? lastError;
    for (final provider in orderProviders(providers, health)) {
      try {
        final result = await provider.sourcesFor(item).timeout(timeout);
        if (result.sources.isNotEmpty) return result;
      } catch (error) {
        lastError = error;
      }
    }
    throw StateError('No provider returned a stream${lastError == null ? '' : ': $lastError'}');
  }
}
