class ProviderPreference {
  const ProviderPreference({required this.id, this.enabled = true, this.priority = 0});
  final String id;
  final bool enabled;
  final int priority;

  ProviderPreference copyWith({bool? enabled, int? priority}) => ProviderPreference(
    id: id,
    enabled: enabled ?? this.enabled,
    priority: priority ?? this.priority,
  );
}

List<ProviderPreference> orderPreferences(Iterable<ProviderPreference> values) {
  final result = values.where((value) => value.enabled).toList();
  result.sort((a, b) {
    final byPriority = b.priority.compareTo(a.priority);
    return byPriority != 0 ? byPriority : a.id.compareTo(b.id);
  });
  return result;
}
