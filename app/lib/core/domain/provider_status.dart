enum ProviderState { unknown, healthy, degraded, offline }

class ProviderStatus {
  const ProviderStatus({required this.id, required this.state, required this.checkedAt, this.message});
  final String id;
  final ProviderState state;
  final DateTime checkedAt;
  final String? message;
}
