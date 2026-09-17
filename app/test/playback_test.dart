import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/player/playback.dart';

class FakeAdapter implements PlaybackAdapter {
  FakeAdapter(this.protocol);
  final StreamProtocol protocol;
  bool opened = false;
  @override
  bool supports(StreamProtocol value) => value == protocol;
  @override
  Future<void> open(StreamSource source) async => opened = true;
  @override
  Future<void> stop() async => opened = false;
}

void main() {
  test('selects adapter by normalized protocol', () async {
    final hls = FakeAdapter(StreamProtocol.hls);
    final coordinator = PlaybackCoordinator([hls]);
    final source = StreamSource(uri: Uri.parse('https://example.test/a.m3u8'), protocol: StreamProtocol.hls, providerId: 'fixture');
    await coordinator.open(source);
    expect(hls.opened, isTrue);
  });
}
