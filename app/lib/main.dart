import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/a11y/shell_labels.dart';
import 'core/data/download_transfer.dart';
import 'core/data/downloads.dart';
import 'core/data/persistent_library.dart';
import 'core/domain/download_policy.dart';
import 'core/domain/validation.dart';
import 'core/player/playback_screen.dart';
import 'core/providers/legal_demo_provider.dart';
import 'core/providers/legal_live_demo_provider.dart';
import 'core/providers/product_provider_selector.dart';
import 'core/providers/provider_health_store.dart';
import 'core/providers/provider_registry.dart';
import 'core/resolvers/direct_media_resolver.dart';
import 'core/resolvers/resolver_coordinator.dart';
import 'core/resolvers/resolver_registry.dart';
import 'core/security/url_policy.dart';
import 'core/settings/section_settings.dart';
import 'core/settings/settings_screen.dart';
import 'features/cinema/cinema_controller.dart';
import 'features/cinema/cinema_screen.dart';
import 'features/library/library_screen.dart';
import 'features/live_tv/live_tv_controller.dart';
import 'features/live_tv/live_tv_screen.dart';
import 'features/resolvers/resolvers_controller.dart';
import 'features/resolvers/resolvers_screen.dart';
import 'features/sources/sources_controller.dart';
import 'features/sources/sources_screen.dart';
import 'features/system_diagnostics/system_diagnostics_controller.dart';
import 'features/system_diagnostics/system_diagnostics_screen.dart';
import 'features/tools/providers_controller.dart';
import 'features/tools/providers_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final store = PersistentLibraryStore(preferences);
  await store.initialize();
  runApp(TheOnlyApp(store: store));
}

class TheOnlyApp extends StatelessWidget {
  const TheOnlyApp({super.key, required this.store});

  final PersistentLibraryStore store;

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'The Only',
        theme: ThemeData.dark(useMaterial3: true),
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Directionality(
          key: const Key('app-shell-rtl'),
          textDirection: TextDirection.rtl,
          child: TheOnlyShell(store: store),
        ),
      );
}

class TheOnlyShell extends StatefulWidget {
  const TheOnlyShell({super.key, required this.store});

  final PersistentLibraryStore store;

  @override
  State<TheOnlyShell> createState() => _TheOnlyShellState();
}

class _TheOnlyShellState extends State<TheOnlyShell> {
  late final SectionSettings settings =
      SectionSettings(preferences: widget.store.preferences);
  final ProviderRegistry providers = ProviderRegistry([LegalDemoProvider()]);
  final health = ProviderHealthStore();
  late final providerSelector = ProductProviderSelector(
    health: health,
    preferences: widget.store.preferences,
  );
  late final favorites = PersistentFavoritesRepository(widget.store);
  late final history = PersistentHistoryRepository(widget.store);
  late final downloads = PersistentDownloadsRepository(widget.store);
  late final downloadTransfer = DownloadTransferService(repository: downloads);
  late final ResolverRegistry resolvers =
      ResolverRegistry(const [DirectMediaResolver()]);
  late final ResolverCoordinator resolverCoordinator = ResolverCoordinator(
    resolvers,
    const StreamValidator(UrlPolicy()),
  );
  late final CinemaController cinema = CinemaController(
    providers: providers.all.toList(growable: false),
    favorites: favorites,
    history: history,
    downloads: downloads,
    resolver: resolverCoordinator,
    providerSelector: providerSelector,
  );
  late final LiveTvController liveTv = LiveTvController(
    [LegalLiveDemoProvider()],
    resolver: resolverCoordinator,
  );
  late final SourcesController sources = SourcesController(
    providers,
    resolver: resolverCoordinator,
    downloads: downloads,
  );
  late final ResolversController resolverController =
      ResolversController(resolvers, resolverCoordinator);
  late final ProvidersController providerTools = ProvidersController(
    providers,
    health,
    const [],
    preferencesStore: widget.store.preferences,
  );
  late final SystemDiagnosticsController diagnostics =
      SystemDiagnosticsController(RuntimeSystemSnapshotProvider());

