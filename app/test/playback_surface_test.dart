import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/player/embed_screen.dart';
import 'package:the_only/core/player/playback_screen.dart';

StreamSource source(StreamProtocol protocol, String url) => StreamSource(
  uri: Uri.parse(url), protocol: protocol, providerId: 'test');

void main() {
  test('HLS MP4 and DASH route to native playback while embed is isolated', () {
    for (final protocol in [StreamProtocol.hls, StreamProtocol.mp4, StreamProtocol.dash]) {
      expect(playbackSurfaceFor(source(protocol, 'https://media.example/video')), PlaybackSurface.native);
    }
    expect(playbackSurfaceFor(source(StreamProtocol.embed, 'https://embed.example/watch')), PlaybackSurface.legalEmbed);
  });

  testWidgets('embed product route fails closed when no legal host is allowlisted', (tester) async {
    final embed = source(StreamProtocol.embed, 'https://unapproved.example/watch');
    await tester.pumpWidget(MaterialApp(home: PlaybackScreen(source: embed, title: 'Embed')));
    expect(find.byType(EmbedScreen), findsOneWidget);
    expect(find.byKey(const Key('embed-error')), findsOneWidget);
    expect(find.text('This embedded source is not allowed.'), findsOneWidget);
    expect(find.byKey(const Key('legal-embed-webview')), findsNothing);
  });
}
