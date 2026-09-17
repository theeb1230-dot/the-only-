import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/domain/source_identity.dart';

void main() {
  test('deduplicates identical normalized streams', () {
    final source = StreamSource(uri: Uri.parse('https://example.test/a.m3u8'), protocol: StreamProtocol.hls, providerId: 'p', quality: '1080p');
    expect(deduplicateStreams([source, source]).length, 1);
  });
}
