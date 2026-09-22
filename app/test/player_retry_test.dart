import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/player/retry.dart';

void main() {
  test('bounded retry retries transient failures then succeeds', () async {
    var calls = 0;
    final result = await runWithBoundedRetry<int>(
      attempts: 3,
      retryDelay: Duration.zero,
      shouldRetry: (error) => error is TimeoutException,
      operation: (attempt) async {
        calls++;
        if (attempt < 3) throw TimeoutException('temporary');
        return 42;
      },
    );

    expect(result, 42);
    expect(calls, 3);
  });

  test('bounded retry fails fast for deterministic failures', () async {
    var calls = 0;

    await expectLater(
      runWithBoundedRetry<void>(
        attempts: 3,
        retryDelay: Duration.zero,
        shouldRetry: (error) => error is TimeoutException,
        operation: (attempt) async {
          calls++;
          throw StateError('superseded');
        },
      ),
      throwsStateError,
    );

    expect(calls, 1);
  });
}
