class TimeoutPolicy {
  const TimeoutPolicy({this.provider = const Duration(seconds: 8), this.resolver = const Duration(seconds: 8)});
  final Duration provider;
  final Duration resolver;
}
