class Programme {
  const Programme({required this.channelId, required this.title, required this.startsAt, required this.endsAt});
  final String channelId;
  final String title;
  final DateTime startsAt;
  final DateTime endsAt;

  bool isOnAirAt(DateTime instant) => !instant.isBefore(startsAt) && instant.isBefore(endsAt);
}
