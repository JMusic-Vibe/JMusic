import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'package:jmusic/features/player/presentation/player_providers.dart';
import 'package:jmusic/features/player/presentation/player_screen.dart';
import 'package:jmusic/core/widgets/cover_art.dart';
import 'package:jmusic/l10n/app_localizations.dart';
import 'package:jmusic/features/music_lib/presentation/widgets/webdav_download_icon.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';
import 'dart:io';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaItem = ref.watch(currentMediaItemProvider).value;
    final isPlaying = ref.watch(isPlayingProvider).value ?? false;
    final controller = ref.read(playerControllerProvider);
    final currentSongAsync = ref.watch(currentSongProvider);
    final l10n = AppLocalizations.of(context)!;

    if (mediaItem == null) return const SizedBox.shrink();
    
    final currentSong = currentSongAsync.value;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => const PlayerScreen(),
        );
      },
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Cover Art
            AspectRatio(
              aspectRatio: 1,
              child: CoverArt(
                path: mediaItem.artUri?.toString(),
              ),
            ),
            const SizedBox(width: 12),
            // Title & Artist
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mediaItem.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.normal, color: Theme.of(context).colorScheme.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${mediaItem.artist ?? l10n.unknownArtist} •${mediaItem.album ?? l10n.unknownAlbum}",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // WebDAV Icon
            if (currentSong != null && (currentSong.sourceType == SourceType.webdav || currentSong.sourceType == SourceType.openalist))
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: WebDavDownloadIcon(song: currentSong, size: 20),
              ),
            // Controls
            if (!isSmallScreen)
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: () => controller.previous(),
              ),
            IconButton(
              icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
              iconSize: 32,
              onPressed: () => controller.togglePlay(),
            ),
            if (!isSmallScreen)
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: () => controller.next(),
              ),
            // Open queue directly
            IconButton(
              icon: const Icon(Icons.queue_music),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  useRootNavigator: true,
                  builder: (context) => const QueueSheet(),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

