import 'package:flutter/material.dart';

import '../../core/data/download_transfer.dart';
import '../../core/data/downloads.dart';
import '../../core/data/library.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key, required this.favorites, required this.history, required this.downloads, this.transfer});
  final FavoritesRepository favorites;
  final HistoryRepository history;
  final DownloadsRepository downloads;
  final DownloadTransferService? transfer;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _downloadState(DownloadJob job) => switch (job.state) {
    DownloadState.queued => 'في الانتظار',
    DownloadState.running => 'جارٍ التنزيل ${(job.progress * 100).round()}%',
    DownloadState.paused => 'متوقف مؤقتًا',
    DownloadState.completed => 'مكتمل',
    DownloadState.failed => 'فشل',
    DownloadState.cancelled => 'ملغى',
  };

  Future<void> _refresh() async => setState(() {});

  Future<void> _start(DownloadJob job) async {
    final transfer = widget.transfer;
    if (transfer == null) return;
    setState(() {});
    await transfer.start(job);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: _refresh,
    child: ListView(
      key: const Key('library-screen'),
      padding: const EdgeInsets.all(16),
      children: [
        Text('المفضلة', style: Theme.of(context).textTheme.titleLarge),
        FutureBuilder(
          future: widget.favorites.all(),
          builder: (context, snapshot) {
            final items = snapshot.data ?? const [];
            if (items.isEmpty) return const ListTile(key: Key('favorites-empty'), title: Text('لا توجد عناصر مفضلة بعد'));
            return Column(children: [for (final item in items) ListTile(key: Key('favorite-${item.id}'), title: Text(item.title), subtitle: Text(item.kind.name), trailing: IconButton(key: Key('favorite-remove-${item.id}'), tooltip: 'حذف من المفضلة', icon: const Icon(Icons.delete_outline), onPressed: () async { await widget.favorites.remove(item.id); await _refresh(); }))]);
          },
        ),
        const Divider(),
        Text('السجل', style: Theme.of(context).textTheme.titleLarge),
        FutureBuilder(
          future: widget.history.all(),
          builder: (context, snapshot) {
            final entries = snapshot.data ?? const [];
            if (entries.isEmpty) return const ListTile(key: Key('history-empty'), title: Text('لا يوجد سجل مشاهدة بعد'));
            return Column(children: [for (final entry in entries) ListTile(key: Key('history-${entry.item.id}'), title: Text(entry.item.title), subtitle: Text('استئناف عند ${entry.position.inSeconds} ث'))]);
          },
        ),
        const Divider(),
        Text('التنزيلات', style: Theme.of(context).textTheme.titleLarge),
        FutureBuilder(
          future: widget.downloads.all(),
          builder: (context, snapshot) {
            final jobs = snapshot.data ?? const <DownloadJob>[];
            if (jobs.isEmpty) return const ListTile(key: Key('downloads-empty'), title: Text('لا توجد تنزيلات في قائمة الانتظار'));
            return Column(children: [
              for (final job in jobs)
                ListTile(
                  key: Key('download-${job.id}'),
                  title: Text(job.source.uri.pathSegments.isEmpty ? job.id : job.source.uri.pathSegments.last),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_downloadState(job)),
                      if (job.state == DownloadState.running) LinearProgressIndicator(value: job.progress > 0 ? job.progress : null),
                      if (job.error != null) Text(job.error!, key: Key('download-error-${job.id}')),
                      if (job.state == DownloadState.completed && job.localPath != null) const Text('محفوظ للمشاهدة دون اتصال'),
                    ],
                  ),
                  trailing: Wrap(
                    children: [
                      if (widget.transfer != null && {DownloadState.queued, DownloadState.failed, DownloadState.cancelled, DownloadState.paused}.contains(job.state))
                        IconButton(key: Key('download-start-${job.id}'), tooltip: 'بدء / إعادة المحاولة', icon: const Icon(Icons.download), onPressed: () => _start(job)),
                      if (widget.transfer != null && job.state == DownloadState.running)
                        IconButton(key: Key('download-cancel-${job.id}'), tooltip: 'إلغاء', icon: const Icon(Icons.cancel_outlined), onPressed: () { widget.transfer!.cancel(job.id); }),
                      IconButton(key: Key('download-remove-${job.id}'), tooltip: 'حذف التنزيل', icon: const Icon(Icons.delete_outline), onPressed: () async { widget.transfer?.cancel(job.id); await widget.downloads.remove(job.id); await _refresh(); }),
                    ],
                  ),
                ),
            ]);
          },
        ),
      ],
    ),
  );
}
