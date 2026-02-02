import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/widgets/capsule_toast.dart';
import 'package:jmusic/features/music_lib/domain/entities/playlist.dart';
import 'package:jmusic/features/playlists/data/playlist_repository.dart';
import 'package:jmusic/features/playlists/presentation/playlists_screen.dart'; // reuse stream provider
import 'package:jmusic/features/playlists/presentation/playlist_detail_screen.dart';
import 'package:jmusic/l10n/app_localizations.dart';

class PlaylistSelectionDialog extends ConsumerWidget {
  final List<int> songIds;

  const PlaylistSelectionDialog({super.key, required this.songIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsProvider);
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(
        l10n.addToPlaylist,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
      ),
      content: SizedBox(
        width: min(300, MediaQuery.of(context).size.width * 0.9),
        height: min(400, MediaQuery.of(context).size.height * 0.7),
        child: playlistsAsync.when(
          data: (playlists) {
            if (playlists.isEmpty) {
              return Center(child: Text(l10n.noPlaylists, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)));
            }
            return ListView.builder(
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return ListTile(
                  leading: Icon(Icons.queue_music, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  title: Text(playlist.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                  subtitle: Text(l10n.songCount(playlist.songIds.length), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  onTap: () async {
                    // Prevent adding duplicates: compute only-songIds-not-already-in-playlist
                    final toAdd = songIds.where((id) => !playlist.songIds.contains(id)).toList();
                    if (toAdd.isEmpty) {
                      if (context.mounted) {
                        Navigator.pop(context);
                        CapsuleToast.show(context, l10n.songsAlreadyInPlaylist(playlist.name));
                      }
                      return;
                    }

                    await ref.read(playlistRepositoryProvider).addSongsToPlaylist(playlist.id, toAdd);
                    // Invalidate the playlist songs provider so detail screens refresh
                    ref.invalidate(playlistSongsProvider(playlist.id));
                    if (context.mounted) {
                      Navigator.pop(context);
                      CapsuleToast.show(context, l10n.addedToPlaylist(playlist.name));
                    }
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $s', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error))),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}

