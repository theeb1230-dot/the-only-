bool shouldResume(Duration position, Duration? duration) {
  if (position < const Duration(seconds: 10)) return false;
  if (duration == null || duration <= Duration.zero) return true;
  return position < duration * 0.95;
}
