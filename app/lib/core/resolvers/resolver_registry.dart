import 'resolver.dart';

class ResolverRegistry {
  ResolverRegistry(Iterable<StreamResolver> resolvers)
      : _resolvers = resolvers.toList(growable: false);

  final List<StreamResolver> _resolvers;

  StreamResolver? forUri(Uri uri) {
    for (final resolver in _resolvers) {
      if (resolver.supports(uri)) return resolver;
    }
    return null;
  }
}
