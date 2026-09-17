import 'package:flutter/material.dart';

import '../../core/domain/live_channel.dart';
import '../../core/domain/models.dart';
import '../../core/domain/programme.dart';
import 'live_tv_controller.dart';

class LiveTvScreen extends StatefulWidget {
  const LiveTvScreen({super.key, required this.controller, required this.onWatch});

  final LiveTvController controller;
  final Future<void> Function(StreamSource source) onWatch;

  @override
  State<LiveTvScreen> createState() => _LiveTvScreenState();
}

class _LiveTvScreenState extends State<LiveTvScreen> {
  List<LiveChannel> _channels = const [];
  List<Programme> _guide = const [];
  List<StreamSource> _streams = const [];
  LiveChannel? _selected;
  bool _busy = false;
  String? _error;

  Future<void> _loadChannels() async {
    setState(() { _busy = true; _error = null; });
    try {
      final channels = await widget.controller.channels();
      if (mounted) setState(() => _channels = channels);
    } catch (_) {
      if (mounted) setState(() => _error = 'Channel loading failed');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _open(LiveChannel channel) async {
    setState(() { _selected = channel; _busy = true; _error = null; _guide = const []; _streams = const []; });
    try {
      final now = DateTime.now().toUtc();
      final results = await Future.wait<Object>([
        widget.controller.guide(channel.id, now.subtract(const Duration(hours: 2)), now.add(const Duration(hours: 8))),
        widget.controller.streams(channel),
      ]);
      if (!mounted) return;
      setState(() {
        _guide = results[0] as List<Programme>;
        _streams = results[1] as List<StreamSource>;
      });
    } catch (_) {
      if (mounted) setState(() => _error = 'Channel details failed');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
        key: const Key('live-tv-screen'),
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton.icon(key: const Key('live-tv-load'), onPressed: _busy ? null : _loadChannels, icon: const Icon(Icons.live_tv), label: const Text('Load channels')),
          if (_busy) const LinearProgressIndicator(),
          if (_error != null) Text(_error!, key: const Key('live-tv-error')),
          for (final channel in _channels)
            ListTile(
              key: Key('live-tv-channel-${channel.id}'),
              title: Text(channel.name),
              subtitle: channel.group == null ? null : Text(channel.group!),
              selected: _selected?.id == channel.id,
              onTap: () => _open(channel),
            ),
          if (_selected != null) ...[
            const Divider(),
            Text(_selected!.name, style: Theme.of(context).textTheme.headlineSmall),
            Text('Guide', style: Theme.of(context).textTheme.titleMedium),
            if (_guide.isEmpty && !_busy) const Text('No EPG entries'),
            for (final programme in _guide)
              ListTile(key: Key('live-tv-programme-${programme.startsAt.millisecondsSinceEpoch}'), title: Text(programme.title), subtitle: Text('${programme.startsAt.toLocal()}')),
            Text('Streams', style: Theme.of(context).textTheme.titleMedium),
            if (_streams.isEmpty && !_busy) const Text('No playable streams'),
            for (var i = 0; i < _streams.length; i++)
              ListTile(
                key: Key('live-tv-stream-$i'),
                title: Text(_streams[i].quality ?? _streams[i].protocol.name.toUpperCase()),
                subtitle: Text(_streams[i].providerId),
                trailing: FilledButton.icon(key: Key('live-tv-watch-$i'), onPressed: () => widget.onWatch(_streams[i]), icon: const Icon(Icons.play_arrow), label: const Text('Watch')),
              ),
          ],
        ],
      );
}
