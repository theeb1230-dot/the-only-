import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/player/embed_policy.dart';

void main() {
  test('embed policy requires explicit HTTPS host allowlist', () {
    final policy = EmbedNavigationPolicy(allowedHosts: {'media.example'});
    expect(policy.allowsInitial(Uri.parse('https://media.example/embed/1')), isTrue);
    expect(policy.allowsInitial(Uri.parse('https://evil.example/embed/1')), isFalse);
    expect(policy.allowsInitial(Uri.parse('http://media.example/embed/1')), isFalse);
    expect(policy.allowsInitial(Uri.parse('https://user:pass@media.example/embed/1')), isFalse);
  });

  test('embed navigation blocks cross-host and downgrade redirects', () {
    final policy = EmbedNavigationPolicy(allowedHosts: {'media.example'});
    final initial = Uri.parse('https://media.example/embed/1');
    expect(policy.allowsNavigation(initial, Uri.parse('https://media.example/player')), isTrue);
    expect(policy.allowsNavigation(initial, Uri.parse('https://evil.example/player')), isFalse);
    expect(policy.allowsNavigation(initial, Uri.parse('http://media.example/player')), isFalse);
  });

  test('empty allowlist fails closed', () {
    final policy = EmbedNavigationPolicy(allowedHosts: {});
    expect(policy.allowsInitial(Uri.parse('https://media.example/embed/1')), isFalse);
  });
}
