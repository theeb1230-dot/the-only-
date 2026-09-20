import '../domain/live_channel.dart';
import '../domain/models.dart';
import '../domain/programme.dart';
import 'live_provider.dart';

/// Built-in public channel baseline. It guarantees that the Live interface has
/// playable entries while external/authorized playlist providers are being
/// configured or temporarily unavailable.
final class LegalLiveDemoProvider implements LiveTvProvider {
  @override
  String get id => 'legal-live-demo';

  static const _channels = <LiveChannel>[
    LiveChannel(
      id: 'public-bunny',
      name: 'Big Buck Bunny',
      group: 'قنوات عامة',
      epgId: 'public-bunny',
    ),
    LiveChannel(
      id: 'public-elephants',
      name: 'Elephants Dream',
      group: 'قنوات عامة',
      epgId: 'public-elephants',
    ),
    LiveChannel(
      id: 'public-joyrides',
      name: 'For Bigger Joyrides',
      group: 'قنوات عامة',
      epgId: 'public-joyrides',
    ),
  ];

  static final _streams = <String, Uri>{
    'public-bunny': Uri.parse(
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    ),
    'public-elephants': Uri.parse(
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    ),
    'public-joyrides': Uri.parse(
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
    ),
  };

  @override
  Future<List<LiveChannel>> channels() async => _channels;

  @override
  Future<List<Programme>> programmes(
    String channelId,
    DateTime from,
    DateTime to,
  ) async {
    final channel = _channels.where((item) => item.id == channelId).firstOrNull;
    if (channel == null || !to.isAfter(from)) return const [];
    final midpoint = from.add(Duration(milliseconds: to.difference(from).inMilliseconds ~/ 2));
    return [
      Programme(
        channelId: channelId,
        title: '${channel.name} • تشغيل عام',
        startsAt: from,
        endsAt: midpoint,
      ),
      Programme(
        channelId: channelId,
        title: 'استمرار البث التجريبي العام',
        startsAt: midpoint,
        endsAt: to,
      ),
    ];
  }

  @override
  Future<List<StreamSource>> streams(LiveChannel channel) async {
    final uri = _streams[channel.id];
    if (uri == null) return const [];
    return [
      StreamSource(
        uri: uri,
        protocol: StreamProtocol.mp4,
        providerId: id,
        quality: '1080p',
      ),
    ];
  }
}
