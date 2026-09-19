import 'models.dart';

/// Offline file transfer currently supports direct MP4 assets only.
///
/// HLS/DASH are playable but are segmented manifests, not single downloadable
/// media files. They stay out of Download until an explicit offline packaging
/// implementation can preserve segments/manifests correctly.
bool isDownloadable(StreamSource source) => source.protocol == StreamProtocol.mp4;
