import 'package:flutter/material.dart';

import '../../core/domain/download_policy.dart';
import '../../core/domain/models.dart';
import '../../core/player/playback_screen.dart';
import 'sources_controller.dart';

typedef SourcesPlayerLauncher = Future<void> Function(
  BuildContext context,
  MediaItem item,
  StreamSource source,
);

class SourcesScreen extends StatefulWidget {
  const SourcesScreen({
    super.key,
    required this.controller,
    this.playerLauncher,
  });

  final SourcesController controller;
  final SourcesPlayerLauncher? playerLauncher;

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
  void initState() {
    super.initState();
    _search();
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final results = await widget.controller.search(_query.text.trim());
      if (!mounted) return;
      setState(() {
        _results = results;
        _selected = null;
        _sources = const {};
      });
    } catch (_) {
      if (mounted) setState(() => _error = 'فشل البحث في المصادر');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _open(MediaItem item) async {
    setState(() {
      _busy = true;
      _error = null;
      _selected = item;
      _sources = const {};
    });
    try {
      final sources = await widget.controller.sourcesByProvider(item);
      if (!mounted) return;
      setState(() => _sources = sources);
    } catch (_) {
      if (mounted) setState(() => _error = 'تعذر تحميل المصادر');
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
        builder: (_) => PlaybackScreen(source: source, title: item.title),
      ),
    );
  }

  Future<void> _watch(MediaItem item, StreamSource source) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final resolved = await widget.controller.resolveForWatch(item, source);
      if (!mounted) return;
      if (resolved == null) {
        setState(() => _error = 'تعذر تحليل المصدر المحدد بأمان');
        return;
      }
      await _launchPlayer(item, resolved);
    } catch (_) {
      if (mounted) setState(() => _error = 'فشل تحليل مصدر المشاهدة');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _download(MediaItem item, StreamSource source) async {
    try {
      await widget.controller.download(item, source);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة التنزيل إلى قائمة الانتظار')),
      );
    } on StateError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  String _providerLabel(String id) => id == 'legal-demo' ? 'المكتبة العامة' : id;

  @override
  Widget build(BuildContext context) => ListView(
        key: const Key('sources-screen'),
        padding: const EdgeInsets.all(16),
        children: [
          Text('المصادر', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final id in widget.controller.providerIds)
                Chip(
                  avatar: const Icon(Icons.cloud_outlined, size: 18),
                  label: Text(_providerLabel(id)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('sources-search-field'),
            controller: _query,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              labelText: 'البحث في جميع المزودات',
              hintText: 'اتركه فارغًا لعرض المحتوى المتاح',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                key: const Key('sources-search-button'),
                tooltip: 'بحث',
                onPressed: _busy ? null : _search,
                icon: const Icon(Icons.arrow_forward),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_busy) const LinearProgressIndicator(key: Key('sources-loading')),
          if (_error != null)
            Semantics(
              liveRegion: true,
              child: Text(_error!, key: const Key('sources-error')),
            ),
          if (_results.isEmpty && !_busy && _error == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(child: Text('لا توجد نتائج', key: Key('sources-empty'))),
            ),
          for (final item in _results)
            Card(
              key: Key('sources-item-${item.id}'),
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: item.posterUrl == null
                    ? const CircleAvatar(child: Icon(Icons.movie_outlined))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          item.posterUrl!,
                          width: 58,
                          height: 58,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(
                            width: 58,
                            height: 58,
                            child: ColoredBox(
                              color: Color(0xFF24212B),
                              child: Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        ),
                      ),
                title: Text(item.title),
                subtitle: Text(item.kind == MediaKind.series ? 'مسلسل' : 'فيلم'),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => _open(item),
              ),
            ),
          if (_selected case final item?) ...[
            const Divider(height: 30),
            Text(item.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (_sources.isEmpty && !_busy && _error == null)
              const Text('لا توجد مصادر متاحة', key: Key('sources-streams-empty')),
            for (final entry in _sources.entries) ...[
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _providerLabel(entry.key),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (var i = 0; i < entry.value.length; i++)
                ListTile(
                  key: Key('sources-stream-${entry.key}-$i'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.play_circle_outline),
                  title: Text(entry.value[i].quality ?? entry.value[i].protocol.name.toUpperCase()),
                  subtitle: Text(entry.value[i].protocol.name.toUpperCase()),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      FilledButton(
                        key: Key('sources-watch-${entry.key}-$i'),
                        onPressed: _busy ? null : () => _watch(item, entry.value[i]),
                        child: const Text('مشاهدة'),
                      ),
                      if (isDownloadable(entry.value[i]))
                        OutlinedButton(
                          key: Key('sources-download-${entry.key}-$i'),
                          onPressed: () => _download(item, entry.value[i]),
                          child: const Text('تنزيل'),
                        ),
                    ],
                  ),
                ),
            ],
          ],
        ],
      );
}
