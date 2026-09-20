import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:the_only/application/cinema_controller.dart';
import 'package:the_only/domain/models.dart';
import 'package:the_only/infrastructure/resolvers/direct_media_resolver.dart';
import 'package:the_only/infrastructure/resolvers/resolver_coordinator.dart';
import 'package:the_only/infrastructure/storage/memory_library.dart';
import 'package:the_only/presentation/cinema_screen.dart';

class _CinemaProvider implements MediaProvider {
  @override
  String get id => 'cinema-test';

  @override
  Future<List<MediaItem>> search(String query) async => query == 'none'
      ? const []
      : const [
          MediaItem(id: 'movie-1', title: 'Movie One', kind: MediaKind.movie),
        ];

  @override
  Future<List<StreamSource>> sources(MediaItem item) async => [
        StreamSource(
          uri: Uri.parse('https://example.com/movie.mp4'),
          protocol: StreamProtocol.mp4,
          providerId: id,
          quality: '1080p',
        ),
      ];
}

class _EmptyProvider implements MediaProvider {
  @override
  String get id => 'empty';

  @override
  Future<List<MediaItem>> search(String query) async => const [];

  @override
  Future<List<StreamSource>> sources(MediaItem item) async => const [];
}

void main() {
  testWidgets('Cinema exposes truthful empty search state after loading',
      (tester) async {
    final controller = CinemaController(
      [_EmptyProvider()],
      resolver: ResolverCoordinator([DirectMediaResolver()]),
    );
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CinemaScreen(controller: controller)),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('لا توجد نتائج'), findsOneWidget);
  });

  testWidgets('Cinema exposes separate resolver-backed Watch and Download actions',
      (tester) async {
    StreamSource? launched;
    final history = MemoryHistoryRepository();
    final downloads = MemoryDownloadsRepository();
    final controller = CinemaController(
      [_CinemaProvider()],
      resolver: ResolverCoordinator([DirectMediaResolver()]),
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

    expect(find.text('Movie One'), findsOneWidget);
    await tester.tap(find.byKey(const Key('cinema-item-movie-1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('cinema-details-movie-1')), findsOneWidget);
    final watch = find.byKey(const Key('cinema-watch-0'));
    final download = find.byKey(const Key('cinema-download-0'));
    expect(watch, findsOneWidget);
    expect(download, findsOneWidget);

    await tester.ensureVisible(watch);
    await tester.tap(watch);
    await tester.pumpAndSettle();
    expect(history.entries, hasLength(1));
    expect(launched, isNotNull);
    expect(launched!.protocol, StreamProtocol.mp4);
    expect(downloads.jobs, isEmpty,
        reason: 'Watch must never implicitly queue a download');

    await tester.ensureVisible(download);
    await tester.tap(download);
    await tester.pumpAndSettle();
    expect(downloads.jobs, hasLength(1));
    expect(history.entries, hasLength(1),
        reason: 'Download must remain independent from Watch/history');
    expect(find.text('تمت إضافة التنزيل إلى قائمة الانتظار'), findsOneWidget);
  });
}
