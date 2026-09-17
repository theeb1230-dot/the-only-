enum PlayerPhase { idle, loading, playing, paused, ended, failed }

class PlayerState {
  const PlayerState({this.phase = PlayerPhase.idle, this.position = Duration.zero, this.duration});
  final PlayerPhase phase;
  final Duration position;
  final Duration? duration;
}
