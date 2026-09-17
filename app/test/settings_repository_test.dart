import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/data/storage.dart';
import 'package:the_only/core/settings/section_settings.dart';
import 'package:the_only/core/settings/settings_repository.dart';

void main() {
  test('persists optional section enablement', () async {
    final repository = SettingsRepository(MemoryKeyValueStore());
    expect((await repository.load()).isEnabled(SectionId.optional), isFalse);
    await repository.setEnabled(SectionId.optional, true);
    expect((await repository.load()).isEnabled(SectionId.optional), isTrue);
  });
}
