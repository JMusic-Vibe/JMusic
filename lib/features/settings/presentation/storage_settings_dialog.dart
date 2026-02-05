import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/services/webdav_service.dart';
import 'package:jmusic/core/services/cover_cache_service.dart';
import 'dart:math' as Math;
import 'package:jmusic/core/widgets/capsule_toast.dart';
import 'dart:io';
import 'package:jmusic/core/services/log_service.dart';
import 'package:jmusic/features/sync/application/sync_service.dart';
import 'package:jmusic/features/sync/data/sync_config_repository.dart';
import 'package:jmusic/l10n/app_localizations.dart';

class StorageSettingsDialog extends ConsumerStatefulWidget {
  const StorageSettingsDialog({super.key});

  static String _formatBytes(int bytes, [int decimals = 1]) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (bytes == 0) ? 0 : (Math.log(bytes) / Math.log(1024)).floor();
    final value = bytes / Math.pow(1024, i);
    return '${value.toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  @override
  ConsumerState<StorageSettingsDialog> createState() => _StorageSettingsDialogState();
}

class _StorageSettingsDialogState extends ConsumerState<StorageSettingsDialog> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.storageEvents),
      ),
      body: FutureBuilder(
        future: ref.read(syncConfigRepositoryProvider).getAllConfigs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final configs = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(l10n.coverCache, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                      subtitle: FutureBuilder<int>(
                        future: CoverCacheService().getCacheSize(),
                        builder: (c, snap) {
                          final bytes = snap.data ?? 0;
                          final sizeText = snap.connectionState == ConnectionState.waiting
                              ? '...'
                              : StorageSettingsDialog._formatBytes(bytes);
                          return Text(sizeText, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant));
                        },
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.primary),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: Text(l10n.confirm, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                              content: Text(l10n.clearCoverCacheConfirm, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l10n.cancel)),
                                TextButton(onPressed: () => Navigator.pop(c, true), child: Text(l10n.clear)),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await CoverCacheService().clearCache();
                            if (mounted) {
                              CapsuleToast.show(context, l10n.coverCacheCleared);
                              setState(() {});
                            }
                          }
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(l10n.artistAvatarCache, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                      subtitle: FutureBuilder<int>(
                        future: CoverCacheService().getCacheSize(subDir: CoverCacheService.artistAvatarSubDir),
                        builder: (c, snap) {
                          final bytes = snap.data ?? 0;
                          final sizeText = snap.connectionState == ConnectionState.waiting
                              ? '...'
                              : StorageSettingsDialog._formatBytes(bytes);
                          return Text(sizeText, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant));
                        },
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.primary),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: Text(l10n.confirm, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                              content: Text(l10n.clearArtistAvatarCacheConfirm, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l10n.cancel)),
                                TextButton(onPressed: () => Navigator.pop(c, true), child: Text(l10n.clear)),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await CoverCacheService().clearCache(subDir: CoverCacheService.artistAvatarSubDir);
                            if (mounted) {
                              CapsuleToast.show(context, l10n.artistAvatarCacheCleared);
                              setState(() {});
                            }
                          }
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(l10n.embeddedCoverCache, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                      subtitle: FutureBuilder<int>(
                        future: CoverCacheService().getCacheSize(subDir: CoverCacheService.embeddedCoverSubDir),
                        builder: (c, snap) {
                          final bytes = snap.data ?? 0;
                          final sizeText = snap.connectionState == ConnectionState.waiting
                              ? '...'
                              : StorageSettingsDialog._formatBytes(bytes);
                          return Text(sizeText, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant));
                        },
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.primary),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: Text(l10n.confirm, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                              content: Text(l10n.clearEmbeddedCoverCacheConfirm, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l10n.cancel)),
                                TextButton(onPressed: () => Navigator.pop(c, true), child: Text(l10n.clear)),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await CoverCacheService().clearCache(subDir: CoverCacheService.embeddedCoverSubDir);
                            if (mounted) {
                              CapsuleToast.show(context, l10n.embeddedCoverCacheCleared);
                              setState(() {});
                            }
                          }
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(l10n.appDataSize, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                      subtitle: FutureBuilder<int>(
                        future: CoverCacheService().getAppDataSize(),
                        builder: (c, snap) {
                          final bytes = snap.data ?? 0;
                          final sizeText = snap.connectionState == ConnectionState.waiting
                              ? '...'
                              : StorageSettingsDialog._formatBytes(bytes);
                          return Text(sizeText, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant));
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: Text(l10n.logExport, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                      subtitle: FutureBuilder<int>(
                        future: LogService.instance.getLogSize(),
                        builder: (c, snap) {
                          final bytes = snap.data ?? 0;
                          final sizeText = snap.connectionState == ConnectionState.waiting
                              ? '...'
                              : StorageSettingsDialog._formatBytes(bytes);
                          return Text('${l10n.logFileSize}: $sizeText', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant));
                        },
                      ),
                        trailing: IconButton(
                          icon: Icon(Icons.ios_share, color: Theme.of(context).colorScheme.primary),
                          onPressed: () async {
                            final exported = await LogService.instance.exportLog();
                            if (exported == null) {
                              if (mounted) CapsuleToast.show(context, 'No logs available');
                              return;
                            }
                            if (mounted) CapsuleToast.show(context, l10n.logExported);
                          },
                        ),
                    ),
                    ListTile(
                      title: Text(l10n.clearLogs, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.primary),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: Text(l10n.confirm, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                              content: Text(l10n.clearLogsConfirm, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l10n.cancel)),
                                TextButton(onPressed: () => Navigator.pop(c, true), child: Text(l10n.clear)),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await LogService.instance.clearLogs();
                            if (mounted) {
                              CapsuleToast.show(context, l10n.logsCleared);
                              setState(() {});
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (configs.isNotEmpty) ...[
                Text(l10n.webdavAccountsCache, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      ...configs.map((config) => ListTile(
                        title: Text(config.name),
                        subtitle: FutureBuilder<int>(
                          future: ref.read(syncServiceProvider).getCacheSizeForAccount(config),
                          builder: (c, snap) {
                            final bytes = snap.data ?? 0;
                            String sizeText;
                            if (snap.connectionState == ConnectionState.waiting) {
                              sizeText = '...';
                            } else {
                              sizeText = StorageSettingsDialog._formatBytes(bytes);
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(config.url),
                                const SizedBox(height: 4),
                                Text('${sizeText} cached', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                              ],
                            );
                          },
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.primary),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: Text(l10n.confirm, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                                content: Text(l10n.clearCacheForAccount(config.name), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l10n.cancel)),
                                  TextButton(onPressed: () => Navigator.pop(c, true), child: Text(l10n.clear)),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await ref.read(syncServiceProvider).clearCacheForAccount(config);
                              if (mounted) {
                                CapsuleToast.show(context, l10n.accountCacheCleared);
                                setState(() {});
                              }
                            }
                          },
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}


