import 'package:flutter/material.dart';

import 'providers_controller.dart';

class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({super.key, required this.controller});

  final ProvidersController controller;

  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  List<ProviderToolState> get _states => widget.controller.states();

  void _setEnabled(String id, bool value) {
    setState(() => widget.controller.setEnabled(id, value));
  }

  void _changePriority(ProviderToolState state, int delta) {
    setState(() => widget.controller.setPriority(state.id, state.priority + delta));
  }

  @override
  Widget build(BuildContext context) {
    final states = _states;
    if (states.isEmpty) {
      return const Center(
        key: Key('providers-empty'),
        child: Text('No providers registered.'),
      );
    }

    return ListView.builder(
      key: const Key('providers-list'),
      padding: const EdgeInsets.all(16),
      itemCount: states.length,
      itemBuilder: (context, index) {
        final state = states[index];
        return Card(
          key: Key('provider-${state.id}'),
          child: ListTile(
            title: Text(state.id),
            subtitle: Text(
              'Priority ${state.priority} • Health ${state.health.score.toStringAsFixed(2)}',
            ),
            leading: Switch(
              key: Key('provider-enabled-${state.id}'),
              value: state.enabled,
              onChanged: (value) => _setEnabled(state.id, value),
            ),
            trailing: Wrap(
              spacing: 4,
              children: [
                IconButton(
                  key: Key('provider-priority-down-${state.id}'),
                  tooltip: 'Lower priority',
                  onPressed: () => _changePriority(state, -1),
                  icon: const Icon(Icons.arrow_downward),
                ),
                IconButton(
                  key: Key('provider-priority-up-${state.id}'),
                  tooltip: 'Raise priority',
                  onPressed: () => _changePriority(state, 1),
                  icon: const Icon(Icons.arrow_upward),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
