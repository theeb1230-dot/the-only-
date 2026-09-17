import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/app_section.dart';
import 'package:the_only/core/domain/section_policy.dart';

void main() {
  test('only optional section is disabled by default', () {
    expect(UnifiedSection.values.where(enabledByDefault).length, 5);
    expect(enabledByDefault(UnifiedSection.optional), isFalse);
  });
}
