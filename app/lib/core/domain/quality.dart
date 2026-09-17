int qualityRank(String? quality) {
  if (quality == null) return 0;
  final match = RegExp(r'(\d{3,4})').firstMatch(quality);
  return int.tryParse(match?.group(1) ?? '') ?? 0;
}

List<T> orderByQuality<T>(Iterable<T> values, String? Function(T value) qualityOf) {
  final result = values.toList();
  result.sort((a, b) => qualityRank(qualityOf(b)).compareTo(qualityRank(qualityOf(a))));
  return result;
}
