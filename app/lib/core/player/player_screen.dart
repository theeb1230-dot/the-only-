import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../domain/models.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.source, required this.title});

  final StreamSource source;
  final String title;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _controller;
  Future<void>? _initialize;
  String? _error;

  @override
  void initState() {
    super.initState();
    final controller = VideoPlayerController.networkUrl(widget.source.uri);
    _controller = controller;
    _initialize = controller.initialize().then((_) async {
      await controller.play();
      if (mounted) setState(() {});
    }).catchError((Object error) {
      if (mounted) {
        setState(() => _error = 'Playback failed. Try another source.');
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Center(
          child: _error != null
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_error!, key: const Key('player-error'), textAlign: TextAlign.center),
                )
              : FutureBuilder<void>(
                  future: _initialize,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done || controller == null || !controller.value.isInitialized) {
                      return const CircularProgressIndicator(key: Key('player-loading'));
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AspectRatio(
                          aspectRatio: controller.value.aspectRatio == 0 ? 16 / 9 : controller.value.aspectRatio,
                          child: VideoPlayer(controller),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              key: const Key('player-play-pause'),
                              onPressed: () async {
                                if (controller.value.isPlaying) {
                                  await controller.pause();
                                } else {
                                  await controller.play();
                                }
                                if (mounted) setState(() {});
                              },
                              icon: Icon(controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
                            ),
                            const SizedBox(width: 12),
                            Text(widget.source.protocol.name.toUpperCase()),
                          ],
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }
}
