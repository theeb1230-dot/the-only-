import '../domain/models.dart';
import 'provider.dart';

/// A deliberately legal, deterministic provider backed by public MDN sample media.
/// It proves the real provider -> results -> sources product path without
/// scraping, credentials, DRM bypass, or relying on test-only fixtures.
final class LegalDemoProvider implements MediaProvider {
  @override
  String get id => 'legal-demo';

  static const _catalog = <MediaItem>[
    MediaItem(id: 'mdn-flower', title: 'MDN Flower Sample', kind: MediaKind.movie),
  ];

  static final Uri _sampleUri = Uri.parse(
    'https://mdn.github.io/shared-assets/videos/flower.mp4',
  );

  @override
  Future<List<MediaItem>> search(String query) async {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return _catalog;
    return _catalog
        .where((item) => item.title.toLowerCase().contains(needle))
        .toList(growable: false);
  }

  @override
  Future<ProviderResult> sourcesFor(MediaItem item) async {
    final sources = item.id == 'mdn-flower'
        ? <StreamSource>[
            StreamSource(
              uri: _sampleUri,
              protocol: StreamProtocol.mp4,
              providerId: id,
              quality: 'sample',
            ),
          ]
        : const <StreamSource>[];
    return ProviderResult(providerId: id, sources: sources);
  }
}
