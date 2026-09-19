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
| TO-06 | Real ProviderRegistry and allowed-provider registration | DONE | runtime shell constructs ProviderRegistry with the legal Cinema provider and Sources/Tools consume that same registry |
| TO-07 | Real ResolverRegistry integrated with Watch paths | DONE | runtime shell constructs ResolverRegistry/ResolverCoordinator; Cinema, Live TV, Sources and Resolvers Watch actions all route through shared resolver/player paths |
| TO-08 | Health/ranking/priority/fallback/timeouts/cancellation | DONE | production Cinema consumes persisted enablement/priority plus measured health ordering; bounded provider operations isolate failures and retain healthy fallback |
| TO-09 | Cache/dedup/validation/quality/preferences | DONE | production Cinema source path applies fail-closed StreamValidator, source dedup, quality ranking, persisted provider preferences, and TTL source caching; regression proves unsafe rejection, ranking, fresh reuse and expiry |
| TO-10 | Cinema functional search/results | DONE | production Cinema UI searches the legal runtime provider and renders visible results; widget runtime product-path test proves search -> visible result -> open |
| TO-11 | Cinema details/list/seasons/episodes where applicable | IN_PROGRESS | deeper functional product path pending |
| TO-12 | Cinema source selection + separate Watch | DONE | production Cinema UI exposes source selection and resolver-backed Watch; runtime product-path test proves resolved player launch |
| TO-13 | Cinema separate Download + honest failure states | DONE | production Cinema keeps Download separate, rejects non-downloadable or security-invalid sources, and queues direct legal sources without Watch side effects |
| TO-14 | Persistent Favorites | DONE | production SharedPreferences repository is wired into Cinema and a user-visible Library screen; recreation smoke proves persisted favorites render after store reconstruction |
| TO-15 | Persistent History/resume | DONE | Watch persists history through production repository and Library renders saved resume position after store reconstruction |
| TO-16 | Persistent legal Downloads manager | IN_PROGRESS | persistent queue/state is user-visible in Library and survives reconstruction; platform file-transfer execution remains pending |
| TO-17 | Live TV provider/configuration + authorized channels | DONE | production shell registers the authorized public-sample Live provider and runtime UI test proves visible channel loading |
| TO-18 | Live TV EPG now/next/list | DONE | Live TV UI loads channel details and renders provider programme data in the runtime product-path test |
| TO-19 | Live TV stream selection/player/fallback | DONE | Live TV runtime path proves channel -> stream -> shared resolver -> player launch; provider failures/timeouts are isolated |
| TO-20 | Sources UI results/source/quality/failure/fallback | DONE | six-interface runtime smoke proves legal provider results, source discovery, resolver-backed Watch and separate Download; failure/timeouts are isolated |
| TO-21 | Resolvers diagnostics UI + real Watch integration | DONE | diagnostics resolution is wired by the production shell to PlayerScreen Watch and the persistent Download queue; unsupported/empty states remain explicit |
| TO-22 | Tools/Providers registry/health/priority/preferences/diagnostics | DONE | production Tools consumes shared registry and exposes visible provider, bounded health probe, enablement/priority and persisted preferences; runtime smoke proves non-empty state |
| TO-23 | Sixth interface clean-room + Feature Gate + functional runtime proof | DONE | exact-SHA license gate is REFERENCE_ONLY; independent local diagnostics UI is disabled by default, activatable in Settings, renders/refreshes real local runtime diagnostics, and uploads no telemetry |
| TO-24 | Production persistent storage + migrations/versioning | DONE | production shell initializes schema-v2 SharedPreferences store; serialized writes, fail-closed corruption/future schema, v1->v2 migration and reconstructed user-visible Library state are covered |
| TO-25 | Player core HLS/MP4/DASH with platform-safe behavior | IN_PROGRESS | coordinator/adapters modeled; actual platform playback pending |
| TO-26 | Legal embed/WebView last-resort fallback + host/navigation policy | IN_PROGRESS | policy/model work exists; runtime adapter proof pending |
| TO-27 | Watch/Download separation end-to-end | DONE | Cinema and Sources runtime product-path tests prove Watch resolves/launches player without enqueueing Download, then explicit Download queues independently |
| TO-28 | Android Mobile UX/runtime integration | IN_PROGRESS | APK builds; DEVICE/runtime UX verification pending |
| TO-29 | Android TV 10-foot UX, D-pad/focus/LEANBACK/launcher | IN_PROGRESS | independent TV APK + LEANBACK build verification exists; D-pad/device UX proof pending |
| TO-30 | iOS scaffold/runtime build readiness | IN_PROGRESS | unsigned iOS build/package succeeds; runtime/device proof pending |
| TO-31 | Security hardening and credential-safe logging | DONE | sanitizedUriForLog strips userInfo/query/fragment; regression covers the required credential/token URI and UrlPolicy fails closed for user-info, non-allowlisted hosts and unsafe redirects |
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
