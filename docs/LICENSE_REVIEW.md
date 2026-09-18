# Source License / Reuse Gate

This document is a technical compliance gate, not legal advice.

## Policy
Public availability is not permission to redistribute or incorporate code. License decisions are tied to the exact archived/source SHA inspected. Missing or ambiguous licensing fails closed. A `REFERENCE_ONLY` source may inform public behavior and contracts, but no protected source expression is copied.

| Source capability | Source | Exact SHA | License evidence | Status | Allowed now |
|---|---|---|---|---|---|
| Cinema application | Cinema-HQ | `b4ed6cddb31f33918bef05f436167126ed2b275e` | root contains README/APK and no LICENSE | REFERENCE_ONLY | clean-room behavior only |
| Metadata/embed providers | TMDB-Embed-API | `aacac098f25db5f6fe0614670987c54ae32fc2eb` | `LICENSE.md`, MIT, copyright 2025 Inside4ndroid | CLEARED_MIT | reuse permitted only with MIT copyright/permission notice preserved; dependency/provider legality remains independently gated |
| Python provider/resolver set | PyEmbed-Api | `5741c84279defef8b3a5754f2305d39980683b2f` | no LICENSE/NOTICE found at inspected root | REFERENCE_ONLY | clean-room behavior only |
| IPTV/M3U/XCAPI/EPG | M3U-XCAPI-EPG-IPTV-Stremio | `2d15db6e9f6c4f70258f8ed88fd9203cb0f5c907` | no LICENSE/NOTICE found at inspected root | REFERENCE_ONLY | clean-room behavior only |
| URL resolution | ResolveURL | `7841296a564bf0d6cb301e8e4b6bed1a1201dc88` | root `LICENSE` is GNU GPL v2 | REFERENCE_ONLY_GPL2 | do not copy into The Only while product-wide GPL obligations are not explicitly adopted; implement compatible behavior independently |
| Native in-app playback | Flutter `video_player` | package `2.14.0` | pub.dev license: BSD-3-Clause, copyright The Flutter Authors | CLEARED_BSD3 | dependency use permitted with required copyright/conditions/disclaimer notices retained |
| Local preferences persistence | Flutter `shared_preferences` | package `2.5.5` | pub.dev license: BSD-3-Clause, copyright The Flutter Authors | CLEARED_BSD3 | dependency use permitted for non-secret local state with required notices retained |
| Sixth section | archived agreed source | exact SHA retained in archive manifest | separate review required before code migration | REFERENCE_ONLY | local feature gate only until cleared |
| Android/ADB tooling | Electron-ADB-ToolKit | archived | out of product | OUT_OF_PRODUCT | archive/reference only |
| Desktop/hardware projects | DeskEngine, XStat, Rainity projects | archived | out of product | OUT_OF_PRODUCT | archive/reference only |
| Other archived projects | remaining archive entries | archived | not product inputs | ARCHIVE_ONLY | retain unchanged |

## Required evidence before source copying
Record exact SHA, license filename/text, SPDX identifier when determinable, copyright/notice obligations, redistribution/modification conditions, dependency-license concerns, and a final reuse decision. A permissive project license does not automatically clear third-party provider endpoints, content, credentials, trademarks, datasets, or dependencies.

## Current implementation rule
Cinema and Live TV implementations are clean-room. Sources may use The Only-owned adapters against documented interfaces; no TMDB-Embed-API source is copied unless its MIT notice is carried into `THIRD_PARTY_NOTICES.md` and the copied portion is separately reviewed. ResolveURL and PyEmbed behavior remains independently implemented behind The Only resolver contracts. Native playback uses the official Flutter `video_player` package under BSD-3-Clause; media/provider authorization remains a separate fail-closed gate. Local Favorites/History/Download metadata persistence uses Flutter `shared_preferences` under BSD-3-Clause and must not store provider credentials, userInfo, access tokens, or other secrets.
