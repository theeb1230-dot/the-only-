import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/security/url_policy.dart';

void main() {
  test('allows HTTPS and rejects insecure remote HTTP by default', () {
    const policy = UrlPolicy();
    expect(policy.allows(Uri.parse('https://example.test/a.m3u8')), isTrue);
    expect(policy.allows(Uri.parse('http://example.test/a.m3u8')), isFalse);
  });
}
