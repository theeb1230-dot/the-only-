import '../domain/live_channel.dart';
import '../domain/models.dart';
import '../domain/programme.dart';
import 'live_provider.dart';

/// Legal runtime smoke provider backed by Google's public sample media.
/// No scraping, credentials, DRM bypass, or restricted source is involved.
final class LegalLiveDemoProvider implements LiveTvProvider {
  @override
  String get id => 'legal-live-demo';

  static const _channel = LiveChannel(
    id: 'sample-live',
    name: 'The Only Sample Channel',
    group: 'Public samples',
    epgId: 'sample-live',
  );

  @override
  Future<List<LiveChannel>> channels() async => const [_channel];

  @override
  Future<List<Programme>> programmes(
    String channelId,
    DateTime from,
    DateTime to,
  ) async {
    if (channelId != _channel.id || !to.isAfter(from)) return const [];
    return [
      Programme(
        channelId: channelId,
        title: 'Public sample playback',
        startsAt: from,
        endsAt: to,
      ),
    ];
  }

  @override
  Future<List<StreamSource>> streams(LiveChannel channel) async {
    if (channel.id != _channel.id) return const [];
    return [
      StreamSource(
        uri: Uri.parse(
          'https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        ),
        protocol: StreamProtocol.mp4,
        providerId: id,
        quality: 'sample',
      ),
    ];
  }
}
