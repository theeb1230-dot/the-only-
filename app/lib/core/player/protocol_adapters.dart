import '../domain/models.dart';
import 'playback.dart';

typedef SourceOpener = Future<void> Function(StreamSource source);
typedef StopPlayback = Future<void> Function();

class ProtocolPlaybackAdapter implements PlaybackAdapter {
  ProtocolPlaybackAdapter({required this.protocol, required this.opener, required this.stopper});
  final StreamProtocol protocol;
  final SourceOpener opener;
  final StopPlayback stopper;

  @override
  bool supports(StreamProtocol value) => value == protocol;
  @override
  Future<void> open(StreamSource source) => opener(source);
  @override
  Future<void> stop() => stopper();
}

List<PlaybackAdapter> standardPlaybackAdapters({required SourceOpener opener, required StopPlayback stopper}) => [
  for (final protocol in [StreamProtocol.hls, StreamProtocol.mp4, StreamProtocol.dash])
    ProtocolPlaybackAdapter(protocol: protocol, opener: opener, stopper: stopper),
];
