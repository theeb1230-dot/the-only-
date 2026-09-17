import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/content_filter.dart';

void main() {
  test('optional content is blocked until locally enabled', () {
    expect(const ContentVisibilityPolicy(optionalSectionEnabled: false).allows(optionalContent: true), isFalse);
    expect(const ContentVisibilityPolicy(optionalSectionEnabled: true).allows(optionalContent: true), isTrue);
    expect(const ContentVisibilityPolicy(optionalSectionEnabled: false).allows(optionalContent: false), isTrue);
  });
}
