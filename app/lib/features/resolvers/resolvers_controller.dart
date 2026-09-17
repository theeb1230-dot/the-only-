import '../../core/domain/models.dart';
import '../../core/resolvers/resolver_coordinator.dart';
import '../../core/resolvers/resolver_registry.dart';

class ResolversController {
  ResolversController(this.registry, this.coordinator);

  final ResolverRegistry registry;
  final ResolverCoordinator coordinator;

  bool supports(Uri uri) => registry.forUri(uri) != null;

  Future<List<StreamSource>> resolve(Uri uri) async {
    try {
      return await coordinator.resolve(uri);
    } catch (_) {
      return const [];
    }
  }
}
