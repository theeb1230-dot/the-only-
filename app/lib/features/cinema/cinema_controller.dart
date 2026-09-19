import '../../core/data/cache_policy.dart';
import '../../core/data/downloads.dart';
import '../../core/data/library.dart';
import '../../core/domain/download_policy.dart';
import '../../core/domain/models.dart';
import '../../core/domain/play_request.dart';
import '../../core/domain/validation.dart';
import '../../core/providers/provider.dart';
import '../../core/providers/product_provider_selector.dart';
import '../../core/resolvers/resolver_coordinator.dart';
import '../../core/search/search.dart';
import '../../core/security/url_policy.dart';

class _CachedSources {
  const _CachedSources(this.storedAt, this.sources);
  final DateTime storedAt;
  final List<StreamSource> sources;
}

class CinemaController {
  CinemaController({required this.providers,required this.favorites,required this.history,required this.downloads,this.resolver,this.providerSelector,CachePolicy? cachePolicy,StreamValidator? streamValidator,DateTime Function()? now})
      : cachePolicy=cachePolicy ?? const CachePolicy(),
        streamValidator=streamValidator ?? const StreamValidator(UrlPolicy()),
        now=now ?? DateTime.now;
  final List<MediaProvider> providers;
  final FavoritesRepository favorites;
  final HistoryRepository history;
  final DownloadsRepository downloads;
  final ResolverCoordinator? resolver;
  final ProductProviderSelector? providerSelector;
  final CachePolicy cachePolicy;
  final StreamValidator streamValidator;
  final DateTime Function() now;
  final Map<String,_CachedSources> _sourceCache={};

  List<MediaProvider> get _activeProviders => providerSelector?.order(providers) ?? providers;
  Future<List<MediaItem>> search(String query) async => (await SearchCoordinator(_activeProviders).search(query)).where((item)=>item.kind==MediaKind.movie||item.kind==MediaKind.series).toList(growable:false);

  Future<List<StreamSource>> sources(MediaItem item) async {
    final key='${item.kind.name}:${item.id}';
    final instant=now();
    final cached=_sourceCache[key];
    if(cached!=null && cachePolicy.isFresh(cached.storedAt,instant,cachePolicy.streamTtl)) return cached.sources;
    final all=<StreamSource>[];
    for(final provider in _activeProviders){
      try { final result=await provider.sourcesFor(item).timeout(const Duration(seconds:8)); all.addAll(result.sources.where(streamValidator.isValid)); } catch (_) {}
    }
    final dedup=<String,StreamSource>{};
    for(final source in all){
      final identity='${source.uri}|${source.protocol.name}|${source.quality ?? ''}';
      dedup.putIfAbsent(identity,()=>source);
    }
    final validated=dedup.values.toList(growable:false)..sort((a,b)=>_qualityScore(b.quality).compareTo(_qualityScore(a.quality)));
    final immutable=List<StreamSource>.unmodifiable(validated);
    _sourceCache[key]=_CachedSources(instant,immutable);
    return immutable;
  }

  int _qualityScore(String? quality){
    if(quality==null)return 0;
    final match=RegExp(r'(\d{3,4})').firstMatch(quality);
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  Future<void> favorite(MediaItem item)=>favorites.add(item);
  Future<MediaRequest> watch(MediaItem item) async { await history.save(HistoryEntry(item:item,position:Duration.zero,updatedAt:DateTime.now().toUtc())); return MediaRequest(item:item,action:MediaAction.watch); }
  Future<StreamSource?> resolveForWatch(MediaItem item,StreamSource source) async {
    await watch(item);
    final activeResolver=resolver;
    if(activeResolver==null)return null;
    final resolved=await activeResolver.resolve(source.uri);
    for(final candidate in resolved){if(streamValidator.isValid(candidate))return candidate;}
    return null;
  }
  Future<DownloadJob> download(MediaItem item,StreamSource source) async { if(!streamValidator.isValid(source))throw StateError('Selected source failed security validation'); if(!isDownloadable(source))throw StateError('Selected source is not directly downloadable'); final job=DownloadJob(id:'${item.kind.name}:${item.id}:${source.uri}',source:source,state:DownloadState.queued); await downloads.enqueue(job); return job; }
}
