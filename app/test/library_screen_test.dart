import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_only/core/data/downloads.dart';
import 'package:the_only/core/data/library.dart';
import 'package:the_only/core/data/persistent_library.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/features/library/library_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Library renders persisted favorites history and downloads after store recreation', (tester) async {
    SharedPreferences.setMockInitialValues({});
    var store = PersistentLibraryStore(await SharedPreferences.getInstance());
    await store.initialize();
    const item = MediaItem(id:'persisted', title:'Persisted Movie', kind:MediaKind.movie);
    final source = StreamSource(uri:Uri.parse('https://cdn.example.test/persisted.mp4'), protocol:StreamProtocol.mp4, providerId:'legal');
    await PersistentFavoritesRepository(store).add(item);
    await PersistentHistoryRepository(store).save(HistoryEntry(item:item, position:const Duration(seconds:42), updatedAt:DateTime.utc(2026,9,19)));
    await PersistentDownloadsRepository(store).enqueue(DownloadJob(id:'persisted-download', source:source, state:DownloadState.queued));

    store = PersistentLibraryStore(await SharedPreferences.getInstance());
    await store.initialize();
    await tester.pumpWidget(MaterialApp(home:Scaffold(body:LibraryScreen(favorites:PersistentFavoritesRepository(store),history:PersistentHistoryRepository(store),downloads:PersistentDownloadsRepository(store)))));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('favorite-persisted')), findsOneWidget);\n    expect(find.byKey(const Key('history-persisted')), findsOneWidget);
    expect(find.text('المفضلة'), findsOneWidget);
    expect(find.text('السجل'), findsOneWidget);
    expect(find.text('التنزيلات'), findsOneWidget);
    expect(find.text('استئناف عند 42 ث'), findsOneWidget);
    expect(find.byKey(const Key('download-persisted-download')), findsOneWidget);
    expect(find.text('في الانتظار'), findsOneWidget);
    expect(find.byTooltip('حذف من المفضلة'), findsOneWidget);
    expect(find.byTooltip('حذف التنزيل'), findsOneWidget);
  });
}
