# The Only — Master Delivery Plan

Status values: TODO, IN_PROGRESS, BLOCKED, DONE.

The project is one unified application, not a wrapper around multiple applications. Source archives under `archives/` are immutable evidence/reference inputs until a feature has been legally and technically migrated.

| ID | Task | Status | Depends on | Acceptance evidence |
|---|---|---|---|---|
| TO-01 | Inventory archived sources and exact SHAs | DONE | - | MANIFEST.tsv retained |
| TO-02 | Establish architecture contract | DONE | TO-01 | ARCHITECTURE.md |
| TO-03 | Establish license/reuse gate | DONE | TO-01 | LICENSE_REVIEW.md |
| TO-04 | Select unified application technology | DONE | TO-02 | Flutter decision recorded |
| TO-05 | Bootstrap The Only Flutter app | TODO | TO-04 | flutter analyze/test green |
| TO-06 | Core domain models | TODO | TO-05 | unit tests |
| TO-07 | Unified navigation shell | TODO | TO-05 | navigation tests |
| TO-08 | Unified settings registry | TODO | TO-06 | persistence tests |
| TO-09 | Section enable/disable controls | TODO | TO-08 | UI tests |
| TO-10 | Cinema section shell | TODO | TO-07 | widget tests |
| TO-11 | Live TV section shell | TODO | TO-07 | widget tests |
| TO-12 | Sources section shell | TODO | TO-07 | widget tests |
| TO-13 | Resolvers section shell | TODO | TO-07 | widget tests |
| TO-14 | Tools/Providers section shell | TODO | TO-07 | widget tests |
| TO-15 | Sixth section feature gate | TODO | TO-09 | hidden-by-default tests |
| TO-16 | Provider interface contract | TODO | TO-06 | contract tests |
| TO-17 | Resolver interface contract | TODO | TO-06 | contract tests |
| TO-18 | Unified stream model | TODO | TO-06 | serialization tests |
| TO-19 | Provider health scoring | TODO | TO-16 | deterministic tests |
| TO-20 | Provider fallback ordering | TODO | TO-19 | fallback tests |
| TO-21 | Unified player shell | TODO | TO-18 | player state tests |
| TO-22 | HLS playback adapter | TODO | TO-21 | fixture test |
| TO-23 | MP4 playback adapter | TODO | TO-21 | fixture test |
| TO-24 | DASH playback adapter | TODO | TO-21 | fixture test |
| TO-25 | Unified search | TODO | TO-16 | search tests |
| TO-26 | Favorites repository | TODO | TO-06 | persistence tests |
| TO-27 | History repository | TODO | TO-06 | persistence tests |
| TO-28 | Downloads repository/queue | TODO | TO-18 | queue tests |
| TO-29 | Local storage abstraction | TODO | TO-06 | storage tests |
| TO-30 | Cinema provider migration | TODO | TO-03,TO-16 | license-cleared integration tests |
| TO-31 | TMDB/source provider migration | TODO | TO-03,TO-16 | license-cleared contract tests |
| TO-32 | IPTV/M3U/XCAPI/EPG migration | TODO | TO-03,TO-16 | license-cleared fixtures |
| TO-33 | Resolver migration | TODO | TO-03,TO-17 | license-cleared resolver tests |
| TO-34 | Security and privacy hardening | TODO | TO-08 | security checklist/tests |
| TO-35 | Android mobile UX | TODO | TO-07 | Android build + UI tests |
| TO-36 | Android TV/D-pad UX | TODO | TO-07 | focus/navigation tests |
| TO-37 | CI quality gates | TODO | TO-05 | Actions green on exact SHA |
| TO-38 | Release build pipeline | TODO | TO-35,TO-36,TO-37 | reproducible artifacts |
| TO-39 | Product documentation and attribution | TODO | TO-03 | docs + notices |
| TO-40 | Release candidate validation | TODO | TO-10..TO-39 | release checklist + artifacts |

## Execution rules
- Never exceed these 40 main tasks; refine with subtasks inside an existing task.
- A task becomes DONE only with repository evidence and passing applicable tests.
- Do not copy source code until TO-03 marks that source as reusable under its license.
- Preserve archive bytes and hashes.
- Shared Navigation, Settings, Player, Search, History, Favorites and Downloads are mandatory product-level services.
- Provider and Resolver implementations sit behind contracts; UI sections never hard-code provider internals.
