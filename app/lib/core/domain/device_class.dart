enum DeviceClass { mobile, tv }

class NavigationProfile {
  const NavigationProfile(this.deviceClass);
  final DeviceClass deviceClass;
  bool get requiresDirectionalFocus => deviceClass == DeviceClass.tv;
}
