import 'package:flutter/material.dart';

import '../../core/data/downloads.dart';
import '../../core/data/library.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key, required this.favorites, required this.history, required this.downloads});
  final FavoritesRepository favorites;
  final HistoryRepository history;
  final DownloadsRepository downloads;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  Future<void> _refresh() async => setState(() {});

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: _refresh,
    child: ListView(
      key: const Key('library-screen'),
      padding: const EdgeInsets.all(16),
      children: [
        Text('Favorites', style: Theme.of(context).textTheme.titleLarge),
        FutureBuilder(
          future: widget.favorites.all(),
          builder: (context, snapshot) {
            final items = snapshot.data ?? const [];
            if (items.isEmpty) return const ListTile(key: Key('favorites-empty'), title: Text('No favorites yet'));
            return Column(children: [for (final item in items) ListTile(key: Key('favorite-${item.id}'), title: Text(item.title), subtitle: Text(item.kind.name), trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async { await widget.favorites.remove(item.id); await _refresh(); }))]);
          },
        ),
        const Divider(),
        Text('History', style: Theme.of(context).textTheme.titleLarge),
        FutureBuilder(
          future: widget.history.all(),
          builder: (context, snapshot) {
            final entries = snapshot.data ?? const [];
            if (entries.isEmpty) return const ListTile(key: Key('history-empty'), title: Text('No watch history yet'));
            return Column(children: [for (final entry in entries) ListTile(key: Key('history-${entry.item.id}'), title: Text(entry.item.title), subtitle: Text('Resume at ${entry.position.inSeconds}s'))]);
          },
        ),
        const Divider(),
        Text('Downloads', style: Theme.of(context).textTheme.titleLarge),
        FutureBuilder(
          future: widget.downloads.all(),
          builder: (context, snapshot) {
            final jobs = snapshot.data ?? const <DownloadJob>[];
            if (jobs.isEmpty) return const ListTile(key: Key('downloads-empty'), title: Text('No downloads queued'));
            return Column(children: [for (final job in jobs) ListTile(key: Key('download-${job.id}'), title: Text(job.source.uri.pathSegments.isEmpty ? job.id : job.source.uri.pathSegments.last), subtitle: Text(job.state.name), trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async { await widget.downloads.remove(job.id); await _refresh(); }))]);
          },
        ),
      ],
    ),
  );
}
