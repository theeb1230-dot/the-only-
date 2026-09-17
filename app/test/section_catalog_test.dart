import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/features/section_catalog.dart';

void main() {
  test('catalog defines exactly six product sections', () {
    expect(sectionPages.length, 6);
    expect(sectionPages.keys, containsAll(['cinema', 'liveTv', 'sources', 'resolvers', 'tools', 'optional']));
  });
}
