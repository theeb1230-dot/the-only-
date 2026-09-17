import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/models.dart';

void main() {
  test('stream source keeps normalized provider and protocol data', () {
    final source = StreamSource(
      uri: Uri.parse('https://example.test/video.m3u8'),
      protocol: StreamProtocol.hls,
      providerId: 'fixture',
      quality: '1080p',
    );
    expect(source.protocol, StreamProtocol.hls);
    expect(source.providerId, 'fixture');
    expect(source.uri.scheme, 'https');
    expect(source.quality, '1080p');
  });
}
