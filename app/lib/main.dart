import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/data/persistent_library.dart';
import 'core/domain/validation.dart';
import 'core/providers/legal_demo_provider.dart';
import 'core/providers/legal_live_demo_provider.dart';
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
import 'features/live_tv/live_tv_controller.dart';
import 'features/live_tv/live_tv_screen.dart';
import 'features/resolvers/resolvers_controller.dart';
import 'features/resolvers/resolvers_screen.dart';
import 'features/section_page.dart';
import 'features/sources/sources_controller.dart';
import 'features/sources/sources_screen.dart';
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
        home: TheOnlyShell(store: store),
      );
}

class TheOnlyShell extends StatefulWidget {
  const TheOnlyShell({super.key, required this.store});

  final PersistentLibraryStore store;

  @override
  State<TheOnlyShell> createState() => _TheOnlyShellState();
}

class _TheOnlyShellState extends State<TheOnlyShell> {
  final SectionSettings settings = SectionSettings();
  final ProviderRegistry providers = ProviderRegistry([LegalDemoProvider()]);
  final health = ProviderHealthStore();
  late final favorites = PersistentFavoritesRepository(widget.store);
  late final history = PersistentHistoryRepository(widget.store);
  late final downloads = PersistentDownloadsRepository(widget.store);
  late final ResolverRegistry resolvers =
      ResolverRegistry(const [DirectMediaResolver()]);
  late final ResolverCoordinator resolverCoordinator =
      ResolverCoordinator(resolvers, const StreamValidator(UrlPolicy()));
  late final CinemaController cinema = CinemaController(
    providers: providers.all.toList(growable: false),
    favorites: favorites,
    history: history,
    downloads: downloads,
    resolver: resolverCoordinator,
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
  late final ResolversController resolverController = ResolversController(
    resolvers,
    resolverCoordinator,
  );
  late final ProvidersController providerTools =
      ProvidersController(providers, health, const []);

  SectionId selected = SectionId.cinema;

  static const labels = <SectionId, String>{
    SectionId.cinema: 'Cinema',
    SectionId.liveTv: 'Live TV',
    SectionId.sources: 'Sources',
    SectionId.resolvers: 'Resolvers',
    SectionId.tools: 'Tools / Providers',
    SectionId.optional: 'Optional',
  };

  void openSettings() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => SectionSettingsScreen(
              settings: settings,
              onChanged: (id, enabled) {
                setState(() {
                  if (!enabled && selected == id) {
                    selected = SectionId.cinema;
                  }
                });
              },
            ),
          ),
        )
        .then((_) => setState(() {}));
  }

  Widget sectionBody() => switch (selected) {
        SectionId.cinema => CinemaScreen(controller: cinema),
        SectionId.liveTv => LiveTvScreen(controller: liveTv),
        SectionId.sources => SourcesScreen(controller: sources),
        SectionId.resolvers => ResolversScreen(controller: resolverController),
        SectionId.tools => ProvidersScreen(controller: providerTools),
        SectionId.optional => const SectionPage(
            title: 'Optional',
            description:
                'Locally gated sixth interface. Disabled by default.',
          ),
      };

  @override
  Widget build(BuildContext context) {
    final visible = settings.visibleSections;
    if (!visible.contains(selected)) selected = visible.first;
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Only'),
        actions: [
          IconButton(
            key: const Key('settings-button'),
            onPressed: openSettings,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: sectionBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: visible.indexOf(selected),
        onDestinationSelected: (index) => setState(() => selected = visible[index]),
        destinations: [
          for (final section in visible)
            NavigationDestination(
              icon: const Icon(Icons.apps),
              label: labels[section]!,
            ),
        ],
      ),
    );
  }
}
