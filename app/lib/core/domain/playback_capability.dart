import 'models.dart';

bool isDirectPlayback(StreamProtocol protocol) =>
    protocol == StreamProtocol.hls || protocol == StreamProtocol.mp4 || protocol == StreamProtocol.dash;
