import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/services/audio_player_service.dart';
import 'package:jmusic/core/widgets/cover_art.dart';
import 'package:jmusic/core/widgets/capsule_toast.dart';
import 'package:jmusic/features/music_lib/domain/entities/playlist.dart';
import 'package:jmusic/features/playlists/data/playlist_repository.dart';
import 'package:jmusic/features/playlists/presentation/playlist_detail_screen.dart';
import 'package:jmusic/features/player/presentation/player_providers.dart';
import 'package:jmusic/l10n/app_localizations.dart';

final playlistsProvider = StreamProvider<List<Playlist>>((ref) {
  final repo = ref.watch(playlistRepositoryProvider);
  return repo.watchPlaylists();
});

class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.playlistTitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
        actions: [
          IconButton(
            tooltip: l10n.createPlaylist,
            onPressed: () => _showCreatePlaylistDialog(context, ref),
            icon: const Icon(Icons.playlist_add),
          ),
        ],
      ),
      body: playlistsAsync.when(
        data: (playlists) {
            if (playlists.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Icon(Icons.queue_music, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                   const SizedBox(height: 16),
                   Text(l10n.noPlaylists, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                  TextButton(
                    onPressed: () => _showCreatePlaylistDialog(context, ref),
                    child: Text(l10n.createPlaylist, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
                  ),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return _PlaylistCard(playlist: playlist);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _showCreatePlaylistDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.createPlaylist, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              // labelText: l10n.playlistName,
              hintText: l10n.playlistNameHint,
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  final repo = ref.read(playlistRepositoryProvider);
                  final existing = await repo.getPlaylists();
                  final exists = existing.any((p) => p.name.toLowerCase() == name.toLowerCase());
                  if (exists) {
                    if (context.mounted) CapsuleToast.show(context, l10n.playlistAlreadyExists(name));
                    return;
                  }
                  await repo.createPlaylist(name);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: Text(l10n.create, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
            ),
          ],
        );
      },
    );
  }
}

class _PlaylistCard extends ConsumerWidget {
  final Playlist playlist;

  const _PlaylistCard({required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PlaylistDetailScreen(playlist: playlist)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  playlist.coverPath != null
                      ? CoverArt(
                          path: playlist.coverPath!,
                          fit: BoxFit.cover,
                          isVideo: false,
                        )
                      : _buildPlaceholder(context),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        Icons.play_arrow,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 32,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        try {
                          final repo = ref.read(playlistRepositoryProvider);
                          final songs = await repo.getSongsForPlaylist(playlist.id);
                          if (songs.isNotEmpty) {
                            final controller = ref.read(playerControllerProvider);
                            // 先停止当前播放，然后设置新队列?
                            await controller.stop();
                            await controller.setQueue(songs);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            CapsuleToast.show(context, 'Error: $e');
                          }
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    AppLocalizations.of(context)!.songCount(playlist.songIds.length),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Icon(Icons.music_note, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}

