import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_only/core/data/download_transfer.dart';
import 'package:the_only/core/data/downloads.dart';
import 'package:the_only/core/data/persistent_library.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/security/url_policy.dart';

void main() {
  late Directory directory;
  late HttpServer server;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    directory = await Directory.systemTemp.createTemp('the-only-download-test-');
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  });

  tearDown(() async {
    await server.close(force: true);
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  Future<PersistentDownloadsRepository> repository() async {
    final store = PersistentLibraryStore(await SharedPreferences.getInstance());
    await store.initialize();
    return PersistentDownloadsRepository(store);
  }

  StreamSource source(String path) => StreamSource(
    uri: Uri.parse('http://127.0.0.1:${server.port}$path'),
    protocol: StreamProtocol.mp4,
    providerId: 'test-legal',
  );

  test('real transfer writes bytes and persists completed lifecycle', () async {
    final repo = await repository();
    final service = DownloadTransferService(
      repository: repo,
      urlPolicy: const UrlPolicy(allowHttpForLocalhost: true),
      directoryProvider: () async => directory,
    );
    final job = DownloadJob(id: 'real-transfer', source: source('/video.mp4'), state: DownloadState.queued);
    await repo.enqueue(job);

    final serving = server.first.then((request) async {
      request.response.headers.contentLength = 6;
      request.response.add([1, 2, 3, 4, 5, 6]);
      await request.response.close();
    });
    final result = await service.start(job);
    await serving;

    expect(result.state, DownloadState.completed);
    expect(result.progress, 1);
    expect(result.localPath, isNotNull);
    expect(await File(result.localPath!).readAsBytes(), [1, 2, 3, 4, 5, 6]);

    final recreated = await repository();
    final persisted = (await recreated.all()).single;
    expect(persisted.state, DownloadState.completed);
    expect(persisted.localPath, result.localPath);
    expect(persisted.progress, 1);
  });

  test('stalled response body times out and cleans partial media', () async {
    final repo = await repository();
    final service = DownloadTransferService(
      repository: repo,
      urlPolicy: const UrlPolicy(allowHttpForLocalhost: true),
      directoryProvider: () async => directory,
      responseIdleTimeout: const Duration(milliseconds: 100),
    );
    final job = DownloadJob(id: 'stalled-transfer', source: source('/stall.mp4'), state: DownloadState.queued);
    await repo.enqueue(job);

    final requestReceived = Completer<void>();
    final releaseServer = Completer<void>();
    final serving = server.first.then((request) async {
      request.response.headers.contentLength = 6;
      request.response.add([1, 2, 3]);
      await request.response.flush();
      requestReceived.complete();
      await releaseServer.future;
      await request.response.close();
    });

    final resultFuture = service.start(job);
    await requestReceived.future;
    final result = await resultFuture;
    releaseServer.complete();
    // The client deliberately aborts the socket after the idle timeout. The
    // server may therefore observe an expected peer-disconnect while closing.
    await serving.then<void>((_) {}, onError: (_) {});

    expect(result.state, DownloadState.failed);
    expect(result.progress, 0);
    expect(result.localPath, isNull);
    expect(result.error, contains('Retry'));
    expect(await directory.list().toList(), isEmpty);
  });

  test('startup recovery pauses interrupted jobs and detects missing completed files', () async {
    final repo = await repository();
    final running = DownloadJob(id: 'running', source: source('/a.mp4'), state: DownloadState.running, progress: .5);
    final missing = DownloadJob(id: 'missing', source: source('/b.mp4'), state: DownloadState.completed, progress: 1, localPath: '${directory.path}/gone.mp4');
    await repo.enqueue(running);
    await repo.enqueue(missing);

    final service = DownloadTransferService(
      repository: repo,
      urlPolicy: const UrlPolicy(allowHttpForLocalhost: true),
      directoryProvider: () async => directory,
    );
    await service.recoverInterrupted();
    final jobs = {for (final job in await repo.all()) job.id: job};

    expect(jobs['running']!.state, DownloadState.paused);
    expect(jobs['running']!.error, contains('interrupted'));
    expect(jobs['missing']!.state, DownloadState.failed);
    expect(jobs['missing']!.error, contains('missing'));
  });

  test('unsafe redirect fails closed without creating completed media', () async {
    final repo = await repository();
    final service = DownloadTransferService(
      repository: repo,
      urlPolicy: const UrlPolicy(allowHttpForLocalhost: true),
      directoryProvider: () async => directory,
    );
    final job = DownloadJob(id: 'redirect', source: source('/redirect'), state: DownloadState.queued);
    await repo.enqueue(job);

    final serving = server.first.then((request) async {
      request.response.statusCode = HttpStatus.found;
      request.response.headers.set(HttpHeaders.locationHeader, 'https://user:pass@example.com/secret.mp4');
      await request.response.close();
    });
    final result = await service.start(job);
    await serving;

    expect(result.state, DownloadState.failed);
    expect(result.localPath, isNull);
    expect(await directory.list().toList(), isEmpty);
  });
}
