class NetworkPolicy {
  const NetworkPolicy({this.maxRedirects = 5, this.maxResponseBytes = 8 * 1024 * 1024});
  final int maxRedirects;
  final int maxResponseBytes;
}
