import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/data/downloads.dart';
import 'package:the_only/core/data/in_memory_downloads.dart';
import 'package:the_only/core/domain/models.dart';

void main() {
  test('download queue enqueues and removes jobs', () async {
    final repo = MemoryDownloadsRepository();
    final job = DownloadJob(id: '1', source: StreamSource(uri: Uri.parse('https://example.test/a.mp4'), protocol: StreamProtocol.mp4, providerId: 'fixture'), state: DownloadState.queued);
    await repo.enqueue(job);
    expect((await repo.all()).single.id, '1');
    await repo.remove('1');
    expect(await repo.all(), isEmpty);
  });
}
