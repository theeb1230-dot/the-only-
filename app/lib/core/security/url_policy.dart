class UrlPolicy {
  const UrlPolicy({this.allowHttpForLocalhost = false});
  final bool allowHttpForLocalhost;

  bool allows(Uri uri) {
    if (uri.scheme == 'https') return uri.host.isNotEmpty;
    if (allowHttpForLocalhost && uri.scheme == 'http') {
      return uri.host == 'localhost' || uri.host == '127.0.0.1';
    }
    return false;
  }
}
