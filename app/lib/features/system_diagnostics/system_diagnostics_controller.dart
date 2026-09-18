import 'dart:io';

class SystemSnapshot {
  const SystemSnapshot({required this.operatingSystem, required this.operatingSystemVersion, required this.logicalProcessors, required this.localeName, required this.appUptime, required this.capturedAt});
  final String operatingSystem;
  final String operatingSystemVersion;
  final int logicalProcessors;
  final String localeName;
  final Duration appUptime;
  final DateTime capturedAt;
}

abstract interface class SystemSnapshotProvider { Future<SystemSnapshot> capture(); }

final class RuntimeSystemSnapshotProvider implements SystemSnapshotProvider {
  RuntimeSystemSnapshotProvider() : _started = Stopwatch()..start();
  final Stopwatch _started;
  @override
  Future<SystemSnapshot> capture() async => SystemSnapshot(
    operatingSystem: Platform.operatingSystem,
    operatingSystemVersion: Platform.operatingSystemVersion,
    logicalProcessors: Platform.numberOfProcessors,
    localeName: Platform.localeName,
    appUptime: _started.elapsed,
    capturedAt: DateTime.now().toUtc(),
  );
}

class SystemDiagnosticsController {
  SystemDiagnosticsController(this.provider);
  final SystemSnapshotProvider provider;
  Future<SystemSnapshot> refresh() => provider.capture();
}
