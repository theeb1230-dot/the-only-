import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/domain/validation.dart';
import 'package:the_only/core/resolvers/resolver.dart';
import 'package:the_only/core/resolvers/resolver_coordinator.dart';
import 'package:the_only/core/resolvers/resolver_registry.dart';
import 'package:the_only/core/security/url_policy.dart';
import 'package:the_only/features/resolvers/resolvers_controller.dart';

class FixtureResolver implements StreamResolver {
  FixtureResolver({this.fail = false});
  final bool fail;
  @override String get id => 'fixture-resolver';
  @override bool supports(Uri uri) => uri.host == 'fixture.test';
  @override Future<List<StreamSource>> resolve(Uri uri) async {
    if (fail) throw StateError('fixture resolver failure');
    return [StreamSource(uri: Uri.parse('https://media.fixture.test/video.m3u8'), protocol: StreamProtocol.hls, providerId: id)];
  }
}

void main() {
  const policy = UrlPolicy();

  test('Resolvers exposes support and validated resolved streams', () async {
    final registry = ResolverRegistry([FixtureResolver()]);
    final controller = ResolversController(registry, ResolverCoordinator(registry, StreamValidator(policy)));
    final input = Uri.parse('https://fixture.test/embed/42');
    expect(controller.supports(input), isTrue);
    final streams = await controller.resolve(input);
    expect(streams.single.protocol, StreamProtocol.hls);
  });

  test('Resolvers isolates resolver failure', () async {
    final registry = ResolverRegistry([FixtureResolver(fail: true)]);
    final controller = ResolversController(registry, ResolverCoordinator(registry, StreamValidator(policy)));
    expect(await controller.resolve(Uri.parse('https://fixture.test/embed/42')), isEmpty);
  });
}
