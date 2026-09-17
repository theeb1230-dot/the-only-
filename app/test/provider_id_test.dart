import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/provider_id.dart';

void main() {
  test('accepts stable ids and rejects unsafe labels', () {
    expect(isValidProviderId('tmdb_embed'), isTrue);
    expect(isValidProviderId('Bad Provider'), isFalse);
    expect(isValidProviderId('../x'), isFalse);
  });
}
