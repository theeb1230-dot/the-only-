import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../domain/models.dart';
import 'playback.dart';
import 'protocol_adapters.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.source, required this.title});

  final StreamSource source;
  final String title;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  PlaybackCoordinator? _coordinator;
  Future<void>? _initialize;
  String? _error;
  bool _resumeAfterInterruption = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _coordinator = PlaybackCoordinator(
      standardPlaybackAdapters(opener: _openSource, stopper: _stopPlayback),
    );
    _initialize = _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      await _coordinator!.open(widget.source);
      if (mounted) setState(() {});
    } on UnsupportedError {
      if (mounted) setState(() => _error = 'This source format is not supported by the native player.');
    } catch (_) {
      if (mounted) setState(() => _error = 'Playback failed. Try another source.');
    }
  }

  Future<void> _openSource(StreamSource source) async {
    final previous = _controller;
    final controller = VideoPlayerController.networkUrl(source.uri);
    _controller = controller;
    try {
      await controller.initialize();
      await controller.play();
    } catch (_) {
      if (identical(_controller, controller)) _controller = previous;
      await controller.dispose();
      rethrow;
    }
    if (previous != null && !identical(previous, controller)) await previous.dispose();
  }

  Future<void> _stopPlayback() async {
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) await controller.pause();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _resumeAfterInterruption = controller.value.isPlaying;
      controller.pause();
    } else if (state == AppLifecycleState.resumed && _resumeAfterInterruption) {
      _resumeAfterInterruption = false;
      controller.play();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _stopPlayback();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: SafeArea(
          child: Center(
            child: _error != null
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Semantics(liveRegion: true, child: Text(_error!, key: const Key('player-error'), textAlign: TextAlign.center)),
                  )
                : FutureBuilder<void>(
                    future: _initialize,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done || controller == null || !controller.value.isInitialized) {
                        return Semantics(label: 'Loading player', liveRegion: true, child: const CircularProgressIndicator(key: Key('player-loading')));
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
                                tooltip: controller.value.isPlaying ? 'Pause' : 'Play',
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
                              Semantics(label: 'Playback protocol ${widget.source.protocol.name}', child: Text(widget.source.protocol.name.toUpperCase())),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
