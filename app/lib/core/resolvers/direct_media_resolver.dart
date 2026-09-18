import '../domain/models.dart';
import '../security/url_policy.dart';
import 'resolver.dart';

/// Resolves already-direct, policy-allowed media URLs into playable sources.
///
/// This resolver performs no scraping, redirects, credential handling, DRM
/// bypass, or provider-specific extraction. It exists so legal/direct provider
/// sources travel through the same ResolverRegistry path used by Watch flows.
final class DirectMediaResolver implements StreamResolver {
  const DirectMediaResolver({this.policy = const UrlPolicy()});

  final UrlPolicy policy;

  @override
  String get id => 'direct-media';

  @override
  bool supports(Uri uri) => policy.allows(uri) && _protocolFor(uri) != null;

  @override
  Future<List<StreamSource>> resolve(Uri uri) async {
    final protocol = _protocolFor(uri);
    if (!policy.allows(uri) || protocol == null) return const [];
    return [
      StreamSource(
        uri: uri,
        protocol: protocol,
        providerId: id,
        quality: 'direct',
      ),
    ];
  }

  StreamProtocol? _protocolFor(Uri uri) {
    final path = uri.path.toLowerCase();
    if (path.endsWith('.m3u8')) return StreamProtocol.hls;
    if (path.endsWith('.mpd')) return StreamProtocol.dash;
    if (path.endsWith('.mp4')) return StreamProtocol.mp4;
    return null;
  }
}
