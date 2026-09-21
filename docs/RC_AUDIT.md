# Release Candidate Audit

Exact main commit audited: `221914174cdfece18ea95f1c1d9cf076c71c81c5`

This audit is evidence, not a substitute for device verification. GitHub Actions artifacts prove deterministic buildability; they do not prove physical-device UX.

## Exact-main deterministic gates

- Release Build run `35549200039` / #231: SUCCESS.
- Android job: SUCCESS.
- Android Mobile APK build: SUCCESS.
- Android TV APK build: SUCCESS.
- Android TV product distinction + LEANBACK manifest verification: SUCCESS.
- iOS unsigned build + IPA packaging: SUCCESS.
- Provenance/checksum generation: SUCCESS.
- Release publication job: intentionally skipped because `GOLDEN_COMPLETE` was not asserted.

Artifacts from the exact-main run:

- `the-only-android` — Android Mobile + Android TV bundle.
- `the-only-ios-unsigned` — unsigned IPA.
- `the-only-release-bundle` — release bundle with `SHA256SUMS` and `BUILD_PROVENANCE.txt`.

## Gates now evidenced

- TO-32 functional integration/smoke: six-interface navigation/runtime smoke exists and the exact-main test suite passes.
- TO-33 LIVE verification: the legal/authorized-source LIVE workflow passed on the merge candidate immediately before merge; runtime legal provider paths remain covered on main.
- TO-37 independent Android Mobile/TV builds: exact-main workflow produced both and verified they are distinct, with TV LEANBACK requirements.
- TO-38 unsigned IPA packaging/signing-state validation: exact-main workflow built and packaged the unsigned IPA and provenance records the no-codesign state.

## Remaining blockers before TO-39 can pass

- TO-25: native HLS/MP4/DASH code path exists, but device playback evidence is still required.
- TO-26: legal embed/WebView fallback policy exists, but runtime/device evidence for an explicitly allowlisted legal embed host is still required.
- TO-28: Android Mobile device/runtime UX verification remains required.
- TO-29: Android TV D-pad/focus/10-foot device proof remains required.
- TO-30: iOS physical-device/runtime proof remains required; current IPA is unsigned by design.
- TO-34: device matrix remains DEVICE_REQUIRED_PENDING where hardware evidence is unavailable.
- TO-35: performance/reliability evidence still needs explicit runtime measurements and offline/recovery checks.
- TO-36: accessibility/RTL/focus consistency needs device-facing evidence, especially TV focus traversal.

## Release decision

TO-39 remains `IN_PROGRESS`. Do not dispatch the workflow with `publish_release=true` and `golden_gate=GOLDEN_COMPLETE` until the remaining blockers above have evidence. The workflow correctly refuses ordinary push publication and keeps the release job gated.
