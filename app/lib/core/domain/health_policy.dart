class HealthPolicy {
  const HealthPolicy({this.maxSamples = 50, this.degradedThreshold = 0.75});
  final int maxSamples;
  final double degradedThreshold;
}
