import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/services/audio_player_service.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';
import 'package:jmusic/features/player/presentation/video_player_screen.dart';

Future<void> openVideoPlayer(BuildContext context, WidgetRef ref, Song song) async {
  await ref.read(audioPlayerServiceProvider).pause();
  if (!context.mounted) return;
  await Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(builder: (_) => VideoPlayerScreen(song: song)),
  );
}
