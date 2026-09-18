import '../domain/models.dart';
import 'provider.dart';

/// A deliberately legal, deterministic provider backed by public sample media.
/// It proves the real provider -> results -> sources product path without
/// scraping, credentials, DRM bypass, or relying on test-only fixtures.
final class LegalDemoProvider implements MediaProvider {
  @override
  String get id => 'legal-demo';

  static const _catalog = <MediaItem>[
    MediaItem(id: 'bbb', title: 'Big Buck Bunny', kind: MediaKind.movie),
    MediaItem(id: 'sintel', title: 'Sintel', kind: MediaKind.movie),
  ];

  @override
  Future<List<MediaItem>> search(String query) async {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return _catalog;
    return _catalog.where((item) => item.title.toLowerCase().contains(needle)).toList(growable: false);
  }

  @override
  Future<ProviderResult> sourcesFor(MediaItem item) async {
    final sources = switch (item.id) {
      'bbb' => <StreamSource>[
          StreamSource(
            uri: Uri.parse('https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'),
            protocol: StreamProtocol.mp4,
            providerId: id,
            quality: 'sample',
          ),
        ],
      'sintel' => <StreamSource>[
          StreamSource(
            uri: Uri.parse('https://storage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4'),
            protocol: StreamProtocol.mp4,
            providerId: id,
            quality: 'sample',
          ),
        ],
      _ => const <StreamSource>[],
    };
    return ProviderResult(providerId: id, sources: sources);
  }
}
