enum MediaKind { movie, series, live }

enum StreamProtocol { hls, mp4, dash, embed }

class MediaItem {
  const MediaItem({required this.id, required this.title, required this.kind});
  final String id;
  final String title;
  final MediaKind kind;
}

class StreamSource {
  const StreamSource({
    required this.uri,
    required this.protocol,
    required this.providerId,
    this.quality,
  });

  final Uri uri;
  final StreamProtocol protocol;
  final String providerId;
  final String? quality;
}

class ProviderResult {
  const ProviderResult({required this.providerId, required this.sources});
  final String providerId;
  final List<StreamSource> sources;
}
