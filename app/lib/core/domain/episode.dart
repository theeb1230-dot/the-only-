class EpisodeRef {
  const EpisodeRef({required this.seriesId, required this.season, required this.episode});
  final String seriesId;
  final int season;
  final int episode;

  String get key => '$seriesId:s$season:e$episode';
}
