import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:jmusic/core/widgets/capsule_toast.dart';
import 'package:jmusic/core/widgets/bottom_action_sheet.dart';
import 'package:jmusic/core/widgets/cover_art.dart';
import 'package:jmusic/features/playlists/presentation/playlists_screen.dart';
import 'package:jmusic/features/music_lib/domain/entities/playlist.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';
import 'package:jmusic/features/playlists/data/playlist_repository.dart';
import 'package:jmusic/features/player/presentation/player_providers.dart';
import 'package:jmusic/features/player/presentation/widgets/mini_player.dart';
import 'package:jmusic/features/music_lib/presentation/widgets/song_details_dialog.dart';
import 'package:jmusic/features/playlists/presentation/playlist_selection_dialog.dart';

import 'package:jmusic/l10n/app_localizations.dart';

final playlistSongsProvider = StreamProvider.family<List<Song>, int>((ref, playlistId) {
  final repo = ref.watch(playlistRepositoryProvider);
  return repo.watchPlaylist(playlistId).asyncMap((playlist) {
    return repo.getSongsForPlaylist(playlistId);
  });
});

class PlaylistDetailScreen extends ConsumerStatefulWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  ConsumerState<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends ConsumerState<PlaylistDetailScreen> {
  late String playlistName;
  String? coverPath;

  @override
  void initState() {
    super.initState();
    playlistName = widget.playlist.name;
    coverPath = widget.playlist.coverPath;
  }

