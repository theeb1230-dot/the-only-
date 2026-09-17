class CachePolicy {
  const CachePolicy({this.searchTtl = const Duration(minutes: 10), this.streamTtl = const Duration(minutes: 3)});
  final Duration searchTtl;
  final Duration streamTtl;

  bool isFresh(DateTime storedAt, DateTime now, Duration ttl) => now.difference(storedAt) <= ttl;
}
