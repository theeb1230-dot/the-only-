import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/live_channel.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/domain/programme.dart';
import 'package:the_only/core/domain/validation.dart';
import 'package:the_only/core/providers/live_provider.dart';
import 'package:the_only/core/resolvers/direct_media_resolver.dart';
import 'package:the_only/core/resolvers/resolver_coordinator.dart';
import 'package:the_only/core/resolvers/resolver_registry.dart';
import 'package:the_only/core/security/url_policy.dart';
import 'package:the_only/features/live_tv/live_tv_controller.dart';
import 'package:the_only/features/live_tv/live_tv_screen.dart';

class ScreenFixtureProvider implements LiveTvProvider {
  @override
  String get id => 'fixture-live';

  @override
  Future<List<LiveChannel>> channels() async => const [
        LiveChannel(id: 'news', name: 'Fixture News', group: 'News'),
      ];

  @override
  Future<List<Programme>> programmes(
    String channelId,
    DateTime from,
    DateTime to,
  ) async => [
        Programme(
          channelId: channelId,
          title: 'Fixture Bulletin',
          startsAt: from,
          endsAt: to,
        ),
      ];

  @override
  Future<List<StreamSource>> streams(LiveChannel channel) async => [
        StreamSource(
          uri: Uri.parse('https://example.com/live.m3u8'),
          protocol: StreamProtocol.hls,
          providerId: id,
          quality: 'HD',
        ),
      ];
}

class EmptyLiveProvider implements LiveTvProvider {
  @override String get id => 'empty-live';
  @override Future<List<LiveChannel>> channels() async => const [];
  @override Future<List<Programme>> programmes(String channelId, DateTime from, DateTime to) async => const [];
  @override Future<List<StreamSource>> streams(LiveChannel channel) async => const [];
}

void main() {
  testWidgets('Live TV exposes truthful empty state after loading', (tester) async {
    final resolver = ResolverCoordinator(ResolverRegistry(const [DirectMediaResolver()]), const StreamValidator(UrlPolicy()));
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: LiveTvScreen(controller: LiveTvController([EmptyLiveProvider()], resolver: resolver)))));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('live-tv-empty')), findsOneWidget);
    expect(find.text('لا توجد قنوات متاحة'), findsOneWidget);
    expect(find.byKey(const Key('live-tv-loading')), findsNothing);
    expect(find.byKey(const Key('live-tv-error')), findsNothing);
  });

  testWidgets('Live TV resolves selected stream before explicit Watch', (tester) async {
    var watched = false;
    final resolver = ResolverCoordinator(
      ResolverRegistry(const [DirectMediaResolver()]),
      const StreamValidator(UrlPolicy()),
    );
    final controller = LiveTvController(
      [ScreenFixtureProvider()],
      resolver: resolver,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiveTvScreen(
            controller: controller,
            playerLauncher: (context, channel, source) async {
              expect(channel.id, 'news');
              expect(source.protocol, StreamProtocol.hls);
              expect(source.uri.toString(), 'https://example.com/live.m3u8');
              watched = true;
            },
          ),
        ),
      ),
    );
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