  SectionId selected = SectionId.cinema;

  @override
  void initState() {
    super.initState();
    downloadTransfer.recoverInterrupted();
  }

  void openSettings() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => SectionSettingsScreen(
              settings: settings,
              onChanged: (id, enabled) {
                setState(() {
                  if (!enabled && selected == id) selected = SectionId.cinema;
                });
              },
            ),
          ),
        )
        .then((_) {
      if (mounted) setState(() {});
    });
  }

  void openLibrary() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => Scaffold(
          appBar: AppBar(title: Text(ShellLabels.library(routeContext))),
          body: LibraryScreen(
            favorites: favorites,
            history: history,
            downloads: downloads,
            transfer: downloadTransfer,
          ),
        ),
      ),
    );
  }

  Widget sectionBody() => switch (selected) {
        SectionId.cinema => CinemaScreen(controller: cinema),
        SectionId.liveTv => LiveTvScreen(controller: liveTv),
        SectionId.sources => SourcesScreen(controller: sources),
        SectionId.resolvers => ResolversScreen(
            controller: resolverController,
            onWatch: (source) => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PlaybackScreen(
                  source: source,
                  title: ShellLabels.resolvedStream(context),
                ),
              ),
            ),
            onDownload: (source) async {
              if (!isDownloadable(source)) {
                throw StateError('Selected source is not directly downloadable');
              }
              await downloads.enqueue(
                DownloadJob(
                  id: 'resolver:${source.uri}',
                  source: source,
                  state: DownloadState.queued,
                ),
              );
            },
          ),
        SectionId.tools => ProvidersScreen(controller: providerTools),
        SectionId.optional => SystemDiagnosticsScreen(controller: diagnostics),
      };

  @override
  Widget build(BuildContext context) {
    final visible = settings.visibleSections;
    if (!visible.contains(selected)) selected = visible.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('The Only'),
        actions: [
          Semantics(
            button: true,
            label: ShellLabels.library(context),
            child: IconButton(
              key: const Key('library-button'),
              tooltip: ShellLabels.library(context),
              onPressed: openLibrary,
              icon: const Icon(Icons.video_library),
            ),
          ),
          Semantics(
            button: true,
            label: ShellLabels.settings(context),
            child: IconButton(
              key: const Key('settings-button'),
              tooltip: ShellLabels.settings(context),
              onPressed: openSettings,
              icon: const Icon(Icons.settings),
            ),
          ),
        ],
      ),
      body: sectionBody(),
      bottomNavigationBar: Material(
        elevation: 3,
        child: SafeArea(
          top: false,
          child: Semantics(
            container: true,
            label: ShellLabels.appNavigation(context),
            child: FocusTraversalGroup(
              policy: ReadingOrderTraversalPolicy(),
              child: Row(
                children: [
                  for (var i = 0; i < visible.length; i++)
                    Expanded(
                      child: FocusTraversalOrder(
                        order: NumericFocusOrder(i.toDouble()),
                        child: Semantics(
                          button: true,
                          selected: visible[i] == selected,
                          label: ShellLabels.section(context, visible[i]),
                          onTap: () => setState(() => selected = visible[i]),
                          child: InkWell(
                            key: Key('nav-${visible[i].name}'),
                            canRequestFocus: true,
                            onTap: () => setState(() => selected = visible[i]),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    switch (visible[i]) {
                                      SectionId.cinema => Icons.movie_outlined,
                                      SectionId.liveTv => Icons.live_tv_outlined,
                                      SectionId.sources => Icons.source_outlined,
                                      SectionId.resolvers => Icons.link_outlined,
                                      SectionId.tools => Icons.tune_outlined,
                                      SectionId.optional =>
                                        Icons.monitor_heart_outlined,
                                    },
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    ShellLabels.section(context, visible[i]),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: visible[i] == selected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
