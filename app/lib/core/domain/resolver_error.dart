enum ResolverErrorKind { unsupported, timeout, invalidResponse, unavailable, unknown }

class ResolverFailure implements Exception {
  const ResolverFailure(this.kind, this.message);
  final ResolverErrorKind kind;
  final String message;
  @override String toString() => 'ResolverFailure(${kind.name}): $message';
}
