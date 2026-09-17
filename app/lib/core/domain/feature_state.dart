enum FeatureReadiness { unavailable, experimental, beta, stable }

class FeatureState {
  const FeatureState({required this.id, required this.readiness});
  final String id;
  final FeatureReadiness readiness;
  bool get userVisible => readiness != FeatureReadiness.unavailable;
}
