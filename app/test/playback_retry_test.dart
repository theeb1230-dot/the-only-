import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/player/retry.dart';

void main() {
  test('retries a failed playback operation and returns the successful result', () async {
    var calls = 0;
    final delays = <Duration>[];

    final result = await runWithBoundedRetry<String>(
      attempts: 2,
      retryDelay: const Duration(milliseconds: 10),
      delay: (duration) async => delays.add(duration),
      operation: (attempt) async {
        calls++;
        if (attempt == 1) throw StateError('first attempt failed');
        return 'ok';
      },
    );

    expect(result, 'ok');
    expect(calls, 2);
    expect(delays, [const Duration(milliseconds: 10)]);
  });

  test('surfaces the final playback error after bounded attempts', () async {
    var calls = 0;

    await expectLater(
      runWithBoundedRetry<void>(
        attempts: 2,
        retryDelay: Duration.zero,
        operation: (_) async {
          calls++;
          throw StateError('still failing');
        },
      ),
      throwsA(isA<StateError>()),
    );

    expect(calls, 2);
  });

  test('rejects an invalid attempt count', () async {
    await expectLater(
      runWithBoundedRetry<void>(
        attempts: 0,
        operation: (_) async {},
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}
