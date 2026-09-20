import 'package:flutter/material.dart';
import 'system_diagnostics_controller.dart';

class SystemDiagnosticsScreen extends StatefulWidget {
  const SystemDiagnosticsScreen({super.key, required this.controller});
  final SystemDiagnosticsController controller;
  @override State<SystemDiagnosticsScreen> createState() => _SystemDiagnosticsScreenState();
}

class _SystemDiagnosticsScreenState extends State<SystemDiagnosticsScreen> {
  SystemSnapshot? _snapshot; bool _busy = false; String? _error;
  @override void initState() { super.initState(); _refresh(); }
  Future<void> _refresh() async {
    setState(() { _busy = true; _error = null; });
    try { final value = await widget.controller.refresh(); if (mounted) setState(() => _snapshot = value); }
    catch (_) { if (mounted) setState(() => _error = 'تعذر قراءة تشخيص النظام المحلي'); }
    finally { if (mounted) setState(() => _busy = false); }
  }
  @override Widget build(BuildContext context) {
    final s = _snapshot;
    return ListView(key: const Key('system-diagnostics-screen'), padding: const EdgeInsets.all(16), children: [
      Row(children: [Expanded(child: Text('تشخيص النظام', style: Theme.of(context).textTheme.headlineSmall)), IconButton(key: const Key('system-diagnostics-refresh'), tooltip: 'تحديث التشخيص', onPressed: _busy ? null : _refresh, icon: const Icon(Icons.refresh))]),
      const Text('معلومات الجهاز المحلية فقط. لا يتم رفع أي بيانات تشخيصية.'),
      if (_busy) const LinearProgressIndicator(key: Key('system-diagnostics-loading')),
      if (_error != null) Semantics(liveRegion: true, child: Text(_error!, key: const Key('system-diagnostics-error'))),
      if (!_busy && _error == null && s == null) const Text('لا تتوفر بيانات تشخيص', key: Key('system-diagnostics-empty')),
      if (s != null) ...[
        _DiagnosticTile(label: 'المنصة', value: s.operatingSystem),
        _DiagnosticTile(label: 'إصدار النظام', value: s.operatingSystemVersion),
        _DiagnosticTile(label: 'المعالجات المنطقية', value: '${s.logicalProcessors}'),
        _DiagnosticTile(label: 'اللغة والمنطقة', value: s.localeName),
        _DiagnosticTile(label: 'مدة تشغيل التطبيق', value: '${s.appUptime.inSeconds}s'),
        _DiagnosticTile(label: 'وقت الالتقاط', value: s.capturedAt.toIso8601String()),
      ],
    ]);
  }
}
class _DiagnosticTile extends StatelessWidget {
  const _DiagnosticTile({required this.label, required this.value}); final String label; final String value;
  @override Widget build(BuildContext context) => ListTile(title: Text(label), subtitle: Text(value));
}
