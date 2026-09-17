enum ProviderErrorKind { timeout, unavailable, invalidResponse, unsupported, unknown }

class ProviderFailure implements Exception {
  const ProviderFailure(this.kind, this.message);
  final ProviderErrorKind kind;
  final String message;
  @override String toString() => 'ProviderFailure(${kind.name}): $message';
}
