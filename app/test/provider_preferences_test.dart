import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/settings/provider_preferences.dart';

void main() {
  test('disabled providers are excluded and priority is descending', () {
    final ordered = orderPreferences(const [
      ProviderPreference(id: 'a', priority: 1),
      ProviderPreference(id: 'b', priority: 5),
      ProviderPreference(id: 'c', enabled: false, priority: 99),
    ]);
    expect(ordered.map((e) => e.id), ['b', 'a']);
  });
}
