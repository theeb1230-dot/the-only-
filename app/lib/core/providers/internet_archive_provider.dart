import 'dart:convert';
import 'dart:io';

import '../domain/models.dart';
import 'provider.dart';

typedef ArchiveJsonFetcher = Future<Map<String, dynamic>> Function(Uri uri);

/// Network provider for openly licensed Internet Archive video items.
/// Only Creative Commons/public-domain licensed records are exposed.
final class InternetArchiveProvider implements MediaProvider {
  InternetArchiveProvider({ArchiveJsonFetcher? fetchJson})
      : _fetchJson = fetchJson ?? _defaultFetchJson;

  final ArchiveJsonFetcher _fetchJson;

  @override
  String get id => 'internet-archive-open';

  @override
  Future<List<MediaItem>> search(String query) async {
    final needle = query.trim();
    if (needle.isEmpty) return const <MediaItem>[];

    final uri = Uri.https('archive.org', '/advancedsearch.php', {
      'q': '($needle) AND mediatype:movies AND licenseurl:*',
      'fl[]': 'identifier,title,description,year,licenseurl',
      'rows': '20',
      'page': '1',
      'output': 'json',
    });
    final json = await _fetchJson(uri);
    final response = json['response'];
    if (response is! Map) return const <MediaItem>[];
    final docs = response['docs'];
    if (docs is! List) return const <MediaItem>[];

    final items = <MediaItem>[];
    for (final raw in docs) {
      if (raw is! Map) continue;
      final identifier = _string(raw['identifier']);
      final title = _string(raw['title']);
      final license = _string(raw['licenseurl']);
      if (identifier == null || title == null || !_isOpenLicense(license)) continue;
      items.add(
        MediaItem(
          id: identifier,
          title: title,
          kind: MediaKind.movie,
          posterUrl: 'https://archive.org/services/img/${Uri.encodeComponent(identifier)}',
          overview: _string(raw['description']),
          year: _year(raw['year']),
        ),
      );
    }
    return List.unmodifiable(items);
  }

  @override
  Future<ProviderResult> sourcesFor(MediaItem item) async {
    final identifier = item.id.trim();
    if (identifier.isEmpty) {
      return ProviderResult(providerId: id, sources: const <StreamSource>[]);
    }

    final metadata = await _fetchJson(
      Uri.https('archive.org', '/metadata/${Uri.encodeComponent(identifier)}'),
    );
    final itemMetadata = metadata['metadata'];
    if (itemMetadata is! Map || !_isOpenLicense(_string(itemMetadata['licenseurl']))) {
      return ProviderResult(providerId: id, sources: const <StreamSource>[]);
    }

    final files = metadata['files'];
    if (files is! List) {
      return ProviderResult(providerId: id, sources: const <StreamSource>[]);
    }

    final sources = <StreamSource>[];
    for (final raw in files) {
      if (raw is! Map) continue;
      final name = _string(raw['name']);
      if (name == null || !name.toLowerCase().endsWith('.mp4')) continue;
      final format = (_string(raw['format']) ?? '').toLowerCase();
      if (format.isNotEmpty && !format.contains('mpeg4') && !format.contains('h.264')) continue;
      sources.add(
        StreamSource(
          uri: Uri(scheme: 'https', host: 'archive.org', pathSegments: ['download', identifier, name]),
          protocol: StreamProtocol.mp4,
          providerId: id,
          quality: _qualityFromName(name),
        ),
      );
      if (sources.length >= 4) break;
    }
    return ProviderResult(providerId: id, sources: List.unmodifiable(sources));
  }

  static Future<Map<String, dynamic>> _defaultFetchJson(Uri uri) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri).timeout(const Duration(seconds: 8));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.userAgentHeader, 'TheOnly/0.1 (+open-media-client)');
      final response = await request.close().timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('Archive request failed with ${response.statusCode}', uri: uri);
      }
      final body = await response.transform(utf8.decoder).join().timeout(const Duration(seconds: 8));
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Archive response was not a JSON object');
      }
      return decoded;
    } finally {
      client.close(force: true);
    }
  }

  static bool _isOpenLicense(String? value) {
    if (value == null) return false;
    final normalized = value.toLowerCase();
    return normalized.startsWith('https://creativecommons.org/') ||
        normalized.startsWith('http://creativecommons.org/');
  }

  static String? _string(Object? value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    if (value is List && value.isNotEmpty) return _string(value.first);
    return null;
  }

  static int? _year(Object? value) {
    if (value is int) return value;
    final text = _string(value);
    if (text == null) return null;
    final match = RegExp(r'\d{4}').firstMatch(text);
    return match == null ? null : int.tryParse(match.group(0)!);
  }

  static String? _qualityFromName(String name) {
    final lower = name.toLowerCase();
    for (final quality in const ['2160p', '1080p', '720p', '480p', '360p']) {
      if (lower.contains(quality)) return quality;
    }
    return null;
  }
}
