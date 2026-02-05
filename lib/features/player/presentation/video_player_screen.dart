import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:jmusic/core/services/audio_player_service.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';
import 'package:jmusic/l10n/app_localizations.dart';

enum _VideoMenuAction {
  mute,
  loop,
  speed05,
  speed075,
  speed10,
  speed125,
  speed15,
  speed20,
}

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final Song song;

  const VideoPlayerScreen({super.key, required this.song});

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _showControls = true;
  String? _error;
  bool _isMuted = false;
  bool _isLooping = false;
  double _playbackSpeed = 1.0;
  BoxFit _fit = BoxFit.contain;
  Timer? _hideTimer;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await ref.read(audioPlayerServiceProvider).pause();

      final resolved = await ref.read(audioPlayerServiceProvider).resolvePlayableSong(widget.song);
      final hasAuth = resolved.remoteUrl != null && resolved.remoteUrl!.isNotEmpty;
      final headers = hasAuth ? {'Authorization': resolved.remoteUrl!} : const <String, String>{};

      if (resolved.path.startsWith('http://') || resolved.path.startsWith('https://')) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(resolved.path), httpHeaders: headers);
      } else {
        _controller = VideoPlayerController.file(File(resolved.path));
      }

      await _controller!.initialize();
      await _controller!.play();
      _kickAutoHide();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _exitFullscreen();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _enterFullscreen() async {
    _isFullscreen = true;
    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } catch (_) {}
  }

  Future<void> _exitFullscreen() async {
    if (!_isFullscreen) return;
    _isFullscreen = false;
    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      await _restoreAppOrientation();
    } catch (_) {}
  }

  Future<void> _restoreAppOrientation() async {
    if (!(Platform.isAndroid || Platform.isIOS)) return;
    final window = WidgetsBinding.instance.window;
    final size = window.physicalSize / window.devicePixelRatio;
    if (size.shortestSide < 600) {
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  Future<void> _toggleFullscreen() async {
    if (_isFullscreen) {
      await _exitFullscreen();
    } else {
      await _enterFullscreen();
    }
    if (mounted) setState(() {});
    _kickAutoHide();
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    _kickAutoHide();
  }

  void _togglePlay() {
    final controller = _controller;
    if (controller == null) return;
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
    setState(() {});
    _kickAutoHide();
  }

  void _kickAutoHide() {
    _hideTimer?.cancel();
    if (!_showControls) return;
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  void _seekBy(Duration offset) {
    final controller = _controller;
    if (controller == null) return;
    final target = controller.value.position + offset;
    final duration = controller.value.duration;
    final clamped = target < Duration.zero
        ? Duration.zero
        : (duration > Duration.zero && target > duration ? duration : target);
    controller.seekTo(clamped);
    _kickAutoHide();
  }

  void _toggleMute() {
    final controller = _controller;
    if (controller == null) return;
    _isMuted = !_isMuted;
    controller.setVolume(_isMuted ? 0.0 : 1.0);
    setState(() {});
    _kickAutoHide();
  }

  void _toggleLoop() {
    final controller = _controller;
    if (controller == null) return;
    _isLooping = !_isLooping;
    controller.setLooping(_isLooping);
    setState(() {});
    _kickAutoHide();
  }

  Future<void> _setSpeed(double speed) async {
    final controller = _controller;
    if (controller == null) return;
    await controller.setPlaybackSpeed(speed);
    setState(() => _playbackSpeed = speed);
    _kickAutoHide();
  }

  void _toggleFit() {
    setState(() {
      _fit = _fit == BoxFit.contain ? BoxFit.cover : BoxFit.contain;
    });
    _kickAutoHide();
  }

  String _formatDuration(Duration d) {
    String two(int v) => v.toString().padLeft(2, '0');
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return hours > 0 ? '${two(hours)}:${two(minutes)}:${two(seconds)}' : '${two(minutes)}:${two(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _isLoading
                ? const CircularProgressIndicator()
                : _error != null
                    ? Text(
                        l10n.playbackError(_error!),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      )
                    : _controller != null
                        ? AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio == 0 ? 16 / 9 : _controller!.value.aspectRatio,
                            child: FittedBox(
                              fit: _fit,
                              clipBehavior: Clip.hardEdge,
                              child: SizedBox(
                                width: _controller!.value.size.width,
                                height: _controller!.value.size.height,
                                child: VideoPlayer(_controller!),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
          ),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _toggleControls,
              onDoubleTapDown: (details) {
                final width = MediaQuery.of(context).size.width;
                final isLeft = details.globalPosition.dx < width / 2;
                _seekBy(isLeft ? const Duration(seconds: -10) : const Duration(seconds: 10));
              },
            ),
          ),
          if (_showControls) ...[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black54, Colors.transparent],
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () async {
                          await _exitFullscreen();
                          if (mounted) Navigator.of(context).pop();
                        },
                      ),
                      Expanded(
                        child: Text(
                          widget.song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: Icon(_isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen, color: Colors.white),
                        onPressed: _toggleFullscreen,
                      ),
                      IconButton(
                        icon: Icon(_fit == BoxFit.contain ? Icons.fit_screen : Icons.crop_free, color: Colors.white),
                        onPressed: _toggleFit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  child: _controller == null
                      ? const SizedBox.shrink()
                      : ValueListenableBuilder<VideoPlayerValue>(
                          valueListenable: _controller!,
                          builder: (context, value, _) {
                            final position = value.position;
                            final duration = value.duration;
                            final playing = value.isPlaying;
                            final isCompact = MediaQuery.of(context).size.width < 520;
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isCompact)
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: _togglePlay,
                                        icon: Icon(playing ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.white, size: 36),
                                      ),
                                      IconButton(
                                        onPressed: () => _seekBy(const Duration(seconds: -10)),
                                        icon: const Icon(Icons.replay_10, color: Colors.white),
                                      ),
                                      IconButton(
                                        onPressed: () => _seekBy(const Duration(seconds: 10)),
                                        icon: const Icon(Icons.forward_10, color: Colors.white),
                                      ),
                                      const Spacer(),
                                      PopupMenuButton<_VideoMenuAction>(
                                        icon: const Icon(Icons.more_vert, color: Colors.white),
                                        onSelected: (action) {
                                          switch (action) {
                                            case _VideoMenuAction.mute:
                                              _toggleMute();
                                              break;
                                            case _VideoMenuAction.loop:
                                              _toggleLoop();
                                              break;
                                            case _VideoMenuAction.speed05:
                                              _setSpeed(0.5);
                                              break;
                                            case _VideoMenuAction.speed075:
                                              _setSpeed(0.75);
                                              break;
                                            case _VideoMenuAction.speed10:
                                              _setSpeed(1.0);
                                              break;
                                            case _VideoMenuAction.speed125:
                                              _setSpeed(1.25);
                                              break;
                                            case _VideoMenuAction.speed15:
                                              _setSpeed(1.5);
                                              break;
                                            case _VideoMenuAction.speed20:
                                              _setSpeed(2.0);
                                              break;
                                          }
                                        },
                                        itemBuilder: (_) => [
                                          PopupMenuItem(
                                            value: _VideoMenuAction.mute,
                                            child: Text(_isMuted ? l10n.unmute : l10n.mute),
                                          ),
                                          PopupMenuItem(
                                            value: _VideoMenuAction.loop,
                                            child: Text(_isLooping ? l10n.loopingOn : l10n.loopingOff),
                                          ),
                                          const PopupMenuDivider(),
                                          const PopupMenuItem(value: _VideoMenuAction.speed05, child: Text('0.5x')),
                                          const PopupMenuItem(value: _VideoMenuAction.speed075, child: Text('0.75x')),
                                          const PopupMenuItem(value: _VideoMenuAction.speed10, child: Text('1.0x')),
                                          const PopupMenuItem(value: _VideoMenuAction.speed125, child: Text('1.25x')),
                                          const PopupMenuItem(value: _VideoMenuAction.speed15, child: Text('1.5x')),
                                          const PopupMenuItem(value: _VideoMenuAction.speed20, child: Text('2.0x')),
                                        ],
                                      ),
                                    ],
                                  )
                                else
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: _togglePlay,
                                        icon: Icon(playing ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.white, size: 36),
                                      ),
                                      IconButton(
                                        onPressed: () => _seekBy(const Duration(seconds: -10)),
                                        icon: const Icon(Icons.replay_10, color: Colors.white),
                                      ),
                                      IconButton(
                                        onPressed: () => _seekBy(const Duration(seconds: 10)),
                                        icon: const Icon(Icons.forward_10, color: Colors.white),
                                      ),
                                      IconButton(
                                        onPressed: _toggleMute,
                                        icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
                                      ),
                                      IconButton(
                                        onPressed: _toggleLoop,
                                        icon: Icon(_isLooping ? Icons.repeat_one : Icons.repeat, color: Colors.white),
                                      ),
                                      PopupMenuButton<double>(
                                        initialValue: _playbackSpeed,
                                        onSelected: _setSpeed,
                                        icon: const Icon(Icons.speed, color: Colors.white),
                                        itemBuilder: (_) => [
                                          0.5,
                                          0.75,
                                          1.0,
                                          1.25,
                                          1.5,
                                          2.0,
                                        ].map((s) => PopupMenuItem(value: s, child: Text('${s}x'))).toList(),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: VideoProgressIndicator(
                                        _controller!,
                                        allowScrubbing: true,
                                        colors: VideoProgressColors(
                                          playedColor: Theme.of(context).colorScheme.primary,
                                          bufferedColor: Colors.white30,
                                          backgroundColor: Colors.white12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_formatDuration(position)} / ${_formatDuration(duration)}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
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
          ],
        ],
      ),
    );
  }
}
