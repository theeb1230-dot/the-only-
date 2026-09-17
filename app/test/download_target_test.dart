import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/download_target.dart';

void main() {
  test('removes path separators from download names', () {
    expect(safeDownloadName('../Movie/Name'), '..MovieName');
    expect(safeDownloadName('***'), 'download');
  });
}
