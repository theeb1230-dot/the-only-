import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/security/url_policy.dart';

void main() {
  test('allows HTTPS and rejects insecure remote HTTP by default', () {
    const policy = UrlPolicy();
    expect(policy.allows(Uri.parse('https://example.test/a.m3u8')), isTrue);
    expect(policy.allows(Uri.parse('http://example.test/a.m3u8')), isFalse);
  });

  test('fails closed for embedded credentials and empty hosts', () {
    const policy = UrlPolicy();
    expect(
      policy.allows(Uri.parse('https://user:pass@example.test/a.m3u8')),
      isFalse,
    );
    expect(policy.allows(Uri.parse('https:///a.m3u8')), isFalse);
  });

  test('optional host allowlist is exact and case insensitive', () {
    const policy = UrlPolicy(allowedHosts: {'media.example.test'});
    expect(
      policy.allows(Uri.parse('https://MEDIA.EXAMPLE.TEST/a.m3u8')),
      isTrue,
    );
    expect(
      policy.allows(Uri.parse('https://evil-media.example.test/a.m3u8')),
      isFalse,
    );
  });

  test('redirect policy rejects downgrade cross-boundary and blocked hosts', () {
    const policy = UrlPolicy(
      allowHttpForLocalhost: true,
      allowedHosts: {'media.example.test', 'localhost'},
    );
    final origin = Uri.parse('https://media.example.test/a.m3u8');
    expect(
      policy.allowsRedirect(
        origin,
        Uri.parse('https://media.example.test/b.m3u8'),
      ),
      isTrue,
    );
    expect(
      policy.allowsRedirect(origin, Uri.parse('http://localhost/b.m3u8')),
      isFalse,
    );
    expect(
      policy.allowsRedirect(
        origin,
        Uri.parse('https://unlisted.example.test/b.m3u8'),
      ),
      isFalse,
    );
  });

  test('rejects credentials on redirects even when destination host is allowed', () {
    const policy = UrlPolicy(allowedHosts: {'media.example.test'});
    final origin = Uri.parse('https://media.example.test/a.m3u8');
    expect(
      policy.allowsRedirect(
        origin,
        Uri.parse('https://user:secret@media.example.test/b.m3u8?token=secret#part'),
      ),
      isFalse,
    );
  });

  test('localhost HTTP exception is limited to exact loopback hosts', () {
    const policy = UrlPolicy(allowHttpForLocalhost: true);
    expect(policy.allows(Uri.parse('http://localhost/a.mp4')), isTrue);
    expect(policy.allows(Uri.parse('http://127.0.0.1/a.mp4')), isTrue);
    expect(policy.allows(Uri.parse('http://[::1]/a.mp4')), isTrue);
    expect(policy.allows(Uri.parse('http://localhost.evil.test/a.mp4')), isFalse);
  });
}
