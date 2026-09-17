import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/domain/play_request.dart';

void main() {
  test('watch and download remain distinct explicit actions', () {
    const item = MediaItem(id: '1', title: 'One', kind: MediaKind.movie);
    const watch = MediaRequest(item: item, action: MediaAction.watch);
    const download = MediaRequest(item: item, action: MediaAction.download);
    expect(watch.action, isNot(download.action));
  });
}
