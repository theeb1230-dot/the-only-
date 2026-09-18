import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/providers/legal_demo_provider.dart';

void main() {
  test('legal provider returns searchable content and playable source', () async {
    final provider = LegalDemoProvider();
    final results = await provider.search('bunny');
    expect(results, hasLength(1));
    final resolved = await provider.sourcesFor(results.single);
    expect(resolved.providerId, provider.id);
    expect(resolved.sources, isNotEmpty);
    expect(resolved.sources.single.uri.scheme, 'https');
    expect(resolved.sources.single.uri.userInfo, isEmpty);
    expect(resolved.sources.single.uri.query, isEmpty);
    expect(resolved.sources.single.uri.fragment, isEmpty);
  });
}
