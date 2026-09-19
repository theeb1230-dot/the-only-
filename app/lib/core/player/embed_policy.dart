import '../security/url_policy.dart';

/// Fail-closed policy for the last-resort in-app embed surface.
///
/// Embeds are never a DRM/paywall/CAPTCHA bypass. A caller must explicitly
/// provide the legal hosts it is authorized to display; an empty allowlist
/// rejects every navigation.
class EmbedNavigationPolicy {
  EmbedNavigationPolicy({required Set<String> allowedHosts})
      : _urlPolicy = UrlPolicy(allowedHosts: Set.unmodifiable(allowedHosts));

  final UrlPolicy _urlPolicy;

  bool allowsInitial(Uri uri) => _urlPolicy.allows(uri);

  bool allowsNavigation(Uri initial, Uri destination) =>
      _urlPolicy.allowsRedirect(initial, destination);
}
