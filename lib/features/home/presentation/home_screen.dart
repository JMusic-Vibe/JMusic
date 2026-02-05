import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/services/audio_player_service.dart';
import 'package:jmusic/core/widgets/capsule_toast.dart';
import 'package:jmusic/features/player/presentation/player_providers.dart';
import 'package:jmusic/core/widgets/cover_art.dart';
import 'package:jmusic/features/home/presentation/home_controller.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';
import 'package:jmusic/l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            tooltip: '刷新推荐',
            onPressed: () async {
              await ref.read(homeControllerProvider.notifier).refreshAll();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: homeState.when(
        data: (state) => RefreshIndicator(
          onRefresh: () => ref.read(homeControllerProvider.notifier).refreshAll(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              if (state.forYou.isNotEmpty)
                _QuickPickSection(
                  title: l10n.forYou,
                  songs: state.forYou,
                ),
              if (state.forYou.isNotEmpty)
                _GeneratedPlaylistSection(
                  title: l10n.playlistRecommendations,
                  songs: state.forYou,
                ),
              if (state.recentlyPlayed.isNotEmpty)
                _SongListSection(
                  title: l10n.recentlyPlayed,
                  songs: state.recentlyPlayed,
                  icon: Icons.history,
                  onPlayAll: () {
                    ref.read(audioPlayerServiceProvider).setQueue(state.recentlyPlayed);
                    ref.read(audioPlayerServiceProvider).player.play();
                  },
                ),
              if (state.recentlyImported.isNotEmpty)
                _SongListSection(
                  title: l10n.recentlyImported,
                  songs: state.recentlyImported,
                  icon: Icons.library_add,
                  onPlayAll: () {
                    ref.read(audioPlayerServiceProvider).setQueue(state.recentlyImported);
                    ref.read(audioPlayerServiceProvider).player.play();
                  },
                ),
              if (state.toBeScraped.isNotEmpty)
                _SongListSection(
                  title: l10n.toBeScraped,
                  subtitle: l10n.toBeScrapedSubtitle(state.toBeScraped.length),
                  songs: state.toBeScraped,
                  icon: Icons.auto_awesome,
                  onPlayAll: null,
                ),
              if (state.recentlyPlayed.isEmpty &&
                  state.recentlyImported.isEmpty &&
                  state.toBeScraped.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.music_note, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noMusicData,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _QuickPickSection extends ConsumerWidget {
  final String title;
  final List<Song> songs;

  const _QuickPickSection({
    required this.title,
    required this.songs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displaySongs = songs.take(8).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 3.6,
          ),
          itemCount: displaySongs.length,
          itemBuilder: (context, index) {
            final song = displaySongs[index];
            return InkWell(
              onTap: () async {
                try {
                  await ref.read(playerControllerProvider).playSingle(song);
                } catch (e) {
                  if (context.mounted) {
                    CapsuleToast.show(context, AppLocalizations.of(context)!.playbackError(e.toString()));
                  }
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: CoverArt(path: song.coverPath, fit: BoxFit.cover, isVideo: song.mediaType == MediaType.video),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SongListSection extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final List<Song> songs;
  final IconData icon;
  final VoidCallback? onPlayAll;
  final VoidCallback? onTap;

  const _SongListSection({
    required this.title,
    this.subtitle,
    required this.songs,
    required this.icon,
    this.onPlayAll,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              if (onPlayAll != null)
                IconButton(
                  icon: const Icon(Icons.play_circle_fill),
                  onPressed: onPlayAll,
                  tooltip: AppLocalizations.of(context)!.playAll,
                ),
              if (onTap != null)
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: onTap,
                )
            ],
          ),
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
          ),
        SizedBox(
          height: 160,
          child: ScrollConfiguration(
            behavior: MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              },
            ),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(), // Enable smooth scrolling
              itemCount: songs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _SongCard(song: songs[index]);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SongCard extends ConsumerWidget {
  final Song song;

  const _SongCard({required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: 110,
      child: InkWell(
        onTap: () async {
          try {
            await ref.read(playerControllerProvider).playSingle(song);
          } catch (e) {
            if (context.mounted) {
              CapsuleToast.show(context, l10n.playbackError(e.toString()));
            }
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Card(
                elevation: 2,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: CoverArt(path: song.coverPath, isVideo: song.mediaType == MediaType.video),
              ),
            ),
            const SizedBox(height: 6),
            Builder(builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(
                song.title.isNotEmpty ? song.title : l10n.unknown,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
              );
            }),
            Builder(builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(
                song.artists.isNotEmpty ? song.artists.join(' / ') : (song.artist.isNotEmpty ? song.artist : l10n.unknownArtist),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _GeneratedPlaylistSection extends ConsumerWidget {
  final String title;
  final List<Song> songs;

  const _GeneratedPlaylistSection({
    required this.title,
    required this.songs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final coverPath = songs.isNotEmpty ? songs.first.coverPath : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        InkWell(
          onTap: () async {
            await ref.read(audioPlayerServiceProvider).setQueue(songs);
            await ref.read(audioPlayerServiceProvider).player.play();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: CoverArt(path: coverPath, fit: BoxFit.cover, isVideo: songs.isNotEmpty && songs.first.mediaType == MediaType.video),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.songCount(songs.length),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  tooltip: l10n.playAll,
                  onPressed: () async {
                    await ref.read(audioPlayerServiceProvider).setQueue(songs);
                    await ref.read(audioPlayerServiceProvider).player.play();
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

