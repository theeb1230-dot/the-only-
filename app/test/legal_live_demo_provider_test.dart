import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/providers/legal_live_demo_provider.dart';

void main() {
  test('legal live provider exposes channel, EPG and safe stream', () async {
    final provider = LegalLiveDemoProvider();
    final channels = await provider.channels();
    expect(channels, hasLength(1));

    final from = DateTime.utc(2026, 9, 18, 12);
    final to = from.add(const Duration(hours: 1));
    final guide = await provider.programmes(channels.single.id, from, to);
    expect(guide, isNotEmpty);
    expect(guide.single.channelId, channels.single.id);

    final streams = await provider.streams(channels.single);
    expect(streams, isNotEmpty);
    final uri = streams.single.uri;
    expect(uri.scheme, 'https');
    expect(uri.userInfo, isEmpty);
    expect(uri.query, isEmpty);
    expect(uri.fragment, isEmpty);
  });
}
