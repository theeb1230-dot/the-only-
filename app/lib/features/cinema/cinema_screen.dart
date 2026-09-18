import 'package:flutter/material.dart';

import '../../core/domain/models.dart';
import '../../core/player/player_screen.dart';
import 'cinema_controller.dart';

typedef CinemaPlayerLauncher = Future<void> Function(
  BuildContext context,
  MediaItem item,
  StreamSource source,
);

class CinemaScreen extends StatefulWidget {
  const CinemaScreen({
    super.key,
    required this.controller,
    this.playerLauncher,
  });

  final CinemaController controller;
  final CinemaPlayerLauncher? playerLauncher;

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
    try {
      final sources = await widget.controller.sources(item);
      if (!mounted) return;
      setState(() => _sources = sources);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not load sources');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _launchPlayer(MediaItem item, StreamSource source) async {
    final launcher = widget.playerLauncher;
    if (launcher != null) {
      await launcher(context, item, source);
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerScreen(source: source, title: item.title),
      ),
    );
  }

  Future<void> _watch(MediaItem item, StreamSource source) async {
    setState(() { _busy = true; _error = null; });
    try {
      final resolved = await widget.controller.resolveForWatch(item, source);
      if (!mounted) return;
      if (resolved == null) {
        setState(() => _error = 'Selected source could not be resolved safely');
        return;
      }
      await _launchPlayer(item, resolved);
    } catch (_) {
      if (mounted) setState(() => _error = 'Watch source resolution failed');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _download(MediaItem item, StreamSource source) async {
    try {
      await widget.controller.download(item, source);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Download queued')));
    } on StateError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    }
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
          if (_sources.isEmpty && !_busy) const Text('No direct sources available'),
          for (var i = 0; i < _sources.length; i++)
            ListTile(
              key: Key('cinema-source-$i'),
              title: Text(_sources[i].quality ?? _sources[i].protocol.name.toUpperCase()),
              subtitle: Text(_sources[i].providerId),
              trailing: Wrap(
                spacing: 8,
                children: [
                  FilledButton.icon(
                    key: Key('cinema-watch-$i'),
                    onPressed: _busy ? null : () => _watch(item, _sources[i]),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Watch'),
                  ),
                  OutlinedButton.icon(
                    key: Key('cinema-download-$i'),
                    onPressed: () => _download(item, _sources[i]),
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
