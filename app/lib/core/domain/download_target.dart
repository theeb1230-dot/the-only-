String safeDownloadName(String title) {
  final cleaned = title.replaceAll(RegExp(r'[^A-Za-z0-9 _.-]'), '').trim();
  return cleaned.isEmpty ? 'download' : cleaned;
}
