import 'package:flutter/material.dart';

import '../../core/domain/models.dart';
import 'sources_controller.dart';

class SourcesScreen extends StatefulWidget {
  const SourcesScreen({super.key, required this.controller, this.onWatch, this.onDownload});

  final SourcesController controller;
  final Future<void> Function(MediaItem item, StreamSource source)? onWatch;
  final Future<void> Function(MediaItem item, StreamSource source)? onDownload;

  @override
  State<SourcesScreen> createState() => _SourcesScreenState();
}

class _SourcesScreenState extends State<SourcesScreen> {
  final _query = TextEditingController();
  List<MediaItem> _results = const [];
  MediaItem? _selected;
  Map<String, List<StreamSource>> _sources = const {};
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
      setState(() { _results = results; _selected = null; _sources = const {}; });
    } catch (_) {
      if (mounted) setState(() => _error = 'Search failed');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _open(MediaItem item) async {
    setState(() { _busy = true; _error = null; _selected = item; _sources = const {}; });
    try {
      final sources = await widget.controller.sourcesByProvider(item);
      if (!mounted) return;
      setState(() => _sources = sources);
    } catch (_) {
      if (mounted) setState(() => _error = 'Unable to load sources');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('sources-screen'),
      padding: const EdgeInsets.all(16),
      children: [
        Text('Sources', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [for (final id in widget.controller.providerIds) Chip(label: Text(id))]),
        TextField(
          key: const Key('sources-search-field'),
          controller: _query,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
          decoration: InputDecoration(
            labelText: 'Search all providers',
            suffixIcon: IconButton(key: const Key('sources-search-button'), onPressed: _busy ? null : _search, icon: const Icon(Icons.search)),
          ),
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) Text(_error!, key: const Key('sources-error')),
        if (_results.isEmpty && !_busy && _query.text.isNotEmpty) const Text('No results'),
        for (final item in _results)
          ListTile(key: Key('sources-item-${item.id}'), title: Text(item.title), subtitle: Text(item.kind.name), onTap: () => _open(item)),
        if (_selected case final item?) ...[
          const Divider(),
          Text(item.title, style: Theme.of(context).textTheme.titleLarge),
          if (_sources.isEmpty && !_busy) const Text('No sources available'),
          for (final entry in _sources.entries) ...[
            Padding(padding: const EdgeInsets.only(top: 12), child: Text(entry.key, style: Theme.of(context).textTheme.titleMedium)),
            for (var i = 0; i < entry.value.length; i++)
              ListTile(
                key: Key('sources-stream-${entry.key}-$i'),
                title: Text(entry.value[i].quality ?? entry.value[i].protocol.name.toUpperCase()),
                subtitle: Text(entry.value[i].protocol.name),
                trailing: Wrap(spacing: 8, children: [
                  FilledButton(key: Key('sources-watch-${entry.key}-$i'), onPressed: widget.onWatch == null ? null : () => widget.onWatch!(item, entry.value[i]), child: const Text('Watch')),
                  OutlinedButton(key: Key('sources-download-${entry.key}-$i'), onPressed: widget.onDownload == null ? null : () => widget.onDownload!(item, entry.value[i]), child: const Text('Download')),
                ]),
              ),
          ],
        ],
      ],
    );
  }
}
