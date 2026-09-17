import 'package:flutter/material.dart';

import '../../core/domain/models.dart';
import 'cinema_controller.dart';

class CinemaScreen extends StatefulWidget {
  const CinemaScreen({super.key, required this.controller});

  final CinemaController controller;

  @override
  State<CinemaScreen> createState() => _CinemaScreenState();
}

class _CinemaScreenState extends State<CinemaScreen> {
  final _query = TextEditingController();
  List<MediaItem> _results = const [];
  MediaItem? _selected;
  List<StreamSource> _sources = const [];
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() { _busy = true; _error = null; });
    try {
      final results = await widget.controller.search(_query.text.trim());
      if (!mounted) return;
      setState(() { _results = results; _selected = null; _sources = const []; });
    } catch (_) {
      if (mounted) setState(() => _error = 'Search failed');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _open(MediaItem item) async {
    setState(() { _busy = true; _error = null; _selected = item; _sources = const []; });
    final sources = await widget.controller.sources(item);
    if (!mounted) return;
    setState(() { _sources = sources; _busy = false; });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('cinema-screen'),
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          key: const Key('cinema-search-field'),
          controller: _query,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
          decoration: InputDecoration(
            labelText: 'Search Cinema',
            suffixIcon: IconButton(key: const Key('cinema-search-button'), onPressed: _busy ? null : _search, icon: const Icon(Icons.search)),
          ),
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) Text(_error!, key: const Key('cinema-error')),
        for (final item in _results)
          ListTile(
            key: Key('cinema-item-${item.id}'),
            title: Text(item.title),
            subtitle: Text(item.kind.name),
            onTap: () => _open(item),
            trailing: IconButton(
              key: Key('cinema-favorite-${item.id}'),
              tooltip: 'Favorite',
              onPressed: () => widget.controller.favorite(item),
              icon: const Icon(Icons.favorite_border),
            ),
          ),
        if (_selected case final item?) ...[
          const Divider(),
          Text(item.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          FilledButton.icon(
            key: const Key('cinema-watch'),
            onPressed: () => widget.controller.watch(item),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Watch'),
          ),
          const SizedBox(height: 8),
          if (_sources.isEmpty && !_busy) const Text('No direct sources available'),
          for (var i = 0; i < _sources.length; i++)
            ListTile(
              key: Key('cinema-source-$i'),
              title: Text(_sources[i].quality ?? _sources[i].protocol.name.toUpperCase()),
              subtitle: Text(_sources[i].providerId),
              trailing: OutlinedButton.icon(
                key: Key('cinema-download-$i'),
                onPressed: () async {
                  try {
                    await widget.controller.download(item, _sources[i]);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Download queued')));
                  } on StateError catch (error) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
                  }
                },
                icon: const Icon(Icons.download),
                label: const Text('Download'),
              ),
            ),
        ],
      ],
    );
  }
}
