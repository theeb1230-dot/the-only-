# The Only — Master Delivery Plan

Status values: TODO, IN_PROGRESS, BLOCKED, DONE.

The project is one unified application, not a wrapper around multiple applications. Source archives under `archives/` are immutable evidence/reference inputs until a feature has been legally and technically migrated.

| ID | Task | Status | Depends on | Acceptance evidence |
|---|---|---|---|---|
| TO-01 | Inventory archived sources and exact SHAs | DONE | - | MANIFEST.tsv retained |
| TO-02 | Establish architecture contract | DONE | TO-01 | ARCHITECTURE.md |
| TO-03 | Establish license/reuse gate | DONE | TO-01 | LICENSE_REVIEW.md |
| TO-04 | Select unified application technology | DONE | TO-02 | Flutter decision recorded |
| TO-05 | Bootstrap The Only Flutter app | IN_PROGRESS | TO-04 | implementation committed; CI pending |
| TO-06 | Core domain models | IN_PROGRESS | TO-05 | implementation + unit test committed; CI pending |
| TO-07 | Unified navigation shell | IN_PROGRESS | TO-05 | shell + widget test committed; CI pending |
| TO-08 | Unified settings registry | IN_PROGRESS | TO-06 | persistence implementation/test committed; CI pending |
| TO-09 | Section enable/disable controls | IN_PROGRESS | TO-08 | model/test committed; settings UI pending |
| TO-10 | Cinema section shell | TODO | TO-07 | widget tests |
| TO-11 | Live TV section shell | TODO | TO-07 | widget tests |
| TO-12 | Sources section shell | TODO | TO-07 | widget tests |
| TO-13 | Resolvers section shell | TODO | TO-07 | widget tests |
| TO-14 | Tools/Providers section shell | TODO | TO-07 | widget tests |
| TO-15 | Sixth section feature gate | IN_PROGRESS | TO-09 | hidden-by-default model/widget tests committed; UI toggle pending |
| TO-16 | Provider interface contract | IN_PROGRESS | TO-06 | contract committed; CI pending |
| TO-17 | Resolver interface contract | IN_PROGRESS | TO-06 | contract committed; CI pending |
| TO-18 | Unified stream model | IN_PROGRESS | TO-06 | model/test committed; CI pending |
| TO-19 | Provider health scoring | IN_PROGRESS | TO-16 | implementation/test committed; CI pending |
| TO-20 | Provider fallback ordering | IN_PROGRESS | TO-19 | implementation/test committed; CI pending |
| TO-21 | Unified player shell | IN_PROGRESS | TO-18 | coordinator/test committed; CI pending |
| TO-22 | HLS playback adapter | TODO | TO-21 | fixture test |
| TO-23 | MP4 playback adapter | TODO | TO-21 | fixture test |
| TO-24 | DASH playback adapter | TODO | TO-21 | fixture test |
| TO-25 | Unified search | IN_PROGRESS | TO-16 | implementation/test committed; CI pending |
| TO-26 | Favorites repository | IN_PROGRESS | TO-06 | contract committed; implementation pending |
| TO-27 | History repository | IN_PROGRESS | TO-06 | contract committed; implementation pending |
| TO-28 | Downloads repository/queue | IN_PROGRESS | TO-18 | contract committed; implementation pending |
| TO-29 | Local storage abstraction | IN_PROGRESS | TO-06 | implementation/test committed; CI pending |
| TO-30 | Cinema provider migration | TODO | TO-03,TO-16 | license-cleared integration tests |
| TO-31 | TMDB/source provider migration | TODO | TO-03,TO-16 | license-cleared contract tests |
| TO-32 | IPTV/M3U/XCAPI/EPG migration | TODO | TO-03,TO-16 | license-cleared fixtures |
| TO-33 | Resolver migration | TODO | TO-03,TO-17 | license-cleared resolver tests |
| TO-34 | Security and privacy hardening | IN_PROGRESS | TO-08 | URL policy/test committed; broader hardening pending |
| TO-35 | Android mobile UX | TODO | TO-07 | Android build + UI tests |
| TO-36 | Android TV/D-pad UX | TODO | TO-07 | focus/navigation tests |
| TO-37 | CI quality gates | IN_PROGRESS | TO-05 | workflow committed; green run pending |
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
