import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/domain/source_selection.dart';

void main() {
  test('selects highest quality normalized stream', () {
    final low = StreamSource(uri: Uri.parse('https://x.test/1'), protocol: StreamProtocol.mp4, providerId: 'p', quality: '480p');
    final high = StreamSource(uri: Uri.parse('https://x.test/2'), protocol: StreamProtocol.mp4, providerId: 'p', quality: '1080p');
    expect(selectBestStream([low, high])?.quality, '1080p');
    expect(selectBestStream(const []), isNull);
  });
}
