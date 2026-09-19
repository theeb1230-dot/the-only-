import 'downloads.dart';

class MemoryDownloadsRepository implements DownloadsRepository {
  final Map<String, DownloadJob> _jobs = {};
  @override
  Future<List<DownloadJob>> all() async => _jobs.values.toList(growable: false);
  @override
  Future<void> enqueue(DownloadJob job) async => _jobs[job.id] = job;
  @override
  Future<void> update(DownloadJob job) async => _jobs[job.id] = job;
  @override
  Future<void> remove(String id) async => _jobs.remove(id);
}
