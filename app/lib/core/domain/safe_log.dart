String safeUriForLog(Uri uri) {
  final sanitized = Uri(
    scheme: uri.scheme,
    userInfo: uri.userInfo,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
    path: uri.path,
  );
  return sanitized.toString();
}
