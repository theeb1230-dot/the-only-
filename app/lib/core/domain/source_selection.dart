import 'models.dart';
import 'quality.dart';

StreamSource? selectBestStream(Iterable<StreamSource> sources) {
  final ordered = orderByQuality(sources, (source) => source.quality);
  return ordered.isEmpty ? null : ordered.first;
}
