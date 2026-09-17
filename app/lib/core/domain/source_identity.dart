import 'models.dart';

String streamIdentity(StreamSource source) {
  final quality = source.quality?.trim().toLowerCase() ?? '';
  return '${source.providerId}|${source.protocol.name}|${source.uri}|$quality';
}

List<StreamSource> deduplicateStreams(Iterable<StreamSource> sources) {
  final unique = <String, StreamSource>{};
  for (final source in sources) {
    unique.putIfAbsent(streamIdentity(source), () => source);
  }
  return unique.values.toList(growable: false);
}
