import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/history_policy.dart';

void main() {
  test('does not resume trivial or nearly completed playback', () {
    expect(shouldResume(const Duration(seconds: 5), const Duration(minutes: 10)), isFalse);
    expect(shouldResume(const Duration(minutes: 9, seconds: 40), const Duration(minutes: 10)), isFalse);
    expect(shouldResume(const Duration(minutes: 3), const Duration(minutes: 10)), isTrue);
  });
}
