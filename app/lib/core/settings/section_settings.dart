enum SectionId { cinema, liveTv, sources, resolvers, tools, optional }

class SectionSettings {
  SectionSettings({Map<SectionId, bool>? enabled})
      : _enabled = {
          for (final id in SectionId.values) id: id != SectionId.optional,
          ...?enabled,
        };

  final Map<SectionId, bool> _enabled;

  bool isEnabled(SectionId id) => _enabled[id] ?? false;

  void setEnabled(SectionId id, bool value) => _enabled[id] = value;

  List<SectionId> get visibleSections =>
      SectionId.values.where(isEnabled).toList(growable: false);
}
