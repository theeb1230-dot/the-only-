import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/domain/validation.dart';
import 'package:the_only/core/resolvers/resolver.dart';
import 'package:the_only/core/resolvers/resolver_coordinator.dart';
import 'package:the_only/core/resolvers/resolver_registry.dart';
import 'package:the_only/core/security/url_policy.dart';

class _Resolver implements StreamResolver {
  _Resolver({this.error, this.delay = Duration.zero});

  final Object? error;
  final Duration delay;

  @override
  String get id => 'test';

  @override
  bool supports(Uri uri) => true;

  @override
  Future<List<StreamSource>> resolve(Uri uri) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (error != null) throw error!;
    return const [];
  }
}

void main() {
  ResolverCoordinator coordinator(StreamResolver resolver) => ResolverCoordinator(
        ResolverRegistry([resolver]),
        const StreamValidator(UrlPolicy()),
        resolverTimeout: const Duration(milliseconds: 20),
      );

  test('resolver exception fails closed instead of escaping Watch path', () async {
    final result = await coordinator(_Resolver(error: StateError('offline')))
        .resolve(Uri.parse('https://media.example.test/watch'));
    expect(result, isEmpty);
  });

  test('hung resolver times out without hanging Watch path', () async {
    final stopwatch = Stopwatch()..start();
    final result = await coordinator(
      _Resolver(delay: const Duration(seconds: 1)),
    ).resolve(Uri.parse('https://media.example.test/watch'));
    stopwatch.stop();

    expect(result, isEmpty);
    expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 500)));
  });
}
