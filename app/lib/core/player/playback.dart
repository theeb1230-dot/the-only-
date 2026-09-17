import '../domain/models.dart';

abstract interface class PlaybackAdapter {
  bool supports(StreamProtocol protocol);
  Future<void> open(StreamSource source);
  Future<void> stop();
}

class PlaybackCoordinator {
  PlaybackCoordinator(Iterable<PlaybackAdapter> adapters)
      : _adapters = adapters.toList(growable: false);

  final List<PlaybackAdapter> _adapters;

  PlaybackAdapter adapterFor(StreamSource source) => _adapters.firstWhere(
        (adapter) => adapter.supports(source.protocol),
        orElse: () => throw UnsupportedError('No playback adapter for ${source.protocol.name}'),
      );

  Future<void> open(StreamSource source) => adapterFor(source).open(source);
}
