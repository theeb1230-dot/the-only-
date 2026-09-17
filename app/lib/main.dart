import 'package:flutter/material.dart';

void main() => runApp(const TheOnlyApp());

class TheOnlyApp extends StatelessWidget {
  const TheOnlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The Only',
      theme: ThemeData.dark(useMaterial3: true),
      home: const TheOnlyShell(),
    );
  }
}

enum AppSection { cinema, liveTv, sources, resolvers, tools, optional }

class TheOnlyShell extends StatefulWidget {
  const TheOnlyShell({super.key});

  @override
  State<TheOnlyShell> createState() => _TheOnlyShellState();
}

class _TheOnlyShellState extends State<TheOnlyShell> {
  AppSection selected = AppSection.cinema;

  static const labels = <AppSection, String>{
    AppSection.cinema: 'Cinema',
    AppSection.liveTv: 'Live TV',
    AppSection.sources: 'Sources',
    AppSection.resolvers: 'Resolvers',
    AppSection.tools: 'Tools',
    AppSection.optional: 'Optional',
  };

  @override
  Widget build(BuildContext context) {
    final visible = AppSection.values.where((s) => s != AppSection.optional).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('The Only')),
      body: Center(child: Text(labels[selected]!, key: const Key('section-title'))),
      bottomNavigationBar: NavigationBar(
        selectedIndex: visible.indexOf(selected),
        onDestinationSelected: (index) => setState(() => selected = visible[index]),
        destinations: [
          for (final section in visible)
            NavigationDestination(icon: const Icon(Icons.apps), label: labels[section]!),
        ],
      ),
    );
  }
}
