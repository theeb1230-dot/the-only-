import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../domain/models.dart';
import '../security/url_policy.dart';
import 'downloads.dart';

typedef DownloadDirectoryProvider = Future<Directory> Function();

/// Executes legal direct-file downloads into app-owned storage.
///
/// Redirects are handled manually and revalidated so a trusted HTTPS URL
/// cannot redirect into an unsafe host/scheme. HLS/DASH are intentionally not
/// flattened into files here; those protocols need a separate offline-media
/// packaging contract rather than pretending a playlist is a completed video.
final class DownloadTransferService {
  DownloadTransferService({
    required this.repository,
    UrlPolicy urlPolicy = const UrlPolicy(),
    DownloadDirectoryProvider? directoryProvider,
  }) : _urlPolicy = urlPolicy,
       _directoryProvider = directoryProvider ?? _defaultDirectory;

  final DownloadsRepository repository;
  final UrlPolicy _urlPolicy;
  final DownloadDirectoryProvider _directoryProvider;
  final Map<String, HttpClient> _clients = {};
  final Set<String> _cancelled = {};

  static Future<Directory> _defaultDirectory() async {
    final root = await getApplicationSupportDirectory();
    final directory = Directory('${root.path}${Platform.pathSeparator}downloads');
    if (!await directory.exists()) await directory.create(recursive: true);
    return directory;
  }

  Future<void> recoverInterrupted() async {
    for (final job in await repository.all()) {
      if (job.state == DownloadState.running) {
        await repository.update(job.copyWith(
          state: DownloadState.paused,
          error: 'Download was interrupted. Retry to continue with a fresh transfer.',
        ));
      } else if (job.state == DownloadState.completed &&
          (job.localPath == null || !await File(job.localPath!).exists())) {
        await repository.update(job.copyWith(
          state: DownloadState.failed,
          progress: 0,
          error: 'Downloaded file is missing. Retry the download.',
        ));
      }
    }
  }

  Future<DownloadJob> start(DownloadJob job) async {
    if (job.source.protocol != StreamProtocol.mp4) {
      final failed = job.copyWith(
        state: DownloadState.failed,
        error: 'Offline transfer currently supports direct MP4 sources only.',
      );
      await repository.update(failed);
      return failed;
    }
    if (!_urlPolicy.allows(job.source.uri)) {
      final failed = job.copyWith(
        state: DownloadState.failed,
        error: 'Download URL was rejected by security policy.',
      );
      await repository.update(failed);
      return failed;
    }

    _cancelled.remove(job.id);
    var current = job.copyWith(state: DownloadState.running, progress: 0, clearError: true);
    await repository.update(current);
    final directory = await _directoryProvider();
    if (!await directory.exists()) await directory.create(recursive: true);
    final file = File('${directory.path}${Platform.pathSeparator}${_safeName(job)}.part');
    final finalFile = File('${directory.path}${Platform.pathSeparator}${_safeName(job)}.mp4');
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 12);
    _clients[job.id] = client;

    try {
      var uri = job.source.uri;
      HttpClientResponse response;
      for (var redirects = 0; ; redirects++) {
        final request = await client.getUrl(uri).timeout(const Duration(seconds: 12));
        request.followRedirects = false;
        response = await request.close().timeout(const Duration(seconds: 20));
        if (!response.isRedirect) break;
        if (redirects >= 4) throw StateError('Too many download redirects');
        final location = response.headers.value(HttpHeaders.locationHeader);
        if (location == null) throw StateError('Redirect did not provide a location');
        final next = uri.resolve(location);
        if (!_urlPolicy.allowsRedirect(uri, next)) {
          throw StateError('Download redirect was rejected by security policy');
        }
        await response.drain<void>();
        uri = next;
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        await response.drain<void>();
        throw HttpException('Download failed with HTTP ${response.statusCode}');
      }

      final total = response.contentLength;
      var received = 0;
      var lastPersisted = -1;
      final sink = file.openWrite(mode: FileMode.writeOnly);
      try {
        await for (final chunk in response) {
          if (_cancelled.contains(job.id)) throw const _DownloadCancelled();
          sink.add(chunk);
          received += chunk.length;
          final progress = total > 0 ? (received / total).clamp(0.0, 1.0).toDouble() : 0.0;
          final bucket = (progress * 20).floor();
          if (bucket != lastPersisted) {
            lastPersisted = bucket;
            current = current.copyWith(state: DownloadState.running, progress: progress);
            await repository.update(current);
          }
        }
      } finally {
        await sink.flush();
        await sink.close();
      }
      if (_cancelled.contains(job.id)) throw const _DownloadCancelled();
      if (await finalFile.exists()) await finalFile.delete();
      await file.rename(finalFile.path);
      current = current.copyWith(
        state: DownloadState.completed,
        progress: 1,
        localPath: finalFile.path,
        clearError: true,
      );
      await repository.update(current);
      return current;
    } on _DownloadCancelled {
      if (await file.exists()) await file.delete();
      current = current.copyWith(state: DownloadState.cancelled, progress: 0, error: 'Download cancelled.');
      await repository.update(current);
      return current;
    } catch (_) {
      if (await file.exists()) await file.delete();
      if (_cancelled.contains(job.id)) {
        current = current.copyWith(state: DownloadState.cancelled, progress: 0, error: 'Download cancelled.');
        await repository.update(current);
        return current;
      }
      current = current.copyWith(state: DownloadState.failed, progress: 0, error: 'Download failed. Retry when the connection is available.');
      await repository.update(current);
      return current;
    } finally {
      _clients.remove(job.id);
      _cancelled.remove(job.id);
      client.close(force: true);
    }
  }

  void cancel(String id) {
    _cancelled.add(id);
    _clients[id]?.close(force: true);
  }

  String _safeName(DownloadJob job) {
    final raw = job.id.replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
    return raw.length <= 80 ? raw : raw.substring(0, 80);
  }
}

final class _DownloadCancelled implements Exception {
  const _DownloadCancelled();
}
