import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/providers/provider.dart';
import 'package:the_only/core/providers/provider_registry.dart';
import 'package:the_only/features/sources/sources_controller.dart';
import 'package:the_only/features/sources/sources_screen.dart';

class ScreenSourceProvider implements MediaProvider {
  ScreenSourceProvider(this.id, {this.fail = false});
  @override final String id;
  final bool fail;
  @override Future<List<MediaItem>> search(String query) async {
    if (fail) throw StateError('fixture failure');
    return const [MediaItem(id: 'fixture', title: 'Fixture Source Movie', kind: MediaKind.movie)];
  }
  @override Future<ProviderResult> sourcesFor(MediaItem item) async {
    if (fail) throw StateError('fixture failure');
    return ProviderResult(providerId: id, sources: [StreamSource(uri: Uri.parse('https://example.invalid/source.mp4'), protocol: StreamProtocol.mp4, providerId: id, quality: '1080p')]);
  }
}

void main() {
  testWidgets('Sources searches across providers and keeps Watch and Download independent', (tester) async {
    final controller = SourcesController(ProviderRegistry([ScreenSourceProvider('broken', fail: true), ScreenSourceProvider('fixture')]));
    var watches = 0;
    var downloads = 0;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SourcesScreen(
      controller: controller,
      onWatch: (_, __) async => watches++,
      onDownload: (_, __) async => downloads++,
    ))));
    await tester.enterText(find.byKey(const Key('sources-search-field')), 'movie');
    await tester.tap(find.byKey(const Key('sources-search-button')));
    await tester.pumpAndSettle();
    expect(find.text('Fixture Source Movie'), findsOneWidget);
    await tester.tap(find.byKey(const Key('sources-item-fixture')));
    await tester.pumpAndSettle();
    expect(find.text('1080p'), findsOneWidget);
    await tester.tap(find.byKey(const Key('sources-watch-fixture-0')));
    await tester.pump();
    expect(watches, 1);
    expect(downloads, 0);
    await tester.tap(find.byKey(const Key('sources-download-fixture-0')));
    await tester.pump();
    expect(watches, 1);
    expect(downloads, 1);
  });
}
