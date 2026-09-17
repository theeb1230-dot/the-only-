enum PlaybackErrorKind { unsupportedProtocol, openFailed, interrupted, unknown }

class PlaybackFailure implements Exception {
  const PlaybackFailure(this.kind, this.message);
  final PlaybackErrorKind kind;
  final String message;
  @override String toString() => 'PlaybackFailure(${kind.name}): $message';
}
