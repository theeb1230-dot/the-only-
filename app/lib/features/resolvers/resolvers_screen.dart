import 'package:flutter/material.dart';

import '../../core/domain/download_policy.dart';
import '../../core/domain/models.dart';
import 'resolvers_controller.dart';

class ResolversScreen extends StatefulWidget {
  const ResolversScreen({
    super.key,
    required this.controller,
    this.onWatch,
    this.onDownload,
  });

  final ResolversController controller;
  final Future<void> Function(StreamSource source)? onWatch;
  final Future<void> Function(StreamSource source)? onDownload;

  @override
  State<ResolversScreen> createState() => _ResolversScreenState();
}

class _ResolversScreenState extends State<ResolversScreen> {
  static const _safeSample =
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

  final _input = TextEditingController();
  List<StreamSource> _results = const [];
  bool? _supported;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _useSample() async {
    _input.text = _safeSample;
    await _resolve();
  }

  Future<void> _resolve() async {
    final uri = Uri.tryParse(_input.text.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      setState(() {
        _supported = false;
        _results = const [];
        _error = 'أدخل رابطًا صالحًا';
      });
      return;
    }
    final supported = widget.controller.supports(uri);
    setState(() {
      _supported = supported;
      _busy = supported;
      _error = null;
      _results = const [];
    });
    if (!supported) return;
    try {
      final results = await widget.controller.resolve(uri);
      if (!mounted) return;
      setState(() {
        _results = results;
        if (results.isEmpty) {
          _error = 'لم يُرجع المحلل أي مصادر تشغيل';
        }
      });
    } catch (_) {
      if (mounted) setState(() => _error = 'فشل التحليل بأمان');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
        key: const Key('resolvers-screen'),
        padding: const EdgeInsets.all(16),
        children: [
          Text('المحللات', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          const Text(
            'تحقق من رابط HTTPS مباشر وحوّله إلى مصدر تشغيل موحّد. الروابط غير المدعومة أو غير الآمنة تُرفض بدل فتحها بصمت.',
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('resolver-uri'),
            controller: _input,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.go,
            onSubmitted: (_) => _resolve(),
            decoration: const InputDecoration(
              labelText: 'الرابط المراد تحليله',
              hintText: 'https://example.com/video.mp4',
              prefixIcon: Icon(Icons.link),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                key: const Key('resolver-run'),
                onPressed: _busy ? null : _resolve,
                icon: const Icon(Icons.manage_search),
                label: const Text('تحليل الرابط'),
              ),
              OutlinedButton.icon(
                key: const Key('resolver-safe-sample'),
                onPressed: _busy ? null : _useSample,
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('تجربة رابط عام آمن'),
              ),
            ],
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(key: Key('resolver-loading')),
            ),
          if (_supported != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _supported! ? 'مدعوم' : 'غير مدعوم',
                key: const Key('resolver-support'),
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Semantics(
                liveRegion: true,
                child: Text(_error!, key: const Key('resolver-error')),
              ),
            ),
          if (_results.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text('النتائج', style: Theme.of(context).textTheme.titleMedium),
          ],
          for (var i = 0; i < _results.length; i++)
            Card(
              child: ListTile(
                key: Key('resolver-result-$i'),
                title: Text(
                  _results[i].quality ??
                      _results[i].protocol.name.toUpperCase(),
                ),
                subtitle: Text(
                  '${_results[i].providerId} • ${_results[i].protocol.name}',
                ),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    FilledButton(
                      key: Key('resolver-watch-$i'),
                      onPressed: widget.onWatch == null
                          ? null
                          : () => widget.onWatch!(_results[i]),
                      child: const Text('مشاهدة'),
                    ),
                    if (isDownloadable(_results[i]))
                      OutlinedButton(
                        key: Key('resolver-download-$i'),
                        onPressed: widget.onDownload == null
                            ? null
                            : () => widget.onDownload!(_results[i]),
                        child: const Text('تنزيل'),
                      ),
                  ],
                ),
              ),
            ),
        ],
      );
}
