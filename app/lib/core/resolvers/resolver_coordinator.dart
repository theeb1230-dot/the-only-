import '../domain/models.dart';
import '../domain/validation.dart';
import 'resolver_registry.dart';

class ResolverCoordinator {
  ResolverCoordinator(this.registry, this.validator);
  final ResolverRegistry registry;
  final StreamValidator validator;

  Future<List<StreamSource>> resolve(Uri uri) async {
    final resolver = registry.forUri(uri);
    if (resolver == null) return const [];
    final sources = await resolver.resolve(uri);
    return sources.where(validator.isValid).toList(growable: false);
  }
}
