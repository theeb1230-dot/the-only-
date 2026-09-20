import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/settings/section_settings.dart';
import 'package:the_only/core/settings/settings_screen.dart';

void main() {
  testWidgets('settings toggles optional section', (tester) async {
    final settings = SectionSettings();
    SectionId? changed;
    bool? enabled;
    await tester.pumpWidget(MaterialApp(home: SectionSettingsScreen(
      settings: settings,
      onChanged: (id, value) { changed = id; enabled = value; },
    )));
    expect(find.text('الأقسام'), findsOneWidget);
    expect(find.text('السينما'), findsOneWidget);
    expect(find.text('تشخيص النظام'), findsOneWidget);
    await tester.tap(find.byKey(const Key('section-optional')));
    await tester.pump();
    expect(settings.isEnabled(SectionId.optional), isTrue);
    expect(changed, SectionId.optional);
    expect(enabled, isTrue);
  });
}
