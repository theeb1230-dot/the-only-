import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../domain/models.dart';
import 'playback.dart';
import 'protocol_adapters.dart';
import 'retry.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.source, required this.title});

  final StreamSource source;
  final String title;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with WidgetsBindingObserver {
  static const _initializeTimeout = Duration(seconds: 20);
  static const _playTimeout = Duration(seconds: 5);

  VideoPlayerController? _controller;
  PlaybackCoordinator? _coordinator;
  Future<void>? _initialize;
  String? _error;
  bool _resumeAfterInterruption = false;
  bool _disposed = false;
  int _generation = 0;

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
    if (mounted) setState(() => _error = null);
    try {
      await _coordinator!.open(widget.source);
      if (mounted) setState(() {});
    } on TimeoutException {
      if (mounted) {
        setState(() => _error = 'Playback timed out. Check the connection or retry another source.');
      }
    } on UnsupportedError {
      if (mounted) {
        setState(() => _error = 'This source format is not supported by the native player.');
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Playback failed. Try another source.');
    }
  }

  Future<void> _openSource(StreamSource source) async {
    final generation = ++_generation;

    await runWithBoundedRetry<void>(
      attempts: 2,
      retryDelay: const Duration(milliseconds: 300),
      operation: (attempt) async {
        final controller = VideoPlayerController.networkUrl(source.uri);
        var controllerDisposed = false;
        try {
          await controller.initialize().timeout(_initializeTimeout);
          if (_disposed || generation != _generation) {
            await controller.dispose();
            controllerDisposed = true;
            throw StateError('Playback initialization superseded');
          }
          await controller.play().timeout(_playTimeout);
          if (_disposed || generation != _generation) {
            await controller.dispose();
            controllerDisposed = true;
            throw StateError('Playback start superseded');
          }
        } catch (_) {
          if (!controllerDisposed && !identical(_controller, controller)) {
            await controller.dispose();
          }
          rethrow;
        }

        final previous = _controller;
        _controller = controller;
        if (previous != null && !identical(previous, controller)) {
          await previous.dispose();
        }
      },
    );
  }

  Future<void> _stopPlayback() async {
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) await controller.pause();
  }

  Future<void> _retry() async {
    _generation++;
    final previous = _controller;
    _controller = null;
    await previous?.dispose();
    if (!mounted) return;
    setState(() {
      _error = null;
      _initialize = _initializePlayer();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      _resumeAfterInterruption = controller.value.isPlaying;
      unawaited(controller.pause());
    } else if (state == AppLifecycleState.resumed && _resumeAfterInterruption) {
      _resumeAfterInterruption = false;
      unawaited(controller.play());
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    WidgetsBinding.instance.removeObserver(this);
    final controller = _controller;
    _controller = null;
    if (controller != null) unawaited(controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) unawaited(_stopPlayback());
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: SafeArea(
          child: Center(
            child: _error != null
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            _error!,
                            key: const Key('player-error'),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          key: const Key('player-retry'),
                          onPressed: _retry,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : FutureBuilder<void>(
                    future: _initialize,
                    builder: (context, snapshot) {
                      final activeController = _controller;
                      if (snapshot.connectionState != ConnectionState.done ||
                          activeController == null ||
                          !activeController.value.isInitialized) {
                        return Semantics(
                          label: 'Loading player',
                          liveRegion: true,
                          child: const CircularProgressIndicator(key: Key('player-loading')),
                        );
                      }
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AspectRatio(
                            aspectRatio: activeController.value.aspectRatio == 0
                                ? 16 / 9
                                : activeController.value.aspectRatio,
                            child: VideoPlayer(activeController),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                key: const Key('player-play-pause'),
                                tooltip: activeController.value.isPlaying ? 'Pause' : 'Play',
                                onPressed: () async {
                                  if (activeController.value.isPlaying) {
                                    await activeController.pause();
                                  } else {
                                    await activeController.play();
                                  }
                                  if (mounted) setState(() {});
                                },
                                icon: Icon(
                                  activeController.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Semantics(
                                label: 'Playback protocol ${widget.source.protocol.name}',
                                child: Text(widget.source.protocol.name.toUpperCase()),
                              ),
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
