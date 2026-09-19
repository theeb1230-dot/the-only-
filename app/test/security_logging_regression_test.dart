import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/security/url_policy.dart';

void main() {
  test('sanitized URI never leaks credentials, query, fragment or token values', () {
    final input = Uri.parse('https://user:pass@x.test/a?token=secret#part');
    final safe = sanitizedUriForLog(input);
    expect(safe, 'https://x.test/a');
    for (final forbidden in ['user', 'pass', 'token', 'secret', 'part', '?', '#', '@']) {
      expect(safe.contains(forbidden), isFalse, reason: 'leaked $forbidden');
    }
  });

  test('URL policy fails closed for user-info and unsafe redirects', () {
    const policy = UrlPolicy(allowedHosts: {'x.test'});
    expect(policy.allows(Uri.parse('https://user:pass@x.test/a')), isFalse);
    expect(policy.allows(Uri.parse('https://x.test/a')), isTrue);
    expect(policy.allows(Uri.parse('https://other.test/a')), isFalse);
    expect(policy.allowsRedirect(Uri.parse('https://x.test/a'), Uri.parse('http://x.test/b')), isFalse);
    expect(policy.allowsRedirect(Uri.parse('https://x.test/a'), Uri.parse('https://other.test/b')), isFalse);
  });
}
