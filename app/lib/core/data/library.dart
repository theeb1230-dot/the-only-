import '../domain/models.dart';

abstract interface class FavoritesRepository {
  Future<List<MediaItem>> all();
  Future<void> add(MediaItem item);
  Future<void> remove(String mediaId);
}

class HistoryEntry {
  const HistoryEntry({required this.item, required this.position, required this.updatedAt});
  final MediaItem item;
  final Duration position;
  final DateTime updatedAt;
}

abstract interface class HistoryRepository {
  Future<List<HistoryEntry>> all();
  Future<void> save(HistoryEntry entry);
}
