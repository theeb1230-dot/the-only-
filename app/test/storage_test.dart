import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/data/storage.dart';

void main() {
  test('memory store follows read write delete contract', () async {
    final store = MemoryKeyValueStore();
    expect(await store.read('x'), isNull);
    await store.write('x', '1');
    expect(await store.read('x'), '1');
    await store.delete('x');
    expect(await store.read('x'), isNull);
  });
}
