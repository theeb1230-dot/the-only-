import '../domain/models.dart';

enum DownloadState { queued, running, paused, completed, failed }

class DownloadJob {
  const DownloadJob({required this.id, required this.source, required this.state});
  final String id;
  final StreamSource source;
  final DownloadState state;
}

abstract interface class DownloadsRepository {
  Future<List<DownloadJob>> all();
  Future<void> enqueue(DownloadJob job);
  Future<void> remove(String id);
}
