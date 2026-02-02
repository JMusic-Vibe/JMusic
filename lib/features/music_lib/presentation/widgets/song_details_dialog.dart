import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/widgets/capsule_toast.dart';
import 'package:jmusic/features/sync/data/sync_config_repository.dart';
import 'package:jmusic/features/sync/domain/entities/sync_config.dart';
import 'package:jmusic/core/services/preferences_service.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';
import 'package:jmusic/l10n/app_localizations.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

class SongDetailsDialog extends ConsumerWidget {
  final Song song;

  const SongDetailsDialog({super.key, required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.music_note, color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.songDetails,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                              Text(
                                song.title.isNotEmpty ? song.title : l10n.unknown,
                                style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // File Info Section
                    _buildSectionHeader(context, 'File Information', Icons.folder),
                    _buildInfoRow(
                      context,
                      l10n.fileName,
                      p.basename(song.path),
                      onTap: () => _copyToClipboard(context, p.basename(song.path), l10n.fileName),
                    ),
                    // File path: resolve full webdav URL when applicable
                    FutureBuilder<String>(
                      future: _resolveFullPath(ref),
                      builder: (context, snap) {
                        final raw = snap.data ?? song.path;
                        String full;
                        try {
                          full = Uri.decodeFull(raw);
                        } catch (_) {
                          full = raw;
                        }
                        final display = _truncatePath(full);
                        return _buildInfoRow(
                          context,
                          l10n.filePath,
                          display,
                          tooltip: full,
                          onTap: () => _copyToClipboard(context, full, l10n.fullPath),
                        );
                      },
                    ),
                    if (song.size != null)
                      _buildInfoRow(
                        context,
                        l10n.size,
                        _formatFileSize(song.size!),
                      ),
                    if (song.dateAdded != null)
                      _buildInfoRow(
                        context,
                        l10n.dateAdded,
                        DateFormat.yMMMd().add_Hms().format(song.dateAdded!),
                      ),

                    const SizedBox(height: 24),

                    // Metadata Section
                    _buildSectionHeader(context, 'Metadata', Icons.info),
                    _buildInfoRow(
                      context,
                      'Title',
                      song.title.isNotEmpty ? song.title : l10n.unknown,
                    ),
                    _buildInfoRow(
                      context,
                      'Artist',
                      _formatArtistDisplay(song, l10n),
                    ),
                    _buildInfoRow(
                      context,
                      'Album',
                      song.album.isNotEmpty ? song.album : l10n.unknownAlbum,
                    ),
                    if (song.duration != null)
                      _buildInfoRow(
                        context,
                        l10n.duration,
                        _formatDuration(song.duration!),
                      ),
                    if (song.genre != null && song.genre!.isNotEmpty)
                      _buildInfoRow(context, l10n.genre, song.genre!),
                    if (song.year != null)
                      _buildInfoRow(context, l10n.year, song.year.toString()),
                    if (song.trackNumber != null)
                      _buildInfoRow(context, l10n.trackNumber, song.trackNumber.toString()),
                    if (song.discNumber != null)
                      _buildInfoRow(context, l10n.discNumber, song.discNumber.toString()),
                    if (song.lastPlayed != null)
                      _buildInfoRow(
                        context,
                        l10n.lastPlayed,
                        DateFormat.yMMMd().add_Hms().format(song.lastPlayed!),
                      ),
                    if (song.lyrics != null && song.lyrics!.isNotEmpty)
                      _buildExpandableRow(
                        context,
                        l10n.lyrics,
                        song.lyrics!,
                        maxLines: 3,
                      ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    String? tooltip,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: tooltip != null
                ? Tooltip(
                    message: tooltip,
                    child: InkWell(
                      onTap: onTap ?? () => _copyToClipboard(context, tooltip, label),
                      child: Text(
                        value,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                : InkWell(
                    onTap: onTap,
                    child: Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
                    ),
                  ),
          ),
          if (onTap != null)
            IconButton(
              onPressed: onTap,
              icon: Icon(Icons.copy, size: 16, color: theme.colorScheme.onSurfaceVariant),
              tooltip: l10n.copyToClipboard,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  String _formatArtistDisplay(Song song, AppLocalizations l10n) {
    if (song.artists.isEmpty) return song.artist.isNotEmpty ? song.artist : l10n.unknownArtist;
    if (song.artists.length == 1) return song.artists.first;
    final main = song.artists.first;
    final rest = song.artists.sublist(1).join(', ');
    return '$main (feat. $rest)';
  }

  Widget _buildExpandableRow(
    BuildContext context,
    String label,
    String value,
    {int maxLines = 3}
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _truncatePath(String path) {
    if (path.length <= 50) return path;
    return '...${path.substring(path.length - 47)}';
  }

  Future<String> _resolveFullPath(WidgetRef ref) async {
    // If not webdav, return original path
    if (song.sourceType != SourceType.webdav) return song.path;

    // Prefer explicit remoteUrl if present
    if (song.remoteUrl != null && song.remoteUrl!.isNotEmpty) return song.remoteUrl!;

    // Try to find SyncConfig by id
    final repo = ref.read(syncConfigRepositoryProvider);
    try {
      final configs = await repo.getAllConfigs();
      SyncConfig? cfg;
      for (final c in configs) {
        if (song.syncConfigId != null && c.id == song.syncConfigId) {
          cfg = c;
          break;
        }
      }
      String base = '';
      if (cfg != null) {
        base = cfg.url;
      } else {
        // Fallback to preferences default
        final prefs = ref.read(preferencesServiceProvider);
        base = prefs.webDavUrl;
      }

      if (base.isEmpty) return song.path;

      var cleanUrl = base;
      if (cleanUrl.endsWith('/')) cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
      var path = song.path;
      if (!path.startsWith('/')) path = '/$path';
      final encodedPath = path.split('/').map((s) => Uri.encodeComponent(s)).join('/');
      return '$cleanUrl$encodedPath';
    } catch (e) {
      return song.path;
    }
  }

  String _formatFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    double size = bytes.toDouble();
    int i = 0;
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  String _formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    CapsuleToast.show(context, '$label ${AppLocalizations.of(context)!.copyToClipboard}');
  }
}

