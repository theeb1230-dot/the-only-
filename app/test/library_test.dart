import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/data/in_memory_library.dart';
import 'package:the_only/core/data/library.dart';
import 'package:the_only/core/domain/models.dart';

void main() {
  const item = MediaItem(id: '1', title: 'One', kind: MediaKind.movie);
  test('favorites are shared by media identity', () async {
    final repo = MemoryFavoritesRepository();
    await repo.add(item);
    expect((await repo.all()).single.title, 'One');
    await repo.remove('1');
    expect(await repo.all(), isEmpty);
  });
  test('history saves playback position', () async {
    final repo = MemoryHistoryRepository();
    await repo.save(HistoryEntry(item: item, position: const Duration(seconds: 12), updatedAt: DateTime.utc(2026)));
    expect((await repo.all()).single.position, const Duration(seconds: 12));
  });
}
