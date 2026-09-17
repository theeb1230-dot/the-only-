import 'package:flutter/material.dart';

import '../../core/domain/download_policy.dart';
import '../../core/domain/models.dart';
import 'resolvers_controller.dart';

class ResolversScreen extends StatefulWidget {
  const ResolversScreen({super.key, required this.controller, this.onWatch, this.onDownload});
  final ResolversController controller;
  final Future<void> Function(StreamSource source)? onWatch;
  final Future<void> Function(StreamSource source)? onDownload;
  @override State<ResolversScreen> createState() => _ResolversScreenState();
}
class _ResolversScreenState extends State<ResolversScreen> {
  final _input = TextEditingController();
  List<StreamSource> _results = const [];
  bool? _supported;
  bool _busy = false;
  String? _error;
  @override void dispose() { _input.dispose(); super.dispose(); }
  Future<void> _resolve() async {
    final uri = Uri.tryParse(_input.text.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) { setState(() { _supported = false; _results = const []; _error = 'Enter a valid URI'; }); return; }
    final supported = widget.controller.supports(uri);
    setState(() { _supported = supported; _busy = supported; _error = null; _results = const []; });
    if (!supported) return;
    final results = await widget.controller.resolve(uri);
    if (!mounted) return;
    setState(() { _results = results; _busy = false; if (results.isEmpty) _error = 'Resolver returned no streams'; });
  }
  @override Widget build(BuildContext context) => ListView(key: const Key('resolvers-screen'), padding: const EdgeInsets.all(16), children: [
    TextField(key: const Key('resolver-uri'), controller: _input, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'URI to resolve')),
    const SizedBox(height: 8), FilledButton.icon(key: const Key('resolver-run'), onPressed: _busy ? null : _resolve, icon: const Icon(Icons.link), label: const Text('Resolve')),
    if (_busy) const LinearProgressIndicator(),
    if (_supported != null) Text(_supported! ? 'Supported' : 'Unsupported', key: const Key('resolver-support')),
    if (_error != null) Text(_error!, key: const Key('resolver-error')),
    for (var i = 0; i < _results.length; i++) ListTile(key: Key('resolver-result-$i'), title: Text(_results[i].quality ?? _results[i].protocol.name.toUpperCase()), subtitle: Text('${_results[i].providerId} • ${_results[i].protocol.name}'), trailing: Wrap(spacing: 8, children: [
      FilledButton(key: Key('resolver-watch-$i'), onPressed: widget.onWatch == null ? null : () => widget.onWatch!(_results[i]), child: const Text('Watch')),
      if (isDownloadable(_results[i])) OutlinedButton(key: Key('resolver-download-$i'), onPressed: widget.onDownload == null ? null : () => widget.onDownload!(_results[i]), child: const Text('Download')),
    ])),
  ]);
}
