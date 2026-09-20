import 'package:flutter/material.dart';

import 'providers_controller.dart';

class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({super.key, required this.controller});

  final ProvidersController controller;

  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  final Set<String> _probing = <String>{};
  String? _error;

  List<ProviderToolState> get _states => widget.controller.states();

  Future<void> _probe(String id) async {
    setState(() { _probing.add(id); _error = null; });
    try {
      final before = widget.controller.states().firstWhere((state) => state.id == id).health;
      final health = await widget.controller.probe(id);
      if (health.failures > before.failures) {
        if (mounted) setState(() => _error = 'فشل فحص صحة المزود بأمان');
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Provider health probe failed safely');
    } finally {
      if (mounted) setState(() => _probing.remove(id));
    }
  }

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
        child: Text('لا توجد مزودات مسجلة.'),
      );
    }

    return Column(children: [
      if (_error != null) Semantics(liveRegion: true, child: Text(_error!, key: const Key('providers-error'))),
      Expanded(child: ListView.builder(
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
              'الأولوية ${state.priority} • الصحة ${state.health.score.toStringAsFixed(2)}',
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
                  key: Key('provider-probe-${state.id}'),
                  tooltip: 'فحص صحة المزود',
                  onPressed: _probing.contains(state.id) ? null : () => _probe(state.id),
                  icon: _probing.contains(state.id)
                      ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.monitor_heart_outlined),
                ),
                IconButton(
                  key: Key('provider-priority-down-${state.id}'),
                  tooltip: 'خفض الأولوية',
                  onPressed: () => _changePriority(state, -1),
                  icon: const Icon(Icons.arrow_downward),
                ),
                IconButton(
                  key: Key('provider-priority-up-${state.id}'),
                  tooltip: 'رفع الأولوية',
                  onPressed: () => _changePriority(state, 1),
                  icon: const Icon(Icons.arrow_upward),
                ),
              ],
            ),
          ),
        );
      },
    )),
    ]);
  }
}
