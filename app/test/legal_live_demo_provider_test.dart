import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/providers/legal_live_demo_provider.dart';

void main() {
  test('public live baseline exposes multiple channels, EPG and safe streams', () async {
    final provider = LegalLiveDemoProvider();
    final channels = await provider.channels();
    expect(channels.length, greaterThanOrEqualTo(3));

    final from = DateTime.utc(2026, 9, 18, 12);
    final to = from.add(const Duration(hours: 1));
    final guide = await provider.programmes(channels.first.id, from, to);
    expect(guide, hasLength(2));
    expect(guide.every((item) => item.channelId == channels.first.id), isTrue);

    final streams = await provider.streams(channels.first);
    expect(streams, isNotEmpty);
    final uri = streams.single.uri;
    expect(uri.scheme, 'https');
    expect(uri.userInfo, isEmpty);
    expect(uri.query, isEmpty);
    expect(uri.fragment, isEmpty);
  });
}
