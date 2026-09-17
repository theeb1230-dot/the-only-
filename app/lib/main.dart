import 'package:flutter/material.dart';
import 'core/settings/section_settings.dart';
import 'core/settings/settings_screen.dart';
import 'features/section_page.dart';

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
  SectionId selected = SectionId.cinema;

  static const labels = <SectionId, String>{
    SectionId.cinema: 'Cinema', SectionId.liveTv: 'Live TV', SectionId.sources: 'Sources',
    SectionId.resolvers: 'Resolvers', SectionId.tools: 'Tools / Providers', SectionId.optional: 'Optional',
  };
  static const descriptions = <SectionId, String>{
    SectionId.cinema: 'Search, details, sources, favorites, history, Watch and Download.',
    SectionId.liveTv: 'Channels, groups, EPG, stream selection and playback.',
    SectionId.sources: 'Unified provider search and grouped validated sources.',
    SectionId.resolvers: 'Resolve supported inputs into validated playable streams.',
    SectionId.tools: 'Provider health, priority, enablement, diagnostics and fallback controls.',
    SectionId.optional: 'Locally gated sixth interface. Disabled by default.',
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

  @override
  Widget build(BuildContext context) {
    final visible = settings.visibleSections;
    if (!visible.contains(selected)) selected = visible.first;
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Only'),
        actions: [IconButton(key: const Key('settings-button'), onPressed: openSettings, icon: const Icon(Icons.settings))],
      ),
      body: SectionPage(title: labels[selected]!, description: descriptions[selected]!),
      bottomNavigationBar: NavigationBar(
        selectedIndex: visible.indexOf(selected),
        onDestinationSelected: (index) => setState(() => selected = visible[index]),
        destinations: [for (final section in visible) NavigationDestination(icon: const Icon(Icons.apps), label: labels[section]!)],
      ),
    );
  }
}
