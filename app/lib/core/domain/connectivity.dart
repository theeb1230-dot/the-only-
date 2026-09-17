enum ConnectivityState { offline, online }

class ConnectivityPolicy {
  const ConnectivityPolicy(this.state);
  final ConnectivityState state;
  bool get canQueryRemoteProviders => state == ConnectivityState.online;
}
