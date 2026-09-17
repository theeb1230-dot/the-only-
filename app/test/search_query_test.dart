import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/search_query.dart';

void main() {
  test('trims and collapses whitespace', () {
    expect(SearchQuery('  the   only  ').value, 'the only');
    expect(SearchQuery('   ').isEmpty, isTrue);
  });
}
