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
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              if (state.forYou.isNotEmpty)
                _SongListSection(
                  title: l10n.forYou,
                  songs: state.forYou,
                  icon: Icons.favorite,
                  onPlayAll: () {
                    ref.read(audioPlayerServiceProvider).setQueue(state.forYou);
                    ref.read(audioPlayerServiceProvider).player.play();
                  },
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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
                Icon(icon, size: 20,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
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
          height: 180,
          child: ScrollConfiguration(
            behavior: MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              },
            ),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
        const SizedBox(height: 24),
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
      width: 120,
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
                child: CoverArt(path: song.coverPath),
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

