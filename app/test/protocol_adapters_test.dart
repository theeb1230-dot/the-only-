import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/player/protocol_adapters.dart';

void main() {
  test('standard adapters cover HLS MP4 and DASH', () {
    final adapters = standardPlaybackAdapters(opener: (_) async {}, stopper: () async {});
    for (final protocol in [StreamProtocol.hls, StreamProtocol.mp4, StreamProtocol.dash]) {
      expect(adapters.any((adapter) => adapter.supports(protocol)), isTrue);
    }
    expect(adapters.any((adapter) => adapter.supports(StreamProtocol.embed)), isFalse);
  });
}
