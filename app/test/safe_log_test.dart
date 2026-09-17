import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/safe_log.dart';

void main() {
  test('removes query and fragment from logged URI', () {
    expect(safeUriForLog(Uri.parse('https://x.test/a?token=secret#part')), 'https://x.test/a');
  });
}
