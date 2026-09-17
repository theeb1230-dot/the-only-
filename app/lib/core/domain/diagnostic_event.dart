class DiagnosticEvent {
  const DiagnosticEvent({required this.category, required this.code, required this.timestamp});
  final String category;
  final String code;
  final DateTime timestamp;
}
