import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/episode.dart';

void main() {
  test('episode key is stable across providers', () {
    const episode = EpisodeRef(seriesId: 'abc', season: 2, episode: 7);
    expect(episode.key, 'abc:s2:e7');
  });
}
