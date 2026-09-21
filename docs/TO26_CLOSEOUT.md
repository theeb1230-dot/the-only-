# TO-26 closeout evidence

Task: Legal embed/WebView last-resort fallback + host/navigation policy.

Status: DONE for deterministic product/runtime integration evidence. Physical-device verification remains tracked separately under TO-34 and is not claimed here.

## Exact-main evidence

- Main SHA: `b0590674afd9cbe051e7dfa5579d281752be5277`
- Merged PR: #60 `BUILD-1.39: legal embed runtime foundation`
- PR head validated before merge: `8546b70405c57d526fc89eb615a734d857100311`
- Main CI run #277: success
- Main Release Build run #236: success for Android Mobile, Android TV, iOS unsigned IPA, and provenance

## Runtime behavior established

- Embed playback routes to an in-app WebView surface only as the embed fallback path.
- Initial and subsequent navigation fail closed against an explicit host allowlist.
- JavaScript is disabled by default.
- Blocked navigation does not open an external browser.
- Main-frame WebView load errors surface an explicit user-visible failure state.
- Direct HLS/MP4/DASH remain routed to native playback.

## Release-build evidence

Run #236 produced non-zero artifacts for the same exact main SHA:

- `the-only-android` — artifact id `10618811400` — 50,973,769 bytes — `sha256:f28fd76552774061cfc59a5e146609971ae7d972876e081d9031d2f2b428971a`
- `the-only-ios-unsigned` — artifact id `10618197501` — 7,614,848 bytes — `sha256:ba24d3aad77d8c793a3ab48bc76fb74a75a0596f748a4388a4a312489c4e3d94`
- `the-only-release-bundle` — artifact id `10618572305` — 58,589,397 bytes — `sha256:4530c576cec00e6025779640ba8482c2ee6beffca624bb923b574327916ae3ed`

The provenance job completed successfully, including artifact download, checksum/provenance generation, and provenance artifact upload.

## Scope boundary

TO-26 is closed for code, policy, deterministic runtime routing, CI, and release-build integration. Hardware/device behavior is not silently promoted to PASS; Android Mobile, Android TV/D-pad, and iOS physical-device proof remain under TO-28/29/30/34.
