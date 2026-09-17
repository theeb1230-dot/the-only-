import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/security/sanitized_uri.dart';

void main() {
  test('sanitized URI never leaks credentials query or fragment', () {
    final safe = sanitizeUriForLog(Uri.parse('https://user:pass@x.test/a?token=secret#part'));
    expect(safe, 'https://x.test/a');
    expect(safe, isNot(contains('user:pass')));
    expect(safe, isNot(contains('token')));
    expect(safe, isNot(contains('secret')));
    expect(safe, isNot(contains('part')));
    expect(safe, isNot(contains('?')));
    expect(safe, isNot(contains('#')));
  });
}
