import 'package:flutter/material.dart';

import '../domain/models.dart';
import 'embed_screen.dart';
import 'player_screen.dart';

enum PlaybackSurface { native, legalEmbed }

PlaybackSurface playbackSurfaceFor(StreamSource source) =>
    source.protocol == StreamProtocol.embed
        ? PlaybackSurface.legalEmbed
        : PlaybackSurface.native;

/// Single product playback entry point. Direct HLS/MP4/DASH stay native;
/// embed sources can only enter the in-app WebView when their host is present
/// in an explicit product allowlist. An empty allowlist therefore fails closed.
class PlaybackScreen extends StatelessWidget {
  const PlaybackScreen({super.key,required this.source,required this.title,this.allowedEmbedHosts=const<String>{}});
  final StreamSource source;
  final String title;
  final Set<String> allowedEmbedHosts;

  @override Widget build(BuildContext context)=>switch(playbackSurfaceFor(source)){
    PlaybackSurface.legalEmbed=>EmbedScreen(initialUri:source.uri,title:title,allowedHosts:allowedEmbedHosts),
    PlaybackSurface.native=>PlayerScreen(source:source,title:title),
  };
}
