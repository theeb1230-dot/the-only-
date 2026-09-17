import 'models.dart';

bool isDownloadable(StreamSource source) =>
    source.protocol == StreamProtocol.mp4 ||
    source.protocol == StreamProtocol.hls ||
    source.protocol == StreamProtocol.dash;
