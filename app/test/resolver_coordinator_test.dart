import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/domain/validation.dart';
import 'package:the_only/core/resolvers/resolver.dart';
import 'package:the_only/core/resolvers/resolver_coordinator.dart';
import 'package:the_only/core/resolvers/resolver_registry.dart';
import 'package:the_only/core/security/url_policy.dart';

class R implements StreamResolver {
  @override String get id => 'r';
  @override bool supports(Uri uri) => uri.host == 'embed.test';
  @override Future<List<StreamSource>> resolve(Uri uri) async => [StreamSource(uri: Uri.parse('https://cdn.test/a.m3u8'), protocol: StreamProtocol.hls, providerId: 'r')];
}

void main() {
  test('selects resolver and returns validated streams', () async {
    final coordinator = ResolverCoordinator(ResolverRegistry([R()]), const StreamValidator(UrlPolicy()));
    expect((await coordinator.resolve(Uri.parse('https://embed.test/x'))).length, 1);
    expect(await coordinator.resolve(Uri.parse('https://other.test/x')), isEmpty);
  });
}
