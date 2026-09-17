import 'provider.dart';

class ProviderRegistry {
  ProviderRegistry(Iterable<MediaProvider> providers)
      : _providers = {for (final provider in providers) provider.id: provider};

  final Map<String, MediaProvider> _providers;

  Iterable<MediaProvider> get all => _providers.values;

  MediaProvider? byId(String id) => _providers[id];
}
