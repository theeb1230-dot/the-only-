class LiveChannel {
  const LiveChannel({required this.id, required this.name, this.logo, this.group, this.epgId});
  final String id;
  final String name;
  final Uri? logo;
  final String? group;
  final String? epgId;
}
