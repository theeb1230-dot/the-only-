import 'models.dart';

enum MediaAction { watch, download }

class MediaRequest {
  const MediaRequest({required this.item, required this.action});
  final MediaItem item;
  final MediaAction action;
}
