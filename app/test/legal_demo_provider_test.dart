import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/providers/legal_demo_provider.dart';

void main() {
  test('public media provider exposes rich catalog and playable source', () async {
    final provider = LegalDemoProvider();
    final catalog = await provider.search('');
    expect(catalog.length, greaterThanOrEqualTo(6));
    expect(catalog.every((item) => item.posterUrl != null), isTrue);

    final results = await provider.search('Bunny');
    expect(results, hasLength(1));
    expect(results.single.title, 'Big Buck Bunny');
    final resolved = await provider.sourcesFor(results.single);
    expect(resolved.providerId, provider.id);
    expect(resolved.sources, isNotEmpty);
    final uri = resolved.sources.single.uri;
    expect(uri.scheme, 'https');
    expect(uri.host, 'commondatastorage.googleapis.com');
    expect(uri.userInfo, isEmpty);
    expect(uri.query, isEmpty);
    expect(uri.fragment, isEmpty);
  });
}
