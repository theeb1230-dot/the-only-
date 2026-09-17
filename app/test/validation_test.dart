import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/domain/validation.dart';
import 'package:the_only/core/security/url_policy.dart';

void main() {
  test('rejects insecure or providerless stream sources', () {
    const validator = StreamValidator(UrlPolicy());
    expect(validator.isValid(StreamSource(uri: Uri.parse('https://example.test/a.mp4'), protocol: StreamProtocol.mp4, providerId: 'p')), isTrue);
    expect(validator.isValid(StreamSource(uri: Uri.parse('http://example.test/a.mp4'), protocol: StreamProtocol.mp4, providerId: 'p')), isFalse);
    expect(validator.isValid(StreamSource(uri: Uri.parse('https://example.test/a.mp4'), protocol: StreamProtocol.mp4, providerId: ' ')), isFalse);
  });
}
