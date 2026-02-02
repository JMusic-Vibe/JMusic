import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:jmusic/features/player/presentation/player_providers.dart';
import 'package:jmusic/features/scraper/presentation/batch_scraper_service.dart';
import 'package:jmusic/core/widgets/cover_art.dart';
import 'package:jmusic/core/services/database_service.dart';
import 'package:jmusic/features/scraper/presentation/scraper_search_dialog.dart';
import 'package:jmusic/features/playlists/presentation/playlist_selection_dialog.dart';
import 'package:jmusic/features/music_lib/presentation/widgets/song_details_dialog.dart';
import 'package:jmusic/features/music_lib/presentation/widgets/webdav_download_icon.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';
import 'package:jmusic/features/music_lib/domain/entities/playlist.dart';
import 'package:jmusic/features/playlists/data/playlist_repository.dart';
import 'package:jmusic/l10n/app_localizations.dart';
import 'package:jmusic/core/widgets/capsule_toast.dart';
import 'package:jmusic/core/widgets/bottom_action_sheet.dart';

// Check if song is liked (in "Favorites" playlist)
final isLikedProvider = StreamProvider.family<bool, int>((ref, songId) {
  final repo = ref.watch(playlistRepositoryProvider);
  return repo.watchPlaylists().map((playlists) {
    var fav = playlists.where((p) => p.name == 'Favorites').firstOrNull;
    if (fav == null) return false;
    return fav.songIds.contains(songId);
  });
});

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final mediaItem = ref.watch(currentMediaItemProvider).value;

    if (mediaItem == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(l10n.nowPlaying),
          centerTitle: true,
        ),
        body: Center(child: Text(l10n.noItemsFound)),
      );
    }

    final currentSongAsync = ref.watch(currentSongProvider);
    final currentSong = currentSongAsync.value;
    final isCloud = currentSong?.sourceType == SourceType.webdav || currentSong?.sourceType == SourceType.openalist;

    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: const IconThemeData(color: Colors.white),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight + 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 24.0),
              AppBar(
              primary: true,
              leading: IconButton(
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                isCloud ? l10n.sourceCloud : l10n.sourceLocal,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white70,
                  letterSpacing: 1.2,
                ),
              ),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              actions: [
                 IconButton(
                      icon: const Icon(Icons.auto_awesome_outlined, color: Colors.white),
                      tooltip: l10n.scraper,
                      onPressed: () async {
                        final id = int.tryParse(mediaItem.id);
                        if (id != null) {
                            final db = await ref.read(databaseServiceProvider).db;
                            final song = await db.songs.get(id);
                            if (context.mounted && song != null) {
                                showDialog(
                                  context: context,
                                  builder: (context) => ScraperSearchDialog(song: song),
                                );
                            }
                        }
                      },
                    ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () async {
                      final id = int.tryParse(mediaItem.id);
                      if (id != null) {
                            final db = await ref.read(databaseServiceProvider).db;
                            final song = await db.songs.get(id);
                            if (context.mounted && song != null) {
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
                                  ],
                                );
                            }
                        }
                  },
                ),
              ],
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            // 1. Background (Image + Blur)
            Positioned.fill(child: _buildBlurBackground(context, mediaItem)),
            
            // 2. Content
            SafeArea(
              child: Column(
                children: [
                   // Top Image Section
                   Expanded(
                     flex: 5,
                     child: Padding(
                       padding: const EdgeInsets.all(32.0),
                       child: Center(
                         child: AspectRatio(
                           aspectRatio: 1,
                           child: Builder(builder: (ctx) {
                             // If there's artwork provided, keep the original rounded-rect
                             // container with shadow. If not (we'll use the default
                             // transparent circular PNG), render a circular container
                             // so the transparent parts don't show a square dark background.
                             if (mediaItem.artUri != null) {
                               return Container(
                                 decoration: BoxDecoration(
                                   borderRadius: BorderRadius.circular(20),
                                   boxShadow: [
                                     BoxShadow(
                                       color: Colors.black.withOpacity(0.3),
                                       blurRadius: 20,
                                       offset: const Offset(0, 10),
                                     ),
                                   ],
                                 ),
                                 clipBehavior: Clip.antiAlias,
                                 child: _buildArtwork(mediaItem),
                               );
                             } else {
                              return Container(
                                alignment: Alignment.center,
                                // Use circular decoration so transparent PNG remains circular
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Transform.scale(
                                  scale: 1.08, // slightly larger default cover
                                  child: Container(
                                    // inner circle provides shadow separately so shape stays circular
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.25),
                                          blurRadius: 18,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: _buildArtwork(mediaItem),
                                  ),
                                ),
                              );
                             }
                           }),
                         ),
                       ),
                     ),
                   ),

                   // Info & Controls Section
                   Expanded(
                     flex: 4,
                     child: Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 24.0),
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.end,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            // Wrap inner content in flexible or scrollable to avoid overflow
                            Flexible(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                     // Title & Artist
                                     Row(
                                       children: [
                                         Expanded(
                                           child: Column(
                                             crossAxisAlignment: CrossAxisAlignment.start,
                                             children: [
                                               Row(
                                                   children: [
                                                       Flexible(
                                                           child: Text(
                                                             mediaItem.title,
                                                             style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                               fontWeight: FontWeight.bold, 
                                                               color: Colors.white
                                                             ),
                                                             maxLines: 1,
                                                             overflow: TextOverflow.ellipsis,
                                                           ),
                                                       ),
                                                       if (isCloud && currentSong != null) 
                                                         Padding(
                                                           padding: const EdgeInsets.only(left: 8.0),
                                                           child: WebDavDownloadIcon(song: currentSong, color: Colors.white),
                                                         )
                                                   ]
                                               ),
                                               const SizedBox(height: 4),
                                               Text(
                                                 "${mediaItem.artist ?? l10n.unknownArtist} • ${mediaItem.album ?? l10n.unknownAlbum}",
                                                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                                                 maxLines: 1,
                                                 overflow: TextOverflow.ellipsis,
                                               ),
                                             ],
                                           ),
                                         ),
                                       ],
                                     ),
                                     const SizedBox(height: 16),
                                     
                                     // Buttons Row (Like, Lyrics)
                                     Row(
                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                         children: [
                                             _LikeButton(song: currentSong),
                                             const Spacer(),
                                             IconButton(
                                                 icon: const Icon(Icons.lyrics_outlined, color: Colors.white),
                                                 onPressed: () {
                                                     CapsuleToast.show(context, l10n.lyricsComingSoon);
                                                 },
                                             ),
                                         ],
                                     ),
                                  ],
                                ),
                              ),
                            ),

                            // Progress (Keep these visible if possible)
                            const _ProgressBar(),
                            
                            // Controls
                            const _PlayerControls(),
                            
                            const SizedBox(height: 16),
                         ],
                       ),
                     ),
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurBackground(BuildContext context, MediaItem item) {
    // Deterministic random based on media id (falls back to time-seed)
    final seed = int.tryParse(item.id ?? '') ?? DateTime.now().millisecondsSinceEpoch;
    final random = Random(seed);

    final palettes = [
      [Colors.blue.shade400, Colors.purple.shade400, Colors.pink.shade300],
      [Colors.green.shade400, Colors.teal.shade400, Colors.yellow.shade400],
      [Colors.orange.shade400, Colors.red.shade400, Colors.pink.shade300],
      [Colors.cyan.shade400, Colors.blue.shade400, Colors.purple.shade400],
      [Colors.yellow.shade400, Colors.orange.shade400, Colors.red.shade400],
      [Colors.pink.shade300, Colors.purple.shade400, Colors.blue.shade400],
    ];

    final chosen = palettes[random.nextInt(palettes.length)];
    final baseGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: chosen,
    );

    // When there's no cover art, paint several soft radial 'ink' blobs
    Widget colorBlobs() {
      final size = MediaQuery.of(context).size;
      // produce 3 blobs with different positions/sizes
      return Stack(
        children: List.generate(3, (i) {
          final clr = chosen[i % chosen.length].withOpacity(0.45 + random.nextDouble() * 0.15);
          final blobSize = (min(size.width, size.height) * (0.6 - i * 0.12)).clamp(120.0, 800.0);
          final dx = (random.nextDouble() * 1.4) - 0.2; // -0.2 .. 1.2
          final dy = (random.nextDouble() * 1.0) - 0.1; // -0.1 .. 0.9

          return Align(
            alignment: Alignment(dx * 2 - 1, dy * 2 - 1),
            child: Transform.rotate(
              angle: (random.nextDouble() - 0.5) * 0.6,
              child: Container(
                width: blobSize,
                height: blobSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [clr, clr.withOpacity(0.05)],
                    radius: 0.8,
                  ),
                ),
              ),
            ),
          );
        }),
      );
    }

    return Stack(
      children: [
        if (item.artUri != null)
          Positioned.fill(child: CoverArt(path: item.artUri.toString(), fit: BoxFit.cover))
        else
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(gradient: baseGradient),
              child: colorBlobs(),
            ),
          ),
        // Frosted Glass Effect
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
            child: Container(
              color: Colors.black.withOpacity(0.35), // subtle dark overlay for contrast
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArtwork(MediaItem item) {
    return RotatingArtwork(item: item);
  }
}

