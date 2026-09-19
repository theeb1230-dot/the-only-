# The Only — Master Delivery Plan

Status values: TODO, IN_PROGRESS, BLOCKED, DONE.

The project is one unified application, not a wrapper around multiple applications. Source archives under `archives/` remain immutable evidence/reference inputs. PRODUCT DONE requires user-visible functional evidence; controllers, models, fixtures, and unit/widget tests alone are not completion evidence. Deterministic CI, LIVE verification, and DEVICE verification are recorded separately.

## Golden 40 governance
This plan has exactly TO-01..TO-40. TO-01..TO-30 preserve the historical scope and evidence already earned; TO-31..TO-40 add the missing Golden-release gates. No TO-41+ task may be created. New defects are subtasks/evidence under the closest TO.

| ID | Task | Status | Acceptance evidence / retained scope |
|---|---|---|---|
| TO-01 | Repository baseline, archive inventory and exact SHAs | DONE | MANIFEST.tsv and repository history; archives remain immutable |
| TO-02 | License/NOTICE/source provenance gate | DONE | LICENSE_REVIEW.md + THIRD_PARTY_NOTICES.md exact-SHA ledger |
| TO-03 | Architecture/domain contracts without UI-provider coupling | DONE | ARCHITECTURE.md + domain/provider contracts |
| TO-04 | Shared navigation/routing/back/deep state | DONE | unified six-section shell and navigation tests |
| TO-05 | Settings, local feature gates and preferences | DONE | Settings controls + sixth-section local gate |
| TO-06 | Real ProviderRegistry and allowed-provider registration | IN_PROGRESS | legal Cinema provider registered; broader registry/product verification pending |
| TO-07 | Real ResolverRegistry integrated with Watch paths | IN_PROGRESS | resolver contracts/controllers exist; shell/player Watch integration pending |
| TO-08 | Health/ranking/priority/fallback/timeouts/cancellation | IN_PROGRESS | health store/policies exist; end-to-end probes/ranking pending |
| TO-09 | Cache/dedup/validation/quality/preferences | IN_PROGRESS | policies exist; complete end-to-end integration pending |
| TO-10 | Cinema functional search/results | IN_PROGRESS | legal runtime provider search/results exists; LIVE/UI runtime proof pending |
| TO-11 | Cinema details/list/seasons/episodes where applicable | IN_PROGRESS | deeper functional product path pending |
| TO-12 | Cinema source selection + separate Watch | IN_PROGRESS | source/Watch UI exists; actual player path pending |
| TO-13 | Cinema separate Download + honest failure states | IN_PROGRESS | explicit Download action exists; execution/durable state pending |
| TO-14 | Persistent Favorites | IN_PROGRESS | production SharedPreferences-backed repository exists and survives repository recreation in deterministic tests; app-restart/DEVICE evidence pending |
| TO-15 | Persistent History/resume | IN_PROGRESS | production SharedPreferences-backed repository exists and preserves resume position across repository recreation; app-restart/DEVICE evidence pending |
| TO-16 | Persistent legal Downloads manager | IN_PROGRESS | persistent queue/state repository exists; platform download execution and restart/DEVICE evidence pending |
| TO-17 | Live TV provider/configuration + authorized channels | IN_PROGRESS | PR #23 merged legal runtime channel provider; LIVE/player proof pending |
| TO-18 | Live TV EPG now/next/list | IN_PROGRESS | legal provider exposes programme data; product runtime proof pending |
| TO-19 | Live TV stream selection/player/fallback | IN_PROGRESS | stream selection exists; actual playback/fallback runtime proof pending |
| TO-20 | Sources UI results/source/quality/failure/fallback | IN_PROGRESS | provider discovery exists; full product flow pending |
| TO-21 | Resolvers diagnostics UI + real Watch integration | IN_PROGRESS | diagnostics/controller exists; Watch/player integration pending |
| TO-22 | Tools/Providers registry/health/priority/preferences/diagnostics | IN_PROGRESS | registry/health controller exists; complete product diagnostics pending |
| TO-23 | Sixth interface clean-room + Feature Gate + functional runtime proof | IN_PROGRESS | gate exists; placeholder is not acceptance; license/archive review required before clean-room implementation |
| TO-24 | Production persistent storage + migrations/versioning | IN_PROGRESS | SharedPreferences-backed schema v2 store, serialized writes, corruption fail-closed behavior and v1→v2 migration exist; real app restart/DEVICE evidence pending |
| TO-25 | Player core HLS/MP4/DASH with platform-safe behavior | IN_PROGRESS | coordinator/adapters modeled; actual platform playback pending |
| TO-26 | Legal embed/WebView last-resort fallback + host/navigation policy | IN_PROGRESS | policy/model work exists; runtime adapter proof pending |
| TO-27 | Watch/Download separation end-to-end | IN_PROGRESS | UI actions separate; complete execution paths pending |
| TO-28 | Android Mobile UX/runtime integration | IN_PROGRESS | APK builds; DEVICE/runtime UX verification pending |
| TO-29 | Android TV 10-foot UX, D-pad/focus/LEANBACK/launcher | IN_PROGRESS | independent TV APK + LEANBACK build verification exists; D-pad/device UX proof pending |
| TO-30 | iOS scaffold/runtime build readiness | IN_PROGRESS | unsigned iOS build/package succeeds; runtime/device proof pending |
| TO-31 | Security hardening and credential-safe logging | IN_PROGRESS | must regress https://user:pass@x.test/a?token=secret#part with no userInfo/query/fragment/token/secret leakage; URL/redirect/host policies fail closed |
| TO-32 | Functional integration/smoke suite for all six interfaces | TODO | loading/error/empty/results/details/actions/player/back/state; fixtures are not runtime proof |
| TO-33 | LIVE verification suite using legal/authorized sources | TODO | separate from deterministic CI; record honest live failures |
| TO-34 | DEVICE verification matrix: Android Mobile/TV/iOS | TODO | unavailable hardware remains DEVICE_REQUIRED_PENDING, never PASS |
| TO-35 | Performance/reliability hardening | TODO | startup/memory/cancellation/retry/offline/error recovery/no hangs |
| TO-36 | Accessibility/localization/RTL/TV focus consistency | TODO | understandable loading/empty/error states and platform focus evidence |
| TO-37 | Independent Android Mobile/TV release builds from same source/version | IN_PROGRESS | workflow proves distinct APKs and TV LEANBACK configuration; final RC proof pending |
| TO-38 | macOS no-codesign IPA packaging and signing-state validation | IN_PROGRESS | unsigned IPA packaging succeeds; final Payload/version/UNSIGNED validation pending |
| TO-39 | Release-candidate audit | TODO | all executable TOs evidenced, six interfaces functional, analyze/tests/build/security/license green, no placeholders/secrets/unauthorized sources |
| TO-40 | GOLDEN COMPLETE RELEASE | TODO | exact-main Mobile APK + TV APK + IPA, integrity/application/version/manifest/signing validation, SHA256SUMS + BUILD_PROVENANCE + release manifest, GitHub Release assets verified non-zero via Releases API |

## Execution rules
- Never exceed TO-01..TO-40; refine new work as subtasks/evidence under these tasks.
- Recompute DONE/40 from this file and current repository/runtime evidence every run. Reopen a DONE task if evidence contradicts functional completion.
- A provider/content interface is not DONE until its applicable user path reaches visible results/details/source selection/separate Watch or Download/player or honest diagnosable failure/navigation/persistence.
- Deterministic CI is necessary but never substitutes for LIVE or DEVICE verification.
- Do not copy source code until the license gate records explicit reuse permission and obligations. Restricted/no-license sources remain reference-only and any allowed behavioral reimplementation is clean-room.
- Preserve archive bytes and hashes.
- Shared Navigation, Settings, Player, Search, History, Favorites and Downloads are product-level services.
- UI never hard-codes provider internals; Provider and Resolver implementations remain behind contracts.
- No unauthorized live links and no paywall/CAPTCHA/DRM bypass.
- Do not publish a new release before TO-39 passes. Actions artifacts are not a GitHub Release.
