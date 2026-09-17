import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/live_channel.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/domain/programme.dart';
import 'package:the_only/core/providers/live_provider.dart';
import 'package:the_only/features/live_tv/live_tv_controller.dart';
import 'package:the_only/features/live_tv/live_tv_screen.dart';

class ScreenFixtureProvider implements LiveTvProvider {
  @override String get id => 'fixture-live';
  @override Future<List<LiveChannel>> channels() async => const [LiveChannel(id: 'news', name: 'Fixture News', group: 'News')];
  @override Future<List<Programme>> programmes(String channelId, DateTime from, DateTime to) async => [Programme(channelId: channelId, title: 'Fixture Bulletin', startsAt: from, endsAt: to)];
  @override Future<List<StreamSource>> streams(LiveChannel channel) async => [StreamSource(uri: Uri.parse('https://fixture.test/live.m3u8'), protocol: StreamProtocol.hls, providerId: id, quality: 'HD')];
}

void main() {
  testWidgets('Live TV opens channel, guide, stream and explicit Watch', (tester) async {
    var watched = false;
    final controller = LiveTvController([ScreenFixtureProvider()]);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: LiveTvScreen(
      controller: controller,
      onWatch: (channel, source) async {
        expect(channel.id, 'news');
        expect(source.protocol, StreamProtocol.hls);
        watched = true;
      },
    ))));
    await tester.pumpAndSettle();
    expect(find.text('Fixture News'), findsOneWidget);
    await tester.tap(find.byKey(const Key('live-channel-news')));
    await tester.pumpAndSettle();
    expect(find.text('Fixture Bulletin'), findsOneWidget);
    expect(find.text('HD'), findsOneWidget);
    await tester.tap(find.byKey(const Key('live-watch-0')));
    await tester.pumpAndSettle();
    expect(watched, isTrue);
  });
}