class RotatingArtwork extends ConsumerStatefulWidget {
  final MediaItem item;
  const RotatingArtwork({required this.item});

  @override
  ConsumerState<RotatingArtwork> createState() => _RotatingArtworkState();
}

class _RotatingArtworkState extends ConsumerState<RotatingArtwork> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static const _rotationDuration = Duration(seconds: 20);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _rotationDuration);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final artPath = widget.item.artUri?.toString();

    // Only rotate when there's NO cover art (we use the default asset as
    // the 'vinyl' to rotate). If a real art is present, keep it static.
    final isPlaying = ref.watch(isPlayingProvider).value ?? false;

    Widget image;
    if (artPath != null) {
      // If there's artwork, ensure animation is stopped and show static image.
      if (_controller.isAnimating) _controller.stop();
      image = CoverArt(path: artPath, fit: BoxFit.cover);

      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox.expand(child: image),
      );
    } else {
      image = Image.asset('assets/images/default_player_cover.png', fit: BoxFit.cover);

      if (isPlaying) {
        if (!_controller.isAnimating) _controller.repeat();
      } else {
        if (_controller.isAnimating) _controller.stop();
      }

      // Keep the rotating content constrained so it doesn't overlap other UI
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * pi,
            child: child,
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox.expand(child: image),
        ),
      );
    }
  }
}

