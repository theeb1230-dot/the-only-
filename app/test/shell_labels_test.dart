import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/a11y/shell_labels.dart';
import 'package:the_only/core/settings/section_settings.dart';

void main() {
  Future<Map<String, String>> labelsFor(
    WidgetTester tester,
    Locale locale,
  ) async {
    final labels = <String, String>{};
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Builder(
          builder: (context) {
            labels['cinema'] = ShellLabels.section(context, SectionId.cinema);
            labels['live'] = ShellLabels.section(context, SectionId.liveTv);
            labels['library'] = ShellLabels.library(context);
            labels['settings'] = ShellLabels.settings(context);
            labels['navigation'] = ShellLabels.appNavigation(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pump();
    return labels;
  }

  testWidgets('Arabic shell labels remain RTL-friendly and user-facing',
      (tester) async {
    final labels = await labelsFor(tester, const Locale('ar'));
    expect(labels['cinema'], 'السينما');
    expect(labels['live'], 'البث المباشر');
    expect(labels['library'], 'المكتبة');
    expect(labels['settings'], 'الإعدادات');
    expect(labels['navigation'], 'التنقل الرئيسي');
  });

  testWidgets('English shell labels are available without hard-coded Arabic',
      (tester) async {
    final labels = await labelsFor(tester, const Locale('en'));
    expect(labels['cinema'], 'Cinema');
    expect(labels['live'], 'Live TV');
    expect(labels['library'], 'Library');
    expect(labels['settings'], 'Settings');
    expect(labels['navigation'], 'Main navigation');
  });
}
