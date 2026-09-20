import '../domain/models.dart';
import 'provider.dart';

/// Built-in public-media catalog used as a real, non-empty runtime baseline.
/// All media points to openly published sample assets. Network providers can be
/// layered on top without leaving the six core interfaces blank when remote
/// services are unavailable.
final class LegalDemoProvider implements MediaProvider {
  @override
  String get id => 'legal-demo';

  static const _catalog = <MediaItem>[
    MediaItem(
      id: 'big-buck-bunny',
      title: 'Big Buck Bunny',
      kind: MediaKind.movie,
      posterUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg',
      backdropUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg',
      overview: 'فيلم رسوم متحركة مفتوح للاختبار وتشغيل الفيديو داخل التطبيق.',
      year: 2008,
      rating: 8.0,
    ),
    MediaItem(
      id: 'elephants-dream',
      title: 'Elephants Dream',
      kind: MediaKind.movie,
      posterUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg',
      backdropUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg',
      overview: 'فيلم مفتوح المصدر لاختبار المشغل والمصادر عالية الجودة.',
      year: 2006,
      rating: 7.2,
    ),
    MediaItem(
      id: 'for-bigger-blazes',
      title: 'For Bigger Blazes',
      kind: MediaKind.movie,
      posterUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg',
      overview: 'مقطع عام قصير لاختبار بدء التشغيل السريع.',
      rating: 7.0,
    ),
    MediaItem(
      id: 'for-bigger-escapes',
      title: 'For Bigger Escapes',
      kind: MediaKind.movie,
      posterUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerEscapes.jpg',
      overview: 'مقطع عام لاختبار الاستئناف والتشغيل على الأجهزة المختلفة.',
      rating: 7.1,
    ),
    MediaItem(
      id: 'for-bigger-fun',
      title: 'For Bigger Fun',
      kind: MediaKind.movie,
      posterUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerFun.jpg',
      overview: 'محتوى عام مدمج ضمن كتالوج التشغيل الأساسي.',
      rating: 7.0,
    ),
    MediaItem(
      id: 'for-bigger-joyrides',
      title: 'For Bigger Joyrides',
      kind: MediaKind.movie,
      posterUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerJoyrides.jpg',
      overview: 'مقطع عام لاختبار التنقل بين النتائج والمصادر.',
      rating: 7.0,
    ),
  ];

  static final _streams = <String, Uri>{
    'big-buck-bunny': Uri.parse('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'),
    'elephants-dream': Uri.parse('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4'),
    'for-bigger-blazes': Uri.parse('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4'),
    'for-bigger-escapes': Uri.parse('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4'),
    'for-bigger-fun': Uri.parse('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4'),
    'for-bigger-joyrides': Uri.parse('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4'),
  };

  @override
  Future<List<MediaItem>> search(String query) async {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return _catalog;
    return _catalog
        .where((item) =>
            item.title.toLowerCase().contains(needle) ||
            (item.overview?.toLowerCase().contains(needle) ?? false))
        .toList(growable: false);
  }

  @override
  Future<ProviderResult> sourcesFor(MediaItem item) async {
    final uri = _streams[item.id];
    final sources = uri == null
        ? const <StreamSource>[]
        : <StreamSource>[
            StreamSource(
              uri: uri,
              protocol: StreamProtocol.mp4,
              providerId: id,
              quality: '1080p',
            ),
          ];
    return ProviderResult(providerId: id, sources: sources);
  }
}
