enum ProviderCapability { search, movies, series, liveTv, epg, resolve, download }

class ProviderDescriptor {
  const ProviderDescriptor({required this.id, required this.name, required this.capabilities});
  final String id;
  final String name;
  final Set<ProviderCapability> capabilities;

  bool supports(ProviderCapability capability) => capabilities.contains(capability);
}
