# The Only — Master Delivery Plan

Status values: TODO, IN_PROGRESS, BLOCKED, DONE.

The project is one unified application, not a wrapper around multiple applications. Source archives under `archives/` remain immutable evidence/reference inputs.

| ID | Task | Status | Depends on | Acceptance evidence |
|---|---|---|---|---|
| TO-01 | Inventory archived sources and exact SHAs | DONE | - | MANIFEST.tsv retained |
| TO-02 | Establish architecture contract | DONE | TO-01 | ARCHITECTURE.md |
| TO-03 | Establish license/reuse gate | DONE | TO-01 | exact-SHA LICENSE_REVIEW.md + THIRD_PARTY_NOTICES.md ledger |
| TO-04 | Select unified application technology | DONE | TO-02 | Flutter decision recorded |
| TO-05 | Bootstrap The Only Flutter app | DONE | TO-04 | Flutter scaffold passed CI analyze/test |
| TO-06 | Core domain models | DONE | TO-05 | committed models/tests passed CI |
| TO-07 | Unified navigation shell | DONE | TO-05 | six-section shell/widget tests passed CI |
| TO-08 | Unified settings registry | IN_PROGRESS | TO-06 | shared registry wired into app shell in PR #8; durable persistence pending |
| TO-09 | Section enable/disable controls | IN_PROGRESS | TO-08 | Settings screen wired to shared shell in PR #8; CI pending |
| TO-10 | Cinema section | IN_PROGRESS | TO-07 | functional controller + fixture flow merged; product UI/details/player wiring pending |
| TO-11 | Live TV section | IN_PROGRESS | TO-07 | channels/EPG/streams/fallback controller + fixture test merged |
| TO-12 | Sources section | IN_PROGRESS | TO-07 | provider discovery/search/grouped-source implementation merged; product UI pending |
| TO-13 | Resolvers section | IN_PROGRESS | TO-07 | clean-room functional resolver controller + deterministic fixture tests merged; product UI pending |
| TO-14 | Tools/Providers section | IN_PROGRESS | TO-07 | shared registry/health/preferences controller + deterministic tests merged; product UI pending |
| TO-15 | Sixth section feature gate | IN_PROGRESS | TO-09 | hidden by default; Settings enable/navigation widget flow in PR #8; CI pending |
| TO-16 | Provider interface contract | DONE | TO-06 | contract/registry exercised by green CI |
| TO-17 | Resolver interface contract | IN_PROGRESS | TO-06 | contract + functional controller merged; UI integration pending |
| TO-18 | Unified stream model | DONE | TO-06 | model exercised by Cinema/Live TV green CI |
| TO-19 | Provider health scoring | IN_PROGRESS | TO-16 | health store integrated with Tools controller; UI/real probes pending |
| TO-20 | Provider fallback ordering | IN_PROGRESS | TO-19 | implementation/tests present; end-to-end ranking pending |
| TO-21 | Unified player shell | IN_PROGRESS | TO-18 | coordinator/tests present; platform playback pending |
| TO-22 | HLS playback adapter | TODO | TO-21 | platform adapter + fixture test |
| TO-23 | MP4 playback adapter | TODO | TO-21 | platform adapter + fixture test |
| TO-24 | DASH playback adapter | TODO | TO-21 | platform adapter + fixture test |
| TO-25 | Unified search | IN_PROGRESS | TO-16 | shared coordinator green; section/UI integration pending |
| TO-26 | Favorites repository | IN_PROGRESS | TO-06 | memory implementation green; persistent implementation pending |
| TO-27 | History repository | IN_PROGRESS | TO-06 | memory implementation green; persistent implementation pending |
| TO-28 | Downloads repository/queue | IN_PROGRESS | TO-18 | memory queue green; platform download execution pending |
| TO-29 | Local storage abstraction | IN_PROGRESS | TO-06 | abstraction/tests present; durable backend pending |
| TO-30 | Cinema provider migration | IN_PROGRESS | TO-03,TO-16 | no-license source => clean-room functional path merged; deeper UI/provider behavior pending |
| TO-31 | TMDB/source provider migration | IN_PROGRESS | TO-03,TO-16 | MIT-cleared source; The Only-owned Sources implementation merged |
| TO-32 | IPTV/M3U/XCAPI/EPG migration | IN_PROGRESS | TO-03,TO-16 | no-license => clean-room channels/EPG/stream flow merged |
| TO-33 | Resolver migration | IN_PROGRESS | TO-03,TO-17 | reference-only inputs; clean-room resolver controller/tests merged; UI pending |
| TO-34 | Security and privacy hardening | IN_PROGRESS | TO-08 | URL/log/network policies present; broader hardening pending |
| TO-35 | Android mobile UX | TODO | TO-07 | Android build + UI tests |
| TO-36 | Android TV/D-pad UX | TODO | TO-07 | focus/navigation tests |
| TO-37 | CI quality gates | DONE | TO-05 | exact-head PR CI runs pub get/analyze/test successfully |
| TO-38 | Release build pipeline | TODO | TO-35,TO-36,TO-37 | reproducible Mobile/TV artifacts |
| TO-39 | Product documentation and attribution | IN_PROGRESS | TO-03 | license ledger/notices started; product docs pending |
| TO-40 | Release candidate validation | TODO | TO-10..TO-39 | release checklist + artifacts |

## Execution rules
- Never exceed these 40 main tasks; refine with subtasks inside an existing task.
- A task becomes DONE only with repository evidence and passing applicable tests.
- Do not copy source code until TO-03 records an explicit reusable decision and obligations.
- Preserve archive bytes and hashes.
- Shared Navigation, Settings, Player, Search, History, Favorites and Downloads are mandatory product-level services.
- Provider and Resolver implementations sit behind contracts; UI sections never hard-code provider internals.
- Deterministic CI uses legal fixtures/local mocks; live verification is a separate gate.
