import 'package:shared_preferences/shared_preferences.dart';

enum SectionId { cinema, liveTv, sources, resolvers, tools, optional }

class SectionSettings {
  SectionSettings({Map<SectionId, bool>? enabled, this.preferences})
      : _enabled = {
          for (final id in SectionId.values)
            id: preferences?.getBool(_key(id)) ?? id != SectionId.optional,
          ...?enabled,
        } {
    _ensureVisibleSection();
  }

  static const _prefix = 'the_only.section.enabled.';
  final SharedPreferences? preferences;
  final Map<SectionId, bool> _enabled;

  static String _key(SectionId id) => '$_prefix${id.name}';

  bool isEnabled(SectionId id) => _enabled[id] ?? false;

  void setEnabled(SectionId id, bool value) {
    _enabled[id] = value;
    _ensureVisibleSection();
    _persist();
  }

  List<SectionId> get visibleSections =>
      SectionId.values.where(isEnabled).toList(growable: false);

  void _ensureVisibleSection() {
    if (!SectionId.values.any(isEnabled)) {
      _enabled[SectionId.cinema] = true;
    }
  }

  void _persist() {
    final target = preferences;
    if (target == null) return;
    for (final entry in _enabled.entries) {
      target.setBool(_key(entry.key), entry.value);
    }
  }
}
