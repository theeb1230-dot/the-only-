import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models.dart';
import 'downloads.dart';
import 'library.dart';

/// Versioned local persistence for user-owned library state.
///
/// The schema intentionally stores only non-secret application state. Network
/// credentials, tokens and provider secrets must never be written here.
final class PersistentLibraryStore {
  PersistentLibraryStore(this.preferences);

  static const int schemaVersion = 2;
  static const _schemaKey = 'the_only.storage.schema';
  static const _favoritesKey = 'the_only.v1.favorites';
  static const _historyKey = 'the_only.v1.history';
  static const _downloadsKey = 'the_only.v1.downloads';

  final SharedPreferences preferences;
  Future<void> _writeTail = Future<void>.value();

  Future<void> initialize() async {
    final current = preferences.getInt(_schemaKey);
    if (current == null) {
      final ok = await preferences.setInt(_schemaKey, schemaVersion);
      if (!ok) throw StateError('Could not initialize local storage');
      return;
    }
    if (current > schemaVersion) {
      throw StateError('Local storage schema is newer than this app supports');
    }
    if (current < schemaVersion) {
      await _migrate(current, schemaVersion);
    }
  }

  Future<void> _migrate(int from, int to) async {
    if (from < 1 || to > schemaVersion || from > to) {
      throw StateError('Unsupported local storage migration: $from -> $to');
    }

    var current = from;
    while (current < to) {
      switch (current) {
        case 1:
          // v2 intentionally keeps the v1 collection payloads unchanged.
          // The migration establishes an explicit sequential upgrade path so
          // future schemas never silently reinterpret user-owned state.
          current = 2;
        default:
          if (current < to) {
            throw StateError(
              'Unsupported local storage migration step: $current -> ${current + 1}',
            );
          }
      }
    }

    final ok = await preferences.setInt(_schemaKey, to);
    if (!ok) throw StateError('Could not persist local storage migration');
  }

  List<Object?> readList(String key) {
    final raw = preferences.getString(key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      return decoded is List<Object?> ? decoded : const [];
    } on FormatException {
      // Corrupt user state must fail closed rather than crash the application.
      return const [];
    }
  }

  Future<void> writeList(String key, List<Object?> value) {
    final encoded = jsonEncode(value);
    final operation = _writeTail.then((_) async {
      final ok = await preferences.setString(key, encoded);
      if (!ok) throw StateError('Could not persist local state');
    });
    _writeTail = operation.catchError((_) {});
    return operation;
  }

  String get favoritesKey => _favoritesKey;
  String get historyKey => _historyKey;
  String get downloadsKey => _downloadsKey;
}

final class PersistentFavoritesRepository implements FavoritesRepository {
  PersistentFavoritesRepository(this.store);
  final PersistentLibraryStore store;

  @override
  Future<List<MediaItem>> all() async => store
      .readList(store.favoritesKey)
      .map(_mediaFromJson)
      .whereType<MediaItem>()
      .toList(growable: false);

  @override
  Future<void> add(MediaItem item) async {
    final current = (await all()).where((candidate) => candidate.id != item.id).toList();
    current.add(item);
    await store.writeList(store.favoritesKey, current.map(_mediaToJson).toList());
  }

  @override
  Future<void> remove(String mediaId) async {
    final current = (await all()).where((item) => item.id != mediaId).toList();
    await store.writeList(store.favoritesKey, current.map(_mediaToJson).toList());
  }
}

final class PersistentHistoryRepository implements HistoryRepository {
  PersistentHistoryRepository(this.store);
  final PersistentLibraryStore store;

  @override
  Future<List<HistoryEntry>> all() async {
    final entries = store
        .readList(store.historyKey)
        .map(_historyFromJson)
        .whereType<HistoryEntry>()
        .toList();
    entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return entries;
  }

  @override
  Future<void> save(HistoryEntry entry) async {
    final current = (await all()).where((candidate) => candidate.item.id != entry.item.id).toList();
    current.insert(0, entry);
    await store.writeList(store.historyKey, current.map(_historyToJson).toList());
  }
}

final class PersistentDownloadsRepository implements DownloadsRepository {
  PersistentDownloadsRepository(this.store);
  final PersistentLibraryStore store;

  @override
  Future<List<DownloadJob>> all() async => store
      .readList(store.downloadsKey)
      .map(_downloadFromJson)
      .whereType<DownloadJob>()
      .toList(growable: false);

  @override
  Future<void> enqueue(DownloadJob job) async {
    final current = (await all()).where((candidate) => candidate.id != job.id).toList();
    current.add(job);
    await store.writeList(store.downloadsKey, current.map(_downloadToJson).toList());
  }

  @override
  Future<void> remove(String id) async {
    final current = (await all()).where((job) => job.id != id).toList();
    await store.writeList(store.downloadsKey, current.map(_downloadToJson).toList());
  }
}

Map<String, Object?> _mediaToJson(MediaItem item) => {
      'id': item.id,
      'title': item.title,
      'kind': item.kind.name,
    };

MediaItem? _mediaFromJson(Object? value) {
  if (value is! Map) return null;
  final id = value['id'];
  final title = value['title'];
  final kind = value['kind'];
  if (id is! String || title is! String || kind is! String) return null;
  try {
    return MediaItem(id: id, title: title, kind: MediaKind.values.byName(kind));
  } on ArgumentError {
    return null;
  }
}

Map<String, Object?> _historyToJson(HistoryEntry entry) => {
      'item': _mediaToJson(entry.item),
      'positionMs': entry.position.inMilliseconds,
      'updatedAt': entry.updatedAt.toUtc().toIso8601String(),
    };

HistoryEntry? _historyFromJson(Object? value) {
  if (value is! Map) return null;
  final item = _mediaFromJson(value['item']);
  final positionMs = value['positionMs'];
  final updatedAt = value['updatedAt'];
  if (item == null || positionMs is! int || updatedAt is! String || positionMs < 0) return null;
  final parsed = DateTime.tryParse(updatedAt);
  if (parsed == null) return null;
  return HistoryEntry(item: item, position: Duration(milliseconds: positionMs), updatedAt: parsed.toUtc());
}

Map<String, Object?> _sourceToJson(StreamSource source) => {
      'uri': source.uri.toString(),
      'protocol': source.protocol.name,
      'providerId': source.providerId,
      if (source.quality != null) 'quality': source.quality,
    };

StreamSource? _sourceFromJson(Object? value) {
  if (value is! Map) return null;
  final uriValue = value['uri'];
  final protocolValue = value['protocol'];
  final providerId = value['providerId'];
  final quality = value['quality'];
  if (uriValue is! String || protocolValue is! String || providerId is! String) return null;
  final uri = Uri.tryParse(uriValue);
  if (uri == null || !uri.hasScheme || !uri.hasAuthority) return null;
  try {
    return StreamSource(
      uri: uri,
      protocol: StreamProtocol.values.byName(protocolValue),
      providerId: providerId,
      quality: quality is String ? quality : null,
    );
  } on ArgumentError {
    return null;
  }
}

Map<String, Object?> _downloadToJson(DownloadJob job) => {
      'id': job.id,
      'source': _sourceToJson(job.source),
      'state': job.state.name,
    };

DownloadJob? _downloadFromJson(Object? value) {
  if (value is! Map) return null;
  final id = value['id'];
  final source = _sourceFromJson(value['source']);
  final state = value['state'];
  if (id is! String || source == null || state is! String) return null;
  try {
    return DownloadJob(id: id, source: source, state: DownloadState.values.byName(state));
  } on ArgumentError {
    return null;
  }
}
