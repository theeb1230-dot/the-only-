import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/providers/legal_demo_provider.dart';

void main() {
  test('legal provider returns searchable content and playable source', () async {
    final provider = LegalDemoProvider();
    final results = await provider.search('flower');
    expect(results, hasLength(1));
    expect(results.single.title, 'MDN Flower Sample');
    final resolved = await provider.sourcesFor(results.single);
    expect(resolved.providerId, provider.id);
    expect(resolved.sources, isNotEmpty);
    final uri = resolved.sources.single.uri;
    expect(uri.scheme, 'https');
    expect(uri.host, 'mdn.github.io');
    expect(uri.userInfo, isEmpty);
    expect(uri.query, isEmpty);
    expect(uri.fragment, isEmpty);
  });
}
