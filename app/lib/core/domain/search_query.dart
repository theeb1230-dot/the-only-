class SearchQuery {
  SearchQuery(String value) : value = value.trim().replaceAll(RegExp(r'\s+'), ' ');
  final String value;
  bool get isEmpty => value.isEmpty;
}
