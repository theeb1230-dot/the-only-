import '../domain/models.dart';

enum DownloadState { queued, running, paused, completed, failed, cancelled }

class DownloadJob {
  const DownloadJob({
    required this.id,
    required this.source,
    required this.state,
    this.progress = 0,
    this.localPath,
    this.error,
  });
  final String id;
  final StreamSource source;
  final DownloadState state;
  final double progress;
  final String? localPath;
  final String? error;

  DownloadJob copyWith({
    DownloadState? state,
    double? progress,
    String? localPath,
    String? error,
    bool clearError = false,
  }) => DownloadJob(
    id: id,
    source: source,
    state: state ?? this.state,
    progress: progress ?? this.progress,
    localPath: localPath ?? this.localPath,
    error: clearError ? null : (error ?? this.error),
  );
}

abstract interface class DownloadsRepository {
  Future<List<DownloadJob>> all();
  Future<void> enqueue(DownloadJob job);
  Future<void> update(DownloadJob job);
  Future<void> remove(String id);
}
