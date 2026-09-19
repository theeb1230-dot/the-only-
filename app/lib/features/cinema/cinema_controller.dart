import '../../core/data/downloads.dart';
import '../../core/data/library.dart';
import '../../core/domain/download_policy.dart';
import '../../core/domain/models.dart';
import '../../core/domain/play_request.dart';
import '../../core/providers/provider.dart';
import '../../core/providers/product_provider_selector.dart';
import '../../core/resolvers/resolver_coordinator.dart';
import '../../core/search/search.dart';

class CinemaController {
  CinemaController({required this.providers,required this.favorites,required this.history,required this.downloads,this.resolver,this.providerSelector});
  final List<MediaProvider> providers;
  final FavoritesRepository favorites;
  final HistoryRepository history;
  final DownloadsRepository downloads;
  final ResolverCoordinator? resolver;
  final ProductProviderSelector? providerSelector;

  List<MediaProvider> get _activeProviders => providerSelector?.order(providers) ?? providers;
  Future<List<MediaItem>> search(String query) async => (await SearchCoordinator(_activeProviders).search(query)).where((item)=>item.kind==MediaKind.movie||item.kind==MediaKind.series).toList(growable:false);

  Future<List<StreamSource>> sources(MediaItem item) async {
    final all=<StreamSource>[];
    for(final provider in _activeProviders){
      try { final result=await provider.sourcesFor(item).timeout(const Duration(seconds:8)); all.addAll(result.sources); } catch (_) {}
    }
    return all;
  }
  Future<void> favorite(MediaItem item)=>favorites.add(item);
  Future<MediaRequest> watch(MediaItem item) async { await history.save(HistoryEntry(item:item,position:Duration.zero,updatedAt:DateTime.now().toUtc())); return MediaRequest(item:item,action:MediaAction.watch); }
  Future<StreamSource?> resolveForWatch(MediaItem item,StreamSource source) async { await watch(item); final activeResolver=resolver; if(activeResolver==null)return null; final resolved=await activeResolver.resolve(source.uri); return resolved.isEmpty?null:resolved.first; }
  Future<DownloadJob> download(MediaItem item,StreamSource source) async { if(!isDownloadable(source))throw StateError('Selected source is not directly downloadable'); final job=DownloadJob(id:'${item.kind.name}:${item.id}:${source.uri}',source:source,state:DownloadState.queued); await downloads.enqueue(job); return job; }
}