  @override
  Widget build(BuildContext context) {
    final songsAsync = ref.watch(playlistSongsProvider(widget.playlist.id));
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: songsAsync.when(
        data: (songs) => CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 280,
              backgroundColor: theme.colorScheme.surface,
              // Use a white icon theme for the background
              iconTheme: const IconThemeData(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  playlistName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 8, color: Colors.black26, offset: const Offset(0, 2))],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CoverArt(path: coverPath, fit: BoxFit.cover),
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              theme.colorScheme.surface.withOpacity(0.8),
                              theme.colorScheme.surface,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Hero(
                            tag: 'playlist_cover_${widget.playlist.id}',
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: CoverArt(path: coverPath, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showActions(context, l10n),
                ),
              ],
            ),
            if (songs.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    l10n.emptyPlaylist,
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface),
                  ),
                ),
              )
            else
              SliverReorderableList(
                itemCount: songs.length,
                onReorder: (oldIndex, newIndex) async {
                  int adjustedNewIndex = newIndex;
                  if (adjustedNewIndex > oldIndex) adjustedNewIndex -= 1;
                  await ref.read(playlistRepositoryProvider).reorderSongsInPlaylist(widget.playlist.id, oldIndex, adjustedNewIndex);
                  ref.invalidate(playlistSongsProvider(widget.playlist.id));
                },
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return ReorderableDelayedDragStartListener(
                    key: ValueKey(song.id),
                    index: index,
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: CoverArt(path: song.coverPath),
                          ),
                        ),
                        title: Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          '${song.artists.isNotEmpty ? song.artists.join(' / ') : (song.artist ?? l10n.unknownArtist)} · ${song.album ?? l10n.unknownAlbum}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.more_horiz),
                              onPressed: () {
                                BottomActionSheet.show(
                                  context,
                                  title: song.title,
                                  actions: [
                                    ActionItem(
                                      icon: Icons.playlist_add,
                                      title: l10n.addToPlaylist,
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => PlaylistSelectionDialog(songIds: [song.id]),
                                        );
                                      },
                                    ),
                                    ActionItem(
                                      icon: Icons.info_outline,
                                      title: l10n.songDetails,
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => SongDetailsDialog(song: song),
                                        );
                                      },
                                    ),
                                    ActionItem(
                                      icon: Icons.remove_circle_outline,
                                      title: l10n.delete, // Use "Remove from playlist" if available
                                      color: Colors.red,
                                      onTap: () async {
                                        await ref.read(playlistRepositoryProvider).removeSongFromPlaylist(widget.playlist.id, index);
                                        ref.invalidate(playlistSongsProvider(widget.playlist.id));
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                            const Icon(Icons.drag_handle, size: 20),
                          ],
                        ),
                        onTap: () {
                          ref.read(playerControllerProvider).setQueue(songs, initialIndex: index);
                        },
                      ),
                    ),
                  );
                },
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text(e.toString())),
      ),
    );
  }

  void _showActions(BuildContext context, AppLocalizations l10n) {
    final isProtected = widget.playlist.name == 'Favorites';
    final actions = <ActionItem>[];

    // Only show rename action for non-protected playlists
    if (!isProtected) {
      actions.add(
        ActionItem(
          icon: Icons.edit,
          title: l10n.rename,
          onTap: () async {
            final controller = TextEditingController(text: playlistName);
            final newName = await showDialog<String>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.rename),
                content: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(labelText: l10n.playlistName),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, controller.text.trim()),
                    child: Text(l10n.rename),
                  ),
                ],
              ),
            );
            if (newName != null && newName.isNotEmpty && newName != playlistName) {
              await ref.read(playlistRepositoryProvider).renamePlaylist(widget.playlist.id, newName);
              if (!mounted) return;
              setState(() => playlistName = newName);
            }
          },
        ),
      );
    }
    actions.add(
      ActionItem(
        icon: Icons.image,
        title: l10n.importCover,
        onTap: () async {
          try {
            final result = await FilePicker.platform.pickFiles(type: FileType.image);
            if (result != null && result.files.isNotEmpty && result.files.first.path != null) {
              final src = result.files.first.path!;
              final appDir = await getApplicationDocumentsDirectory();
              final coversDir = Directory('${appDir.path}/playlist_covers');
              if (!await coversDir.exists()) await coversDir.create(recursive: true);
              final ext = src.contains('.') ? src.substring(src.lastIndexOf('.')) : '';
              final filename = '${widget.playlist.id}_${DateTime.now().millisecondsSinceEpoch}$ext';
              final destPath = '${coversDir.path}/$filename';
              await File(src).copy(destPath);
              await ref.read(playlistRepositoryProvider).setPlaylistCoverFromFile(widget.playlist.id, src, destPath);
              if (!mounted) return;
              setState(() => coverPath = destPath);
            }
          } catch (e) {
            if (context.mounted) CapsuleToast.show(context, e.toString());
          }
        },
      ),
    );
    actions.add(
      ActionItem(
        icon: Icons.clear,
        title: l10n.clearCover,
        onTap: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.clearCover),
              content: Text(l10n.confirmClearCover(playlistName)),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
                TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.clearCover, style: const TextStyle(color: Colors.red))),
              ],
            ),
          );
          if (confirm == true) {
            await ref.read(playlistRepositoryProvider).clearPlaylistCover(widget.playlist.id);
            if (!mounted) return;
            setState(() => coverPath = null);
          }
        },
      ),
    );
    actions.add(
      ActionItem(
        icon: Icons.clear_all,
        title: l10n.clearPlaylist,
        onTap: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.clearPlaylist),
              content: Text(l10n.confirmClearPlaylist(playlistName)),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
                TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.delete, style: const TextStyle(color: Colors.red))),
              ],
            ),
          );
          if (confirm == true) {
            await ref.read(playlistRepositoryProvider).clearPlaylist(widget.playlist.id);
            ref.invalidate(playlistSongsProvider(widget.playlist.id));
          }
        },
      ),
    );
    actions.add(
      ActionItem(
        icon: Icons.delete,
        title: l10n.deletePlaylist,
        color: Theme.of(context).colorScheme.error,
        onTap: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.deletePlaylist),
              content: Text(l10n.confirmDeletePlaylist(playlistName)),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
                TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.delete, style: const TextStyle(color: Colors.red))),
              ],
            ),
          );
          if (confirm == true) {
            await ref.read(playlistRepositoryProvider).deletePlaylist(widget.playlist.id);
            if (context.mounted) Navigator.pop(context);
          }
        },
      ),
    );
    
    BottomActionSheet.show(context, actions: actions);
  }
}

