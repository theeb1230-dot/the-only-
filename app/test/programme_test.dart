import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/programme.dart';

void main() {
  test('programme uses inclusive start and exclusive end', () {
    final start = DateTime.utc(2026, 1, 1, 10);
    final programme = Programme(channelId: 'c', title: 'Show', startsAt: start, endsAt: start.add(const Duration(hours: 1)));
    expect(programme.isOnAirAt(start), isTrue);
    expect(programme.isOnAirAt(start.add(const Duration(hours: 1))), isFalse);
  });
}
