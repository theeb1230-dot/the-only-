import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/settings/section_settings.dart';

void main() {
  test('optional section is disabled by default and can be enabled locally', () {
    final settings = SectionSettings();
    expect(settings.isEnabled(SectionId.optional), isFalse);
    expect(settings.visibleSections.length, 5);
    settings.setEnabled(SectionId.optional, true);
    expect(settings.isEnabled(SectionId.optional), isTrue);
    expect(settings.visibleSections.length, 6);
  });
}
