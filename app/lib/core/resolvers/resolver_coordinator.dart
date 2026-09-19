import '../domain/models.dart';
import '../domain/validation.dart';
import 'resolver_registry.dart';

class ResolverCoordinator {
  ResolverCoordinator(
    this.registry,
    this.validator, {
    this.resolverTimeout = const Duration(seconds: 5),
  });

  final ResolverRegistry registry;
  final StreamValidator validator;
  final Duration resolverTimeout;

  Future<List<StreamSource>> resolve(Uri uri) async {
    final resolver = registry.forUri(uri);
    if (resolver == null) return const [];

    try {
      final sources = await resolver.resolve(uri).timeout(resolverTimeout);
      return sources.where(validator.isValid).toList(growable: false);
    } catch (_) {
      // Resolver failures are a normal fallback condition. A broken or hung
      // resolver must never hold the Watch path open indefinitely.
      return const [];
    }
  }
}