class _LikeButton extends ConsumerWidget {
  final Song? song;
  const _LikeButton({required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (song == null) return const IconButton(onPressed: null, icon: Icon(Icons.favorite_border, color: Colors.white30));
    
    final isLikedAsync = ref.watch(isLikedProvider(song!.id));
    
    return IconButton(
        icon: isLikedAsync.when(
            data: (liked) => Icon(liked ? Icons.favorite : Icons.favorite_border, 
                                  color: liked ? Colors.redAccent : Colors.white),
            loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            error: (_,__) => const Icon(Icons.error_outline, color: Colors.white),
        ),
        onPressed: () => _toggleLike(context, ref),
    );
  }
  
  Future<void> _toggleLike(BuildContext context, WidgetRef ref) async {
       final repo = ref.read(playlistRepositoryProvider);
       final isar = await ref.read(databaseServiceProvider).db;
       
         final playlists = await repo.getPlaylists();
         const favName = 'Favorites';
         var fav = playlists.where((p) => p.name == favName).firstOrNull;

         if (fav == null) {
           // Keep description localized, but use invariant internal name
           await repo.createPlaylist(favName, description: AppLocalizations.of(context)!.favoritesPlaylistDescription);
           final newPlaylists = await repo.getPlaylists();
           fav = newPlaylists.where((p) => p.name == favName).firstOrNull;
         }
       
       if (fav != null) {
           final currentList = List<int>.from(fav.songIds);
           bool added = false;
           if (currentList.contains(song!.id)) {
               currentList.remove(song!.id);
               added = false;
           } else {
               currentList.add(song!.id);
               added = true;
           }
           
           fav.songIds = currentList;
           
           await isar.writeTxn(() async {
               await isar.playlists.put(fav!);
           });
           
           if (context.mounted) {
               CapsuleToast.show(context, added ? AppLocalizations.of(context)!.addedToFavorites : AppLocalizations.of(context)!.removedFromFavorites);
           }
       }
  }
}

class _ProgressBar extends ConsumerWidget {
  const _ProgressBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(positionProvider).value ?? Duration.zero;
    final duration = ref.watch(durationProvider).value ?? Duration.zero;
    final controller = ref.read(playerControllerProvider);

    final double posMs = position.inMilliseconds.toDouble();
    final double durMs = duration.inMilliseconds.toDouble();
    final double sliderValue = durMs > 0 ? (posMs.clamp(0.0, durMs) as double) : 0.0;

    return Column(
      children: [
        SliderTheme(
            data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white24,
                thumbColor: Colors.white,
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: sliderValue,
              max: durMs > 0 ? durMs : 1.0,
              onChanged: (value) {
                controller.seek(Duration(milliseconds: value.toInt()));
              },
            ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70),
              ),
              Text(
                _formatDuration(duration),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds"; 
  }
}

class _PlayerControls extends ConsumerWidget {
  const _PlayerControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(isPlayingProvider).value ?? false;
    final shuffleEnabled = ref.watch(shuffleModeProvider).value ?? false;
    final loopMode = ref.watch(loopModeProvider).value ?? LoopMode.off;
    final controller = ref.read(playerControllerProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
         IconButton(
          icon: _buildModeIcon(context, shuffleEnabled, loopMode),
          onPressed: controller.cyclePlaybackMode,
        ),
        IconButton(
          icon: const Icon(Icons.skip_previous, size: 36, color: Colors.white),
          onPressed: controller.previous,
        ),
        Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
            ),
            child: IconButton(
              iconSize: 48,
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
              onPressed: controller.togglePlay,
            ),
        ),
        IconButton(
          icon: const Icon(Icons.skip_next, size: 36, color: Colors.white),
          onPressed: controller.next,
        ),
        IconButton(
          icon: const Icon(Icons.queue_music, color: Colors.white),
          onPressed: () {
              showModalBottomSheet(
                context: context,
                useRootNavigator: true,
                backgroundColor: Theme.of(context).colorScheme.surface,
                builder: (context) => const QueueSheet(),
              );
          },
        ),
      ],
    );
  }

  Widget _buildModeIcon(BuildContext context, bool shuffle, LoopMode loop) {
        if (shuffle) {
          return const Icon(Icons.shuffle, color: Colors.white);
        }
        if (loop == LoopMode.one) {
          return const Icon(Icons.repeat_one, color: Colors.white);
        }
        if (loop == LoopMode.all) {
          return const Icon(Icons.repeat, color: Colors.white);
        }
        return const Icon(Icons.repeat, color: Colors.white30);
  }
}

