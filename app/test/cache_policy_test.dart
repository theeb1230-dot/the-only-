import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/data/cache_policy.dart';

void main() {
  test('cache expires beyond configured ttl', () {
    const policy = CachePolicy();
    final stored = DateTime.utc(2026);
    expect(policy.isFresh(stored, stored.add(const Duration(minutes: 2)), policy.streamTtl), isTrue);
    expect(policy.isFresh(stored, stored.add(const Duration(minutes: 4)), policy.streamTtl), isFalse);
  });
}
