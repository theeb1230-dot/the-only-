import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/player/playback.dart';
import 'package:the_only/core/player/protocol_adapters.dart';

void main() {
  test('native player routes HLS MP4 and DASH through protocol adapters', () async {
    final opened = <StreamProtocol>[];
    final coordinator = PlaybackCoordinator(standardPlaybackAdapters(
      opener: (source) async => opened.add(source.protocol),
      stopper: () async {},
    ));

    for (final protocol in [StreamProtocol.hls, StreamProtocol.mp4, StreamProtocol.dash]) {
      await coordinator.open(StreamSource(
        uri: Uri.parse('https://media.example.test/${protocol.name}'),
        protocol: protocol,
        providerId: 'legal-test',
      ));
    }

    expect(opened, [StreamProtocol.hls, StreamProtocol.mp4, StreamProtocol.dash]);
  });

  test('embed never silently enters native playback adapters', () {
    final coordinator = PlaybackCoordinator(standardPlaybackAdapters(
      opener: (_) async {},
      stopper: () async {},
    ));
    final embed = StreamSource(
      uri: Uri.parse('https://embed.example.test/watch'),
      protocol: StreamProtocol.embed,
      providerId: 'legal-test',
    );
    expect(() => coordinator.adapterFor(embed), throwsUnsupportedError);
  });
}
