import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/device_class.dart';

void main() {
  test('TV profile requires directional focus', () {
    expect(const NavigationProfile(DeviceClass.tv).requiresDirectionalFocus, isTrue);
    expect(const NavigationProfile(DeviceClass.mobile).requiresDirectionalFocus, isFalse);
  });
}
