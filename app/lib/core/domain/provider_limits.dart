class ProviderLimits {
  const ProviderLimits({this.maxConcurrentSearches = 4, this.maxSourcesPerProvider = 20});
  final int maxConcurrentSearches;
  final int maxSourcesPerProvider;
}
