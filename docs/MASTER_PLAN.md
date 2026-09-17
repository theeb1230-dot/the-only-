# The Only — Master Delivery Plan

Status values: TODO, IN_PROGRESS, BLOCKED, DONE.

The project is one unified application, not a wrapper around multiple applications. Source archives under `archives/` remain immutable evidence/reference inputs.

## 40 → 30 governance migration
The original TO-01..TO-40 ledger is preserved in Git history. Effective with this revision, the plan has exactly 30 main task containers. Former TO-31..TO-40 scope is not deleted or declared complete: it is carried as explicit subtasks/evidence under TO-08, TO-10..TO-14, TO-17, TO-19..TO-21 and TO-29..TO-30. No TO-31+ task may be created after this migration.

| ID | Task | Status | Depends on | Acceptance evidence / retained subtasks |
|---|---|---|---|---|
| TO-01 | Inventory archived sources and exact SHAs | DONE | - | MANIFEST.tsv retained |
| TO-02 | Establish architecture contract | DONE | TO-01 | ARCHITECTURE.md |
| TO-03 | Establish license/reuse gate | DONE | TO-01 | exact-SHA LICENSE_REVIEW.md + THIRD_PARTY_NOTICES.md ledger |
| TO-04 | Select unified application technology | DONE | TO-02 | Flutter decision recorded |
| TO-05 | Bootstrap The Only Flutter app | DONE | TO-04 | Flutter scaffold passed CI analyze/test |
| TO-06 | Core domain models | DONE | TO-05 | committed models/tests passed CI |
| TO-07 | Unified navigation shell | DONE | TO-05 | six-section shell/widget tests passed CI |
| TO-08 | Settings + security/privacy hardening | IN_PROGRESS | TO-06 | shared registry wired; durable persistence pending; retained former TO-34: URL/log/network hardening including credential-safe logging |
| TO-09 | Section enable/disable controls | DONE | TO-08 | Settings controls merged in PR #8 after exact-head analyze/test passed |
| TO-10 | Cinema product section + provider migration | IN_PROGRESS | TO-03,TO-07 | controller + functional search/source/favorite/Watch/Download UI merged in PR #9; retained former TO-30: clean-room provider behavior; shell/player/deeper behavior pending |
| TO-11 | Live TV product section + IPTV migration | IN_PROGRESS | TO-03,TO-07 | channels/EPG/streams/fallback controller merged; retained former TO-32 M3U/XCAPI/EPG clean-room migration; product UI pending |
| TO-12 | Sources product section + source-provider migration | IN_PROGRESS | TO-03,TO-07 | discovery/search/grouped sources merged; retained former TO-31 MIT-cleared migration obligations; product UI pending |
| TO-13 | Resolvers product section + resolver migration | IN_PROGRESS | TO-03,TO-07 | clean-room controller + functional URI/support/results/Watch/Download UI merged in PR #13 after exact-head CI; retained former TO-33 reference-only migration; shell/player integration pending |
| TO-14 | Tools/Providers product section | IN_PROGRESS | TO-07 | shared registry/health/preferences controller + deterministic tests merged; provider enablement/priority/health Product UI implemented on active branch; shell/diagnostics integration pending |
| TO-15 | Sixth section feature gate | DONE | TO-09 | hidden by default; Settings enable/navigation widget flow passed exact-head CI and merged in PR #8 |
| TO-16 | Provider interface contract | DONE | TO-06 | contract/registry exercised by green CI |
| TO-17 | Resolver interface + migration contract | IN_PROGRESS | TO-03,TO-06 | contract + controller + product UI merged; reference-only inputs retained from former TO-33; shared shell/player integration pending |
| TO-18 | Unified stream model | DONE | TO-06 | model exercised by Cinema/Live TV green CI |
| TO-19 | Provider health + fallback ranking | IN_PROGRESS | TO-16 | health store/Tools integration and health display; retained former TO-20 fallback ordering; end-to-end ranking and real probes pending |
| TO-20 | Unified search + provider preferences | IN_PROGRESS | TO-16 | shared search coordinator green; Cinema UI integrated; remaining section UI/ranking preferences pending |
| TO-21 | Unified player + HLS/MP4/DASH/embed adapters | IN_PROGRESS | TO-18 | coordinator/tests present; retained former TO-22/23/24 adapter scope; actual platform playback pending |
| TO-22 | Favorites + History persistence | IN_PROGRESS | TO-06 | memory repos and Cinema integration green; durable repositories pending |
| TO-23 | Downloads queue + execution | IN_PROGRESS | TO-18 | explicit Cinema/Resolver Download actions; durable queue/platform execution pending |
| TO-24 | Stream validation/dedup/quality/cache/timeouts | IN_PROGRESS | TO-18 | core policies exist; end-to-end integration pending |
| TO-25 | Android Mobile UX + build | TODO | TO-07 | retained former TO-35; Android build + UI tests |
| TO-26 | Android TV D-pad/Focus/LEANBACK + build | TODO | TO-07 | retained former TO-36; focus/navigation/manifest/build evidence |
| TO-27 | CI quality + deterministic E2E gates | IN_PROGRESS | TO-05 | exact-head pub get/analyze/test green through PR #13; expand six-interface fixture E2E/build gates; retains former TO-37 evidence |
| TO-28 | Release build pipeline + provenance | TODO | TO-25,TO-26,TO-27 | retained former TO-38: reproducible Mobile/TV APKs, SHA256SUMS, BUILD_PROVENANCE, honest signing |
| TO-29 | Persistent local storage + product documentation/attribution | IN_PROGRESS | TO-03,TO-06 | abstraction/tests present; durable backend pending; retained former TO-39 docs/attribution scope |
| TO-30 | Release candidate validation | TODO | TO-10..TO-29 | retained former TO-40: complete six-interface checklist, same-SHA artifacts and release verification |

## Execution rules
- Never exceed these 30 main tasks; refine with subtasks inside TO-01..TO-30.
- The historical TO-31..TO-40 scope remains binding through the migration mapping above and Git history.
- A task becomes DONE only with repository evidence and passing applicable tests.
- Do not copy source code until TO-03 records an explicit reusable decision and obligations.
- Preserve archive bytes and hashes.
- Shared Navigation, Settings, Player, Search, History, Favorites and Downloads are mandatory product-level services.
- Provider and Resolver implementations sit behind contracts; UI sections never hard-code provider internals.
- Deterministic CI uses legal fixtures/local mocks; live verification is a separate gate.
