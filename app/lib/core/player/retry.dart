typedef RetryOperation<T> = Future<T> Function(int attempt);
typedef RetryDelay = Future<void> Function(Duration duration);

Future<T> runWithBoundedRetry<T>({
  required RetryOperation<T> operation,
  int attempts = 2,
  Duration retryDelay = const Duration(milliseconds: 250),
  RetryDelay delay = Future<void>.delayed,
}) async {
  if (attempts < 1) {
    throw ArgumentError.value(attempts, 'attempts', 'must be at least 1');
  }

  Object? lastError;
  StackTrace? lastStackTrace;

  for (var attempt = 1; attempt <= attempts; attempt++) {
    try {
      return await operation(attempt);
    } catch (error, stackTrace) {
      lastError = error;
      lastStackTrace = stackTrace;
      if (attempt == attempts) break;
      if (retryDelay > Duration.zero) await delay(retryDelay);
    }
  }

  Error.throwWithStackTrace(lastError!, lastStackTrace!);
}
