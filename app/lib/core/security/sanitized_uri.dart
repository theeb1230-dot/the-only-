String sanitizeUriForLog(Uri uri) {
  final host = uri.host;
  final port = uri.hasPort ? ':${uri.port}' : '';
  final path = uri.path.isEmpty ? '/' : uri.path;
  return '${uri.scheme}://$host$port$path';
}
