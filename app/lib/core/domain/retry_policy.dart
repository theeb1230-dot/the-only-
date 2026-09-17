class RetryPolicy {
  const RetryPolicy({this.maxAttempts = 2, this.delay = const Duration(milliseconds: 250)});
  final int maxAttempts;
  final Duration delay;
}
