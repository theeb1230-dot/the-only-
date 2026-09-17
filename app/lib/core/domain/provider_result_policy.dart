import 'models.dart';
import 'result_limit.dart';
import 'source_identity.dart';

List<StreamSource> normalizeProviderSources(Iterable<StreamSource> sources, {int max = 20}) =>
    limitResults(deduplicateStreams(sources), max: max);
