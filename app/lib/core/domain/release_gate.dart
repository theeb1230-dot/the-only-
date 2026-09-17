class ReleaseGate {
  const ReleaseGate({required this.testsGreen, required this.analysisGreen, required this.licensesCleared, required this.mobileBuild, required this.tvBuild});
  final bool testsGreen;
  final bool analysisGreen;
  final bool licensesCleared;
  final bool mobileBuild;
  final bool tvBuild;

  bool get ready => testsGreen && analysisGreen && licensesCleared && mobileBuild && tvBuild;
}
