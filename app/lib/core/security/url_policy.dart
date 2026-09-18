class UrlPolicy {
  const UrlPolicy({
    this.allowHttpForLocalhost = false,
    this.allowedHosts,
  });

  final bool allowHttpForLocalhost;
  final Set<String>? allowedHosts;

  bool allows(Uri uri) {
    if (uri.userInfo.isNotEmpty) return false;
    if (uri.host.isEmpty) return false;
    if (!_hostAllowed(uri.host)) return false;

    if (uri.scheme == 'https') return true;
    if (allowHttpForLocalhost && uri.scheme == 'http') {
      return _isLoopback(uri.host);
    }
    return false;
  }

  bool allowsRedirect(Uri from, Uri to) {
    if (!allows(from) || !allows(to)) return false;
    if (_isLoopback(from.host) != _isLoopback(to.host)) return false;
    if (from.scheme == 'https' && to.scheme != 'https') return false;
    return true;
  }

  bool _hostAllowed(String host) {
    final allowList = allowedHosts;
    if (allowList == null) return true;
    final normalized = host.toLowerCase();
    return allowList.any((entry) => entry.toLowerCase() == normalized);
  }

  bool _isLoopback(String host) =>
      host == 'localhost' || host == '127.0.0.1' || host == '::1';
}
