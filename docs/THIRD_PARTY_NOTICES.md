# Third-Party Notices

This ledger records third-party licensing relevant to The Only. Archive retention is not a declaration that archived code is incorporated into the product.

## TMDB-Embed-API
- Source: Inside4ndroid/TMDB-Embed-API
- Exact inspected SHA: `aacac098f25db5f6fe0614670987c54ae32fc2eb`
- License: MIT
- Copyright: Copyright (c) 2025 Inside4ndroid
- Obligation: preserve the copyright and MIT permission notice in copies or substantial portions.
- Current product use: behavioral/contract reference only in the Sources implementation. No source code from TMDB-Embed-API has been copied in the current integration.

## ResolveURL
- Exact inspected SHA: `7841296a564bf0d6cb301e8e4b6bed1a1201dc88`
- License file: GNU GPL version 2.
- Current product use: reference only. No ResolveURL source code is copied into The Only. Resolver behavior is implemented independently behind The Only contracts unless a future explicit licensing decision changes this.

## Flutter video_player
- Package: `video_player` from publisher `flutter.dev`.
- Product dependency range: `^2.14.0`.
- License: BSD-3-Clause, copyright The Flutter Authors.
- Obligation: retain the copyright notice, redistribution conditions, and disclaimer in source/binary distributions as required by the license.
- Current product use: native in-app playback surface for policy-approved direct media sources. Provider/content authorization remains independently gated.

## Flutter webview_flutter
- Package: `webview_flutter` from publisher `flutter.dev`.
- Product dependency range: `^4.13.0`.
- License: BSD-3-Clause, copyright The Flutter Authors.
- Obligation: retain the copyright notice, redistribution conditions, and disclaimer in source/binary distributions as required by the license.
- Current product use: last-resort in-app embed rendering only after an explicit legal host allowlist check; external navigation, unsafe redirects and non-HTTPS sources fail closed.

## Flutter shared_preferences
- Package: `shared_preferences` from publisher `flutter.dev`.
- Product dependency range: `^2.5.5`.
- License: BSD-3-Clause, copyright The Flutter Authors.
- Obligation: retain the copyright notice, redistribution conditions, and disclaimer in source/binary distributions as required by the license.
- Current product use: versioned local persistence for non-secret Favorites, History/resume metadata, and Download queue metadata. Credentials and provider secrets are explicitly excluded.

## No-license sources
Cinema-HQ, PyEmbed-Api, and M3U-XCAPI-EPG-IPTV-Stremio had no root LICENSE/NOTICE in the exact revisions inspected. They remain reference-only; The Only uses clean-room implementations based on public behavior and its own contracts.

## Flutter path_provider
- Package: `path_provider` from publisher `flutter.dev`.
- Product dependency range: `^2.1.5`.
- License: BSD-3-Clause, copyright The Flutter Authors.
- Obligation: retain the copyright notice, redistribution conditions, and disclaimer in source/binary distributions as required by the license.
- Current product use: resolves app-owned support storage for legal offline media files; it does not expose or store provider credentials.
