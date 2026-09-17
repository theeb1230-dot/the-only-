import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/provider_capability.dart';

void main() {
  test('capabilities are explicit and queryable', () {
    const descriptor = ProviderDescriptor(id: 'p', name: 'Provider', capabilities: {ProviderCapability.search, ProviderCapability.movies});
    expect(descriptor.supports(ProviderCapability.search), isTrue);
    expect(descriptor.supports(ProviderCapability.liveTv), isFalse);
  });
}
