# Foundation Evidence

Base main SHA: `3b9c9589e4b1cfdbcf7943d3d17f777c976936ad`.

This branch adds the bounded 40-task plan, architecture and license gates, Flutter application shell, six-section catalog with optional section disabled by default, provider/resolver boundaries, normalized media/stream models, health/fallback runner, playback coordinator and protocol adapters, shared search, settings/storage, favorites/history/download contracts and initial memory implementations, URL security policy, tests, and Flutter CI.

No archived source code has been copied into runtime code in this foundation. Archives remain unchanged.

Acceptance remains fail-closed: implementation tasks marked IN_PROGRESS in the master plan cannot become DONE until the exact branch SHA passes `flutter analyze` and `flutter test` in GitHub Actions.
