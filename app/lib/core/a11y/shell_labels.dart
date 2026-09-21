import 'package:flutter/widgets.dart';

import '../settings/section_settings.dart';

class ShellLabels {
  const ShellLabels._();

  static bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

  static String section(BuildContext context, SectionId id) {
    final ar = _isArabic(context);
    return switch (id) {
      SectionId.cinema => ar ? 'السينما' : 'Cinema',
      SectionId.liveTv => ar ? 'البث المباشر' : 'Live TV',
      SectionId.sources => ar ? 'المصادر' : 'Sources',
      SectionId.resolvers => ar ? 'المحللات' : 'Resolvers',
      SectionId.tools => ar ? 'المزودون' : 'Providers',
      SectionId.optional => ar ? 'تشخيص النظام' : 'Diagnostics',
    };
  }

  static String library(BuildContext context) =>
      _isArabic(context) ? 'المكتبة' : 'Library';

  static String settings(BuildContext context) =>
      _isArabic(context) ? 'الإعدادات' : 'Settings';

  static String resolvedStream(BuildContext context) =>
      _isArabic(context) ? 'البث المحلل' : 'Resolved stream';

  static String appNavigation(BuildContext context) =>
      _isArabic(context) ? 'التنقل الرئيسي' : 'Main navigation';
}
