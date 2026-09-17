import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/security/sanitized_uri.dart';

void main() {
  test('sanitized URI logs never expose credentials query fragment or secrets', () {
    final input = Uri.parse('https://user:pass@x.test/a?token=secret#part');
    final safe = sanitizeUriForLog(input);

    expect(safe, 'https://x.test/a');
    expect(safe, isNot(contains('user')));
    expect(safe, isNot(contains('pass')));
    expect(safe, isNot(contains('token')));
    expect(safe, isNot(contains('secret')));
    expect(safe, isNot(contains('part')));
    expect(safe, isNot(contains('?')));
    expect(safe, isNot(contains('#')));
    expect(safe, isNot(contains('@')));
  });
}
