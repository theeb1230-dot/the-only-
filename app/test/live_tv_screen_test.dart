import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/live_channel.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/domain/programme.dart';
import 'package:the_only/core/providers/live_provider.dart';
import 'package:the_only/features/live_tv/live_tv_controller.dart';
import 'package:the_only/features/live_tv/live_tv_screen.dart';

class FailingLiveProvider implements LiveTvProvider {
  @override String get id => 'failing';
  @override Future<List<LiveChannel>> channels() async => throw StateError('fixture failure');
  @override Future<List<Programme>> programmes(String channelId, DateTime from, DateTime to) async => throw StateError('fixture failure');
  @override Future<List<StreamSource>> streams(LiveChannel channel) async => throw StateError('fixture failure');
}

class FixtureLiveProvider implements LiveTvProvider {
  @override String get id => 'fixture';
  @override Future<List<LiveChannel>> channels() async => const [LiveChannel(id: 'news', name: 'Fixture News', group: 'News')];
  @override Future<List<Programme>> programmes(String channelId, DateTime from, DateTime to) async => [Programme(channelId: channelId, title: 'Fixture Programme', startsAt: from.add(const Duration(hours: 1)), endsAt: from.add(const Duration(hours: 2)))];
  @override Future<List<StreamSource>> streams(LiveChannel channel) async => [StreamSource(uri: Uri.parse('https://example.invalid/live.m3u8'), protocol: StreamProtocol.hls, providerId: id, quality: 'HD')];
}

void main() {
  testWidgets('Live TV survives provider failure and exposes guide plus explicit Watch', (tester) async {
    StreamSource? watched;
    final controller = LiveTvController([FailingLiveProvider(), FixtureLiveProvider()]);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: LiveTvScreen(controller: controller, onWatch: (source) async { watched = source; }))));

    await tester.tap(find.byKey(const Key('live-tv-load')));
    await tester.pumpAndSettle();
    expect(find.text('Fixture News'), findsOneWidget);

    await tester.tap(find.byKey(const Key('live-tv-channel-news')));
    await tester.pumpAndSettle();
    expect(find.text('Fixture Programme'), findsOneWidget);
    expect(find.byKey(const Key('live-tv-watch-0')), findsOneWidget);

    await tester.tap(find.byKey(const Key('live-tv-watch-0')));
    await tester.pump();
    expect(watched?.protocol, StreamProtocol.hls);
    expect(watched?.uri.host, 'example.invalid');
  });
}