class QueueSheet extends ConsumerStatefulWidget {
  const QueueSheet({super.key});

  @override
  ConsumerState<QueueSheet> createState() => _QueueSheetState();
}

class _QueueSheetState extends ConsumerState<QueueSheet> {
  final ScrollController _scrollController = ScrollController();
  bool _initialScrollDone = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queueAsync = ref.watch(queueProvider);
    final currentMediaItem = ref.watch(currentMediaItemProvider).value;
    final controller = ref.read(playerControllerProvider);
    const double itemHeight = 72.0;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text(
                   l10n.playingQueue,
                   style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                 ),
                 TextButton.icon(
                   icon: const Icon(Icons.clear_all),
                   label: Text(l10n.clear),
                   onPressed: () async {
                     await controller.clearQueue();
                     if (context.mounted) Navigator.pop(context);
                   },
                 ),
               ],
             ),
          ),
          Expanded(
            child: queueAsync.when(
              data: (queue) {
                if (queue.isEmpty) return Center(child: Text(l10n.noItemsFound, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)));

                // Locate and scroll to current item once
                if (!_initialScrollDone && currentMediaItem != null) {
                  final index = queue.indexWhere((item) => item.id == currentMediaItem.id);
                  if (index != -1) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                         double offset = index * itemHeight;
                         // Center the item in the list if possible
                         final viewportHeight = _scrollController.position.viewportDimension;
                         final maxScroll = _scrollController.position.maxScrollExtent;
                         
                         // Try to center: offset - (half viewport) + (half item)
                         double centeredOffset = offset - (viewportHeight / 2) + (itemHeight / 2);
                         
                         // Clamp
                         if (centeredOffset < 0) centeredOffset = 0;
                         if (centeredOffset > maxScroll) centeredOffset = maxScroll;
                         
                         _scrollController.jumpTo(centeredOffset);
                      }
                    });
                    _initialScrollDone = true;
                  }
                }

                return ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  scrollController: _scrollController,
                  itemExtent: itemHeight,
                  itemCount: queue.length,
                  onReorder: (oldIndex, newIndex) {
                     controller.moveQueueItem(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final item = queue[index];
                    final isSelected = currentMediaItem?.id == item.id;
                    final song = item.extras?['song'] as Song?;
                    final key = ValueKey('${item.id}_$index'); 
                    
                    return Dismissible(
                      key: key,
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Theme.of(context).colorScheme.error,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
                      ),
                      onDismissed: (_) {
                         controller.removeFromQueue(index);
                      },
                      child: ListTile(
                        key: key,
                        leading: item.artUri != null 
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: CoverArt(
                                path: item.artUri.toString(),
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover, // Updated to cover
                              ),
                            )
                          : const Icon(Icons.music_note),
                        title: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          item.artist ?? l10n.unknownArtist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                             // Handle Cloud icon in queue
                            if (song != null && (song.sourceType == SourceType.webdav || song.sourceType == SourceType.openalist))
                               Padding(
                                 padding: const EdgeInsets.only(right: 12.0),
                                 child: WebDavDownloadIcon(song: song, size: 20),
                               ),
                             ReorderableDragStartListener(
                              index: index,
                              child: isSelected
                                ? Icon(Icons.graphic_eq, color: Theme.of(context).colorScheme.primary)
                                : const Icon(Icons.drag_handle, color: Colors.transparent),
                             ),
                          ],
                        ),
                        selected: isSelected,
                        tileColor: isSelected ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3) : null,
                        onTap: () async {
                          try {
                            await controller.skipToIndex(index);
                            await controller.play();
                            if (mounted) Navigator.of(context).pop(); 
                          } catch (e) {
                            print('[ERROR] Queue tap: $e');
                          }
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

