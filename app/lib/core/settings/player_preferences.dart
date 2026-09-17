enum PreferredQuality { auto, p360, p480, p720, p1080, highest }

class PlayerPreferences {
  const PlayerPreferences({this.quality = PreferredQuality.auto, this.autoplayNext = true});
  final PreferredQuality quality;
  final bool autoplayNext;
}
