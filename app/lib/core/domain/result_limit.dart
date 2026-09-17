List<T> limitResults<T>(Iterable<T> values, {int max = 100}) {
  if (max <= 0) return const [];
  return values.take(max).toList(growable: false);
}
