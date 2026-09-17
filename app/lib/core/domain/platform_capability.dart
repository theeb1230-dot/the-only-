enum PlatformCapability { downloads, directionalFocus, backgroundPlayback, pictureInPicture }

class PlatformCapabilities {
  const PlatformCapabilities(this.values);
  final Set<PlatformCapability> values;
  bool supports(PlatformCapability capability) => values.contains(capability);
}
