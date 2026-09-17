import 'package:flutter/material.dart';

import 'core/data/in_memory_downloads.dart';
import 'core/data/in_memory_library.dart';
import 'core/domain/validation.dart';
import 'core/providers/provider_health_store.dart';
import 'core/providers/provider_registry.dart';
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

void main() => runApp(const TheOnlyApp());

class TheOnlyApp extends StatelessWidget {
  const TheOnlyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'The Only',
        theme: ThemeData.dark(useMaterial3: true),
        home: const TheOnlyShell(),
      );
}

class TheOnlyShell extends StatefulWidget {
  const TheOnlyShell({super.key});
  @override
  State<TheOnlyShell> createState() => _TheOnlyShellState();
}

class _TheOnlyShellState extends State<TheOnlyShell> {
  final SectionSettings settings = SectionSettings();
  final ProviderRegistry providers = ProviderRegistry(const []);
  final favorites = MemoryFavoritesRepository();
  final history = MemoryHistoryRepository();
  final downloads = MemoryDownloadsRepository();
  final health = ProviderHealthStore();
  late final ResolverRegistry resolvers = ResolverRegistry(const []);
  late final CinemaController cinema = CinemaController(
    providers: providers.all.toList(growable: false),
    favorites: favorites,
    history: history,
    downloads: downloads,
  );
  late final LiveTvController liveTv = LiveTvController(const []);
  late final SourcesController sources = SourcesController(providers);
  late final ResolversController resolverController = ResolversController(
    resolvers,
    ResolverCoordinator(resolvers, const StreamValidator(UrlPolicy())),
  );
  late final ProvidersController providerTools = ProvidersController(providers, health, const []);

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
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => SectionSettingsScreen(
      settings: settings,
      onChanged: (id, enabled) {
        setState(() {
          if (!enabled && selected == id) selected = SectionId.cinema;
        });
      },
    ))).then((_) => setState(() {}));
  }

  Widget sectionBody() => switch (selected) {
    SectionId.cinema => CinemaScreen(controller: cinema),
    SectionId.liveTv => LiveTvScreen(controller: liveTv),
    SectionId.sources => SourcesScreen(controller: sources),
    SectionId.resolvers => ResolversScreen(controller: resolverController),
    SectionId.tools => ProvidersScreen(controller: providerTools),
    SectionId.optional => const SectionPage(
      title: 'Optional',
      description: 'Locally gated sixth interface. Disabled by default.',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final visible = settings.visibleSections;
    if (!visible.contains(selected)) selected = visible.first;
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Only'),
        actions: [IconButton(key: const Key('settings-button'), onPressed: openSettings, icon: const Icon(Icons.settings))],
      ),
      body: sectionBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: visible.indexOf(selected),
        onDestinationSelected: (index) => setState(() => selected = visible[index]),
        destinations: [for (final section in visible) NavigationDestination(icon: const Icon(Icons.apps), label: labels[section]!)],
      ),
    );
  }
}
