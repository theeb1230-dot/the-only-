import 'package:flutter/material.dart';

import 'system_diagnostics_controller.dart';

class SystemDiagnosticsScreen extends StatefulWidget {
  const SystemDiagnosticsScreen({super.key, required this.controller});

  final SystemDiagnosticsController controller;

  @override
  State<SystemDiagnosticsScreen> createState() => _SystemDiagnosticsScreenState();
}

class _SystemDiagnosticsScreenState extends State<SystemDiagnosticsScreen> {
  SystemSnapshot? _snapshot;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final snapshot = await widget.controller.refresh();
      if (!mounted) return;
      setState(() => _snapshot = snapshot);
    } catch (_) {
      if (mounted) setState(() => _error = 'Unable to read local system diagnostics');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    return ListView(
      key: const Key('system-diagnostics-screen'),
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'System Diagnostics',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            IconButton(
              key: const Key('system-diagnostics-refresh'),
              tooltip: 'Refresh diagnostics',
              onPressed: _busy ? null : _refresh,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const Text('Local device information only. No telemetry is uploaded.'),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null)
          Text(_error!, key: const Key('system-diagnostics-error')),
        if (snapshot != null) ...[
          _DiagnosticTile(label: 'Platform', value: snapshot.operatingSystem),
          _DiagnosticTile(
            label: 'OS version',
            value: snapshot.operatingSystemVersion,
          ),
          _DiagnosticTile(
            label: 'Logical processors',
            value: '${snapshot.logicalProcessors}',
          ),
          _DiagnosticTile(label: 'Locale', value: snapshot.localeName),
          _DiagnosticTile(
            label: 'App uptime',
            value: '${snapshot.appUptime.inSeconds}s',
          ),
          _DiagnosticTile(
            label: 'Captured',
            value: snapshot.capturedAt.toIso8601String(),
          ),
        ],
      ],
    );
  }
}

class _DiagnosticTile extends StatelessWidget {
  const _DiagnosticTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(label),
        subtitle: Text(value),
      );
}
