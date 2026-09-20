import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:the_only/application/cinema_controller.dart';
import 'package:the_only/application/live_tv_controller.dart';
import 'package:the_only/domain/models.dart';
import 'package:the_only/infrastructure/legal_demo_provider.dart';
import 'package:the_only/infrastructure/legal_live_demo_provider.dart';
import 'package:the_only/infrastructure/resolvers/direct_media_resolver.dart';
import 'package:the_only/infrastructure/resolvers/resolver_coordinator.dart';
import 'package:the_only/infrastructure/storage/memory_library.dart';
import 'package:the_only/presentation/cinema_screen.dart';
import 'package:the_only/presentation/live_tv_screen.dart';

ResolverCoordinator legalResolver() => ResolverCoordinator([
      DirectMediaResolver(),
    ]);

void main() {
  testWidgets(
      'legal Cinema runtime provider reaches resolved player launch and keeps Download separate',
      (tester) async {
    StreamSource? launched;
    final history = MemoryHistoryRepository();
    final downloads = MemoryDownloadsRepository();
    final controller = CinemaController(
      [LegalDemoProvider()],
      resolver: legalResolver(),
      history: history,
      downloads: downloads,
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CinemaScreen(
          controller: controller,
          onPlay: (source) async => launched = source,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Big Buck Bunny'), findsOneWidget);
    await tester.tap(find.byKey(const Key('cinema-item-big-buck-bunny')));
    await tester.pumpAndSettle();
    expect(find.text('مصادر التشغيل المتاحة: 1'), findsOneWidget);

    final watch = find.byKey(const Key('cinema-watch-0'));
    final download = find.byKey(const Key('cinema-download-0'));
    expect(watch, findsOneWidget);
    expect(download, findsOneWidget);

    await tester.ensureVisible(watch);
    await tester.tap(watch);
    await tester.pumpAndSettle();
    expect(launched?.uri.host, 'commondatastorage.googleapis.com');
    expect(launched?.protocol, StreamProtocol.mp4);
    expect(await history.all(), hasLength(1));
    expect(await downloads.all(), isEmpty);

    await tester.ensureVisible(download);
    await tester.tap(download);
    await tester.pumpAndSettle();
    expect(await downloads.all(), hasLength(1));
  });

  testWidgets(
      'legal Live TV runtime provider reaches channel guide stream resolver and player launch',
      (tester) async {
    StreamSource? launched;
    final controller =
        LiveTvController([LegalLiveDemoProvider()], resolver: legalResolver());
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
      body: LiveTvScreen(
        controller: controller,
        onPlay: (source) async => launched = source,
      ),
    )));
    await tester.pumpAndSettle();

    expect(find.text('Public Bunny Live'), findsOneWidget);
    await tester.tap(find.byKey(const Key('live-channel-public-bunny')));
    await tester.pumpAndSettle();
    expect(find.textContaining('البرنامج الحالي'), findsOneWidget);
    expect(find.byKey(const Key('live-watch')), findsOneWidget);
    await tester.tap(find.byKey(const Key('live-watch')));
    await tester.pumpAndSettle();
    expect(launched, isNotNull);
    expect(launched!.protocol, StreamProtocol.hls);
  });
}
