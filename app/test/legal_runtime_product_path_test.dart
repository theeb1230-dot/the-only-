import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/data/in_memory_downloads.dart';
import 'package:the_only/core/data/in_memory_library.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/domain/validation.dart';
import 'package:the_only/core/providers/legal_demo_provider.dart';
import 'package:the_only/core/providers/legal_live_demo_provider.dart';
import 'package:the_only/core/resolvers/direct_media_resolver.dart';
import 'package:the_only/core/resolvers/resolver_coordinator.dart';
import 'package:the_only/core/resolvers/resolver_registry.dart';
import 'package:the_only/core/security/url_policy.dart';
import 'package:the_only/features/cinema/cinema_controller.dart';
import 'package:the_only/features/cinema/cinema_screen.dart';
import 'package:the_only/features/live_tv/live_tv_controller.dart';
import 'package:the_only/features/live_tv/live_tv_screen.dart';

ResolverCoordinator legalResolver() => ResolverCoordinator(
  ResolverRegistry(const [DirectMediaResolver()]),
  const StreamValidator(UrlPolicy()),
);

void main() {
  testWidgets('legal Cinema runtime provider reaches resolved player launch and keeps Download separate', (tester) async {
    final favorites = MemoryFavoritesRepository();
    final history = MemoryHistoryRepository();
    final downloads = MemoryDownloadsRepository();
    final controller = CinemaController(
      providers: [LegalDemoProvider()],
      favorites: favorites,
      history: history,
      downloads: downloads,
      resolver: legalResolver(),
    );
    StreamSource? launched;

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: CinemaScreen(
      controller: controller,
      playerLauncher: (_, __, source) async { launched = source; },
    ))));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('cinema-search-field')), 'Bunny');
    await tester.tap(find.byKey(const Key('cinema-search-button')));
    await tester.pumpAndSettle();
    expect(find.text('Big Buck Bunny'), findsOneWidget);
    final item = find.byKey(const Key('cinema-item-big-buck-bunny'));
    await tester.ensureVisible(item);
    await tester.tap(item);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('cinema-details-big-buck-bunny')), findsOneWidget);
    expect(find.text('فيلم'), findsOneWidget);
    expect(find.text('مصادر التشغيل المتاحة: 1'), findsOneWidget);
    expect(find.byKey(const Key('cinema-watch-0')), findsOneWidget);
    expect(find.byKey(const Key('cinema-download-0')), findsOneWidget);

    final watch = find.byKey(const Key('cinema-watch-0'));
    await tester.ensureVisible(watch);
    await tester.tap(watch);
    await tester.pumpAndSettle();
    expect(launched?.uri.host, 'commondatastorage.googleapis.com');
    expect(launched?.protocol, StreamProtocol.mp4);
    expect(await history.all(), hasLength(1));
    expect(await downloads.all(), isEmpty);

    final download = find.byKey(const Key('cinema-download-0'));
    await tester.ensureVisible(download);
    await tester.tap(download);
    await tester.pumpAndSettle();
    expect(await downloads.all(), hasLength(1));
  });

  testWidgets('legal Live TV runtime provider reaches channel guide stream resolver and player launch', (tester) async {
    StreamSource? launched;
    final controller = LiveTvController([LegalLiveDemoProvider()], resolver: legalResolver());
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: LiveTvScreen(
      controller: controller,
      playerLauncher: (_, __, source) async { launched = source; },
    ))));
    await tester.pumpAndSettle();
    expect(find.text('Big Buck Bunny'), findsOneWidget);
    final channel = find.byKey(const Key('live-channel-public-bunny'));
    await tester.ensureVisible(channel);
    await tester.tap(channel);
    await tester.pumpAndSettle();
    expect(find.textContaining('Big Buck Bunny'), findsWidgets);
    final watch = find.byKey(const Key('live-watch-0'));
    expect(watch, findsOneWidget);
    await tester.ensureVisible(watch);
    await tester.tap(watch);
    await tester.pumpAndSettle();
    expect(launched?.uri.host, 'commondatastorage.googleapis.com');
    expect(launched?.protocol, StreamProtocol.mp4);
  });
}
