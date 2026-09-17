import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/quality.dart';

void main() {
  test('extracts and orders common quality labels', () {
    expect(qualityRank('1080p'), 1080);
    expect(qualityRank('HD 720'), 720);
    expect(orderByQuality(['480p', '1080p', '720p'], (v) => v), ['1080p', '720p', '480p']);
  });
}
