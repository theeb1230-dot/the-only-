import '../domain/models.dart';

abstract interface class MediaProvider {
  String get id;

  Future<List<MediaItem>> search(String query);

  Future<ProviderResult> sourcesFor(MediaItem item);
}
