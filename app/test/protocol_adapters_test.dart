import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/player/playback.dart';
import 'package:the_only/core/player/protocol_adapters.dart';

void main() {
  test('standard adapters open exact selected HLS MP4 and DASH sources', () async {
    final opened = <StreamSource>[];
    final adapters = standardPlaybackAdapters(
      opener: (source) async => opened.add(source),
      stopper: () async {},
    );
    final coordinator = PlaybackCoordinator(adapters);
    final sources = [
      StreamSource(uri: Uri.parse('https://media.example.test/live.m3u8'), protocol: StreamProtocol.hls, providerId: 'legal'),
      StreamSource(uri: Uri.parse('https://media.example.test/movie.mp4'), protocol: StreamProtocol.mp4, providerId: 'legal'),
      StreamSource(uri: Uri.parse('https://media.example.test/manifest.mpd'), protocol: StreamProtocol.dash, providerId: 'legal'),
    ];

    for (final source in sources) {
      expect(adapters.any((adapter) => adapter.supports(source.protocol)), isTrue);
      await coordinator.open(source);
    }

    expect(opened, sources);
    expect(adapters.any((adapter) => adapter.supports(StreamProtocol.embed)), isFalse);
  });
}
