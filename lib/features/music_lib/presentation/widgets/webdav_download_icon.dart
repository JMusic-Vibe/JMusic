import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/widgets/capsule_toast.dart';
import 'package:jmusic/features/music_lib/application/download_manager.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';

class WebDavDownloadIcon extends ConsumerWidget {
  final Song song;
  final double size;
  final Color? color;

  const WebDavDownloadIcon({
    super.key,
    required this.song,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (song.sourceType != SourceType.webdav && song.sourceType != SourceType.openalist) {
      return const SizedBox.shrink();
    }

    final cacheStatusAsync = ref.watch(songCacheStatusProvider(song.id));
    final progress = ref.watch(downloadProgressProvider(song.id));
    final isDownloading = progress != null;

    final isCached = cacheStatusAsync.valueOrNull ?? false;

    return GestureDetector(
      onTap: () async {
        if (!isCached && !isDownloading) {
          try {
            await ref.read(downloadManagerProvider).startDownload(song.id);
          } catch (e) {
            if (context.mounted) {
               CapsuleToast.show(context, 'Download failed: $e');
            }
          }
        }
      },
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Progress
            if (isDownloading)
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            
            if (isCached)
               Icon(Icons.check_circle, color: Colors.green, size: size * 0.8)
            else if (!isDownloading)
               Icon(Icons.cloud_download_outlined, color: color ?? Theme.of(context).colorScheme.onSurfaceVariant, size: size * 0.8)
            else
               // Downloading center icon
               Icon(Icons.pause, size: size * 0.6, color: color ?? Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

