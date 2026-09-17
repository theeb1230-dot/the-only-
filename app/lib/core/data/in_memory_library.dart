import '../domain/models.dart';
import 'library.dart';

class MemoryFavoritesRepository implements FavoritesRepository {
  final Map<String, MediaItem> _items = {};
  @override
  Future<List<MediaItem>> all() async => _items.values.toList(growable: false);
  @override
  Future<void> add(MediaItem item) async => _items['${item.kind.name}:${item.id}'] = item;
  @override
  Future<void> remove(String mediaId) async => _items.removeWhere((key, _) => key.endsWith(':$mediaId'));
}

class MemoryHistoryRepository implements HistoryRepository {
  final Map<String, HistoryEntry> _items = {};
  @override
  Future<List<HistoryEntry>> all() async {
    final values = _items.values.toList();
    values.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return values;
  }
  @override
  Future<void> save(HistoryEntry entry) async => _items['${entry.item.kind.name}:${entry.item.id}'] = entry;
}
