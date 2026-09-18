# Source License / Reuse Gate

This document is a technical compliance gate, not legal advice.

## Policy
Public availability is not permission to redistribute or incorporate code. License decisions are tied to the exact archived/source SHA inspected. Missing or ambiguous licensing fails closed. A `REFERENCE_ONLY` source may inform public behavior and contracts, but no protected source expression is copied.

| Source capability | Source | Exact SHA | License evidence | Status | Allowed now |
|---|---|---|---|---|---|
| Cinema application | Cinema-HQ | `b4ed6cddb31f33918bef05f436167126ed2b275e` | root contains README/APK and no LICENSE | REFERENCE_ONLY | clean-room behavior only |
| Metadata/embed providers | TMDB-Embed-API | `aacac098f25db5f6fe0614670987c54ae32fc2eb` | `LICENSE.md`, MIT | CLEARED_MIT | reuse only with notice and separate provider legality review |
| Python provider/resolver set | PyEmbed-Api | `5741c84279defef8b3a5754f2305d39980683b2f` | no LICENSE/NOTICE | REFERENCE_ONLY | clean-room behavior only |
| IPTV/M3U/XCAPI/EPG | M3U-XCAPI-EPG-IPTV-Stremio | `2d15db6e9f6c4f70258f8ed88fd9203cb0f5c907` | no LICENSE/NOTICE | REFERENCE_ONLY | clean-room behavior only |
| URL resolution | ResolveURL | `7841296a564bf0d6cb301e8e4b6bed1a1201dc88` | GPL v2 | REFERENCE_ONLY_GPL2 | independent implementation only |
| Native in-app playback | Flutter `video_player` | package `2.14.0` | BSD-3-Clause | CLEARED_BSD3 | dependency use with notices |
| Local preferences persistence | Flutter `shared_preferences` | package `2.5.5` | BSD-3-Clause | CLEARED_BSD3 | non-secret local state only |
| Sixth section | source #14 from archive manifest | `a92d63c0a542ba37370bb14a026b5cc227e1165d` | recursive exact-SHA tree contains no LICENSE/NOTICE; README grants no license | REFERENCE_ONLY | clean-room behavior only; no source copying; local gate disabled by default |
| Android/ADB tooling | Electron-ADB-ToolKit | archived | out of product | OUT_OF_PRODUCT | archive/reference only |
| Desktop/hardware projects | DeskEngine, XStat, Rainity projects | archived | out of product | OUT_OF_PRODUCT | archive/reference only |
| Other archived projects | remaining archive entries | archived | not product inputs | ARCHIVE_ONLY | retain unchanged |

## Required evidence before source copying
Record exact SHA, license filename/text, SPDX identifier when determinable, copyright/notice obligations, redistribution/modification conditions, dependency-license concerns, and a final reuse decision.

## Current implementation rule
Cinema and Live TV are clean-room. ResolveURL/PyEmbed behavior remains independently implemented behind contracts. Native playback and local persistence retain their package notices. The sixth interface is an independent clean-room local diagnostics implementation based only on generic observable capability categories; no source #14 code, identifiers, assets, or protected implementation expression are copied.
