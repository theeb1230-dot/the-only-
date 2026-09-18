import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/live_channel.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/domain/programme.dart';
import 'package:the_only/core/domain/validation.dart';
import 'package:the_only/core/providers/live_provider.dart';
import 'package:the_only/core/resolvers/direct_media_resolver.dart';
import 'package:the_only/core/resolvers/resolver_coordinator.dart';
import 'package:the_only/core/resolvers/resolver_registry.dart';
import 'package:the_only/core/security/url_policy.dart';
import 'package:the_only/features/live_tv/live_tv_controller.dart';

class FixtureLiveProvider implements LiveTvProvider {
  FixtureLiveProvider(this.id, {this.fail = false});

  @override
  final String id;
  final bool fail;

  @override
  Future<List<LiveChannel>> channels() async {
    if (fail) throw StateError('fixture failure');
    return const [LiveChannel(id: 'news', name: 'News', group: 'News')];
  }

  @override
  Future<List<Programme>> programmes(
    String channelId,
    DateTime from,
    DateTime to,
  ) async {
    if (fail) throw StateError('fixture failure');
    return [
      Programme(
        channelId: channelId,
        title: 'Bulletin',
        startsAt: from,
        endsAt: to,
      ),
    ];
  }

  @override
  Future<List<StreamSource>> streams(LiveChannel channel) async {
    if (fail) throw StateError('fixture failure');
    return [
      StreamSource(
        uri: Uri.parse('https://example.com/live.m3u8'),
        protocol: StreamProtocol.hls,
        providerId: id,
      ),
    ];
  }
}

void main() {
  test('Live TV survives provider failure and exposes channel EPG and HLS', () async {
    final resolver = ResolverCoordinator(
      ResolverRegistry(const [DirectMediaResolver()]),
      const StreamValidator(UrlPolicy()),
    );
    final controller = LiveTvController(
      [FixtureLiveProvider('bad', fail: true), FixtureLiveProvider('good')],
      resolver: resolver,
    );
    final channels = await controller.channels();
    expect(channels.single.name, 'News');
    final from = DateTime.utc(2026, 1, 1, 12);
    final guide = await controller.guide(
      'news',
      from,
      from.add(const Duration(hours: 1)),
    );
    expect(guide.single.title, 'Bulletin');
    final streams = await controller.streams(channels.single);
    expect(streams.single.protocol, StreamProtocol.hls);
    final resolved = await controller.resolveForWatch(
      channels.single,
      streams.single,
    );
    expect(resolved?.protocol, StreamProtocol.hls);
  });
}
