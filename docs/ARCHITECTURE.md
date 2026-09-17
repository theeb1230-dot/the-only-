# The Only Architecture Contract

## Product invariant
The Only is one application with one lifecycle and one navigation system. Imported projects are reference implementations and provider inputs, never nested applications or WebView wrappers masquerading as integration.

## Technology decision
The product shell will be Flutter/Dart. Initial release targets Android mobile and Android TV while keeping core/domain packages platform-neutral so iOS can be enabled without redesigning the architecture.

## Layers
1. `app`: composition root, routes, theme, localization and section registry.
2. `features`: Cinema, Live TV, Sources, Resolvers, Tools/Providers and the sixth feature-gated section.
3. `core/domain`: MediaItem, StreamSource, ProviderResult, ResolverResult, playback and download state.
4. `core/providers`: provider contracts, registry, health scoring, fallback and timeouts.
5. `core/resolvers`: resolver contracts and normalized stream output.
6. `core/player`: one playback coordinator for HLS, MP4 and DASH adapters.
7. `core/data`: settings, favorites, history, downloads and local persistence.

## Dependency rules
- Features depend on core contracts, never on another archived application's UI.
- Provider implementations cannot navigate or render UI.
- Resolver implementations cannot mutate favorites/history.
- Player consumes normalized `StreamSource`; it does not scrape providers.
- Search aggregates provider results through one coordinator.
- Settings owns section visibility and provider priority.

## Section model
All six sections are registered through one `SectionRegistry`. A section may be disabled without changing application binaries. Sensitive/optional sections are hidden by default and require explicit local enablement.

## Migration rule
Before source code from an archive is migrated, its license must be classified in `LICENSE_REVIEW.md`. Unknown/no-license sources are reference-only: behavior may be independently reimplemented from public interfaces, but their code is not copied.

## Definition of integration
A migrated capability is integrated only when it uses The Only domain contracts, shares global services where applicable, has automated tests, and passes CI on the exact commit SHA.
