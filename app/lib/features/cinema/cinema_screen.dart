import 'package:flutter/material.dart';

import '../../core/domain/models.dart';
import '../../core/player/playback_screen.dart';
import 'cinema_controller.dart';

typedef CinemaPlayerLauncher = Future<void> Function(
  BuildContext context,
  MediaItem item,
  StreamSource source,
);

class CinemaScreen extends StatefulWidget {
  const CinemaScreen({super.key, required this.controller, this.playerLauncher});
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
      final r = await widget.controller.search(_query.text.trim());
      if (!mounted) return;
      setState(() {
        _results = r;
        _selected = null;
        _sources = const [];
      });
    } catch (_) {
      if (mounted) setState(() => _error = 'فشل البحث');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _open(MediaItem item) async {
    setState(() {
      _busy = true;
      _error = null;
      _selected = item;
      _sources = const [];
    });
    try {
      final s = await widget.controller.sources(item);
      if (!mounted) return;
      setState(() => _sources = s);
    } catch (_) {
      if (mounted) setState(() => _error = 'تعذر تحميل مصادر التشغيل');
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
        setState(() => _error = 'تعذر تحليل مصدر التشغيل المحدد بأمان');
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

  Widget _poster(MediaItem item) {
    final url = item.posterUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: url == null
            ? const ColoredBox(
                color: Color(0xFF24212B),
                child: Center(child: Icon(Icons.movie_outlined, size: 42)),
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: Color(0xFF24212B),
                  child: Center(child: Icon(Icons.broken_image_outlined, size: 42)),
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListView(
        key: const Key('cinema-screen'),
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const Key('cinema-search-field'),
            controller: _query,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              labelText: 'ابحث في المكتبة',
              hintText: 'اسم فيلم أو مسلسل',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                key: const Key('cinema-search-button'),
                tooltip: 'بحث في السينما',
                onPressed: _busy ? null : _search,
                icon: const Icon(Icons.arrow_forward),
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (_busy) const LinearProgressIndicator(key: Key('cinema-loading')),
          if (_error != null)
            Semantics(
              liveRegion: true,
              child: Text(_error!, key: const Key('cinema-error')),
            ),
          if (!_busy && _error == null && _results.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Text('لا توجد نتائج متاحة الآن', key: Key('cinema-empty')),
              ),
            ),
          if (_results.isNotEmpty) ...[
            Text('المحتوى المتاح', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            for (final item in _results)
              Card(
                key: Key('cinema-item-${item.id}'),
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.only(bottom: 14),
                child: InkWell(
                  onTap: () => _open(item),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _poster(item),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 4),
                                  Text([
                                    if (item.year != null) '${item.year}',
                                    if (item.rating != null) '★ ${item.rating!.toStringAsFixed(1)}',
                                  ].join('  •  ')),
                                  if (item.overview != null) ...[
                                    const SizedBox(height: 6),
                                    Text(item.overview!, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              key: Key('cinema-favorite-${item.id}'),
                              tooltip: 'إضافة إلى المفضلة',
                              onPressed: () => widget.controller.favorite(item),
                              icon: const Icon(Icons.favorite_border),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
          if (_selected case final item?) ...[
            const Divider(height: 32),
            Semantics(
              key: Key('cinema-details-${item.id}'),
              container: true,
              label: 'تفاصيل ${item.title}',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: Theme.of(context).textTheme.headlineSmall),
                  Text(item.kind == MediaKind.series ? 'مسلسل' : 'فيلم'),
                  Text('مصادر التشغيل المتاحة: ${_sources.length}'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (_sources.isEmpty && !_busy && _error == null)
              const Text('لا توجد مصادر تشغيل مباشرة', key: Key('cinema-sources-empty')),
            for (var i = 0; i < _sources.length; i++)
              ListTile(
                key: Key('cinema-source-$i'),
                contentPadding: EdgeInsets.zero,
                title: Text(_sources[i].quality ?? _sources[i].protocol.name.toUpperCase()),
                subtitle: Text(_sources[i].providerId == 'legal-demo' ? 'المكتبة العامة' : _sources[i].providerId),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    FilledButton.icon(
                      key: Key('cinema-watch-$i'),
                      onPressed: _busy ? null : () => _watch(item, _sources[i]),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('مشاهدة'),
                    ),
                    OutlinedButton.icon(
                      key: Key('cinema-download-$i'),
                      onPressed: () => _download(item, _sources[i]),
                      icon: const Icon(Icons.download),
                      label: const Text('تنزيل'),
                    ),
                  ],
                ),
              ),
          ],
        ],
      );
}
