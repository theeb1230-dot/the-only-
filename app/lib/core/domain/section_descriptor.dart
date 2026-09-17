import 'feature_state.dart';

class SectionDescriptor {
  const SectionDescriptor({required this.id, required this.label, required this.state, this.enabledByDefault = true});
  final String id;
  final String label;
  final FeatureState state;
  final bool enabledByDefault;
}
