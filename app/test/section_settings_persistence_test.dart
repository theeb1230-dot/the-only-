import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_only/core/settings/section_settings.dart';

void main() {
  test('sixth-section gate persists locally and remains disabled by default', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    final initial = SectionSettings(preferences: preferences);
    expect(initial.isEnabled(SectionId.optional), isFalse);

    initial.setEnabled(SectionId.optional, true);
    await Future<void>.delayed(Duration.zero);

    final restored = SectionSettings(preferences: preferences);
    expect(restored.isEnabled(SectionId.optional), isTrue);

    restored.setEnabled(SectionId.optional, false);
    await Future<void>.delayed(Duration.zero);
    expect(
      SectionSettings(preferences: preferences).isEnabled(SectionId.optional),
      isFalse,
    );
  });

  test('settings never persist a state with every section disabled', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final settings = SectionSettings(preferences: preferences);

    for (final id in SectionId.values) {
      settings.setEnabled(id, false);
    }
    await Future<void>.delayed(Duration.zero);

    final restored = SectionSettings(preferences: preferences);
    expect(restored.visibleSections, isNotEmpty);
    expect(restored.isEnabled(SectionId.cinema), isTrue);
  });
}
