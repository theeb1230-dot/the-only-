import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/resolvers/direct_media_resolver.dart';

void main() {
  const resolver = DirectMediaResolver();

  test('resolves policy-safe direct media protocols', () async {
    final mp4 = Uri.parse('https://cdn.example.test/video.mp4');
    final hls = Uri.parse('https://cdn.example.test/live.m3u8');
    final dash = Uri.parse('https://cdn.example.test/manifest.mpd');

    expect(resolver.supports(mp4), isTrue);
    expect((await resolver.resolve(mp4)).single.protocol, StreamProtocol.mp4);
    expect((await resolver.resolve(hls)).single.protocol, StreamProtocol.hls);
    expect((await resolver.resolve(dash)).single.protocol, StreamProtocol.dash);
  });

  test('fails closed for unsupported or insecure URLs', () async {
    expect(resolver.supports(Uri.parse('http://cdn.example.test/video.mp4')), isFalse);
    expect(resolver.supports(Uri.parse('https://cdn.example.test/page.html')), isFalse);
    expect(await resolver.resolve(Uri.parse('https://cdn.example.test/page.html')), isEmpty);
  });
}
