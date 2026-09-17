import '../data/storage.dart';
import 'section_settings.dart';

class SettingsRepository {
  SettingsRepository(this.store);
  final KeyValueStore store;

  static String _key(SectionId id) => 'section.${id.name}.enabled';

  Future<SectionSettings> load() async {
    final overrides = <SectionId, bool>{};
    for (final id in SectionId.values) {
      final value = await store.read(_key(id));
      if (value != null) overrides[id] = value == 'true';
    }
    return SectionSettings(enabled: overrides);
  }

  Future<void> setEnabled(SectionId id, bool enabled) =>
      store.write(_key(id), enabled.toString());
}
