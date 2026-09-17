import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/download_policy.dart';
import 'package:the_only/core/domain/models.dart';

void main() {
  test('embed sources are not sent to direct download queue', () {
    expect(isDownloadable(StreamSource(uri: Uri.parse('https://x.test/e'), protocol: StreamProtocol.embed, providerId: 'p')), isFalse);
    expect(isDownloadable(StreamSource(uri: Uri.parse('https://x.test/a.mp4'), protocol: StreamProtocol.mp4, providerId: 'p')), isTrue);
  });
}
