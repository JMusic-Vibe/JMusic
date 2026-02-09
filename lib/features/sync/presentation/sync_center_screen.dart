import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/widgets/capsule_toast.dart';
import 'package:jmusic/core/widgets/bottom_action_sheet.dart';
import 'package:jmusic/features/music_lib/presentation/library_screen.dart';
import 'package:jmusic/features/sync/application/sync_service.dart';
import 'package:jmusic/features/sync/data/sync_config_repository.dart';
import 'package:jmusic/features/sync/domain/entities/sync_config.dart';
import 'package:jmusic/features/sync/openlist/openlist_service_manager.dart';
import 'package:jmusic/features/sync/presentation/webdav_config_dialog.dart';
import 'package:jmusic/features/sync/presentation/webdav_config_screen.dart';
import 'package:jmusic/l10n/app_localizations.dart';

final syncConfigsProvider = FutureProvider<List<SyncConfig>>((ref) async {
  final repo = ref.watch(syncConfigRepositoryProvider);
  return repo.getAllConfigs();
});

class SyncCenterScreen extends ConsumerWidget {
  const SyncCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configsAsync = ref.watch(syncConfigsProvider);
    final openListService = ref.watch(openListServiceControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.syncCenter),
        actions: [
          IconButton(
            tooltip: l10n.addSyncAccount,
            icon: const Icon(Icons.add_link),
            onPressed: () {
              final actions = <ActionItem>[
                ActionItem(
                  icon: Icons.cloud,
                  title: l10n.webdav,
                  onTap: () {
                    final isSmallScreen = MediaQuery.of(context).size.width < 600;
                    if (isSmallScreen) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WebDavConfigScreen(),
                        ),
                      ).then((result) {
                        if (result == true) {
                          ref.invalidate(syncConfigsProvider);
                        }
                      });
                    } else {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const WebdavConfigDialog(),
                      ).then((result) {
                        if (result == true) {
                          ref.invalidate(syncConfigsProvider);
                        }
                      });
                    }
                  },
                ),
                ActionItem(
                  icon: Icons.list,
                  title: l10n.openlist,
                  onTap: () async {
                    final initialUrl = openListService.isRunning
                      ? OpenListServiceManager.buildDavUrl(openListService.address, openListService.port)
                      : null;
                    String? initialUsername;
                    if (openListService.isRunning) {
                      initialUsername = 'admin';
                    }
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WebDavConfigScreen(
                          initialType: SyncType.openlist,
                          initialUrl: initialUrl,
                          initialUsername: initialUsername,
                        ),
                      ),
                    ).then((result) {
                      if (result == true) {
                        ref.invalidate(syncConfigsProvider);
                      }
                    });
                  },
                ),
              ];
              BottomActionSheet.show(context, actions: actions, title: l10n.addSyncAccount);
            },
          ),
        ],
      ),
      body: configsAsync.when(
        data: (configs) {
            if (configs.isEmpty) {
                return Center(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            Icon(Icons.cloud_off, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noSyncAccount,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.addSyncAccountHint,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                        ],
                    ),
                );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: configs.length,
              itemBuilder: (context, index) {
                  final config = configs[index];
                  return _SyncConfigCard(config: config);
              },
            );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _SyncConfigCard extends ConsumerStatefulWidget {
  final SyncConfig config;

  const _SyncConfigCard({required this.config});

  @override
  ConsumerState<_SyncConfigCard> createState() => _SyncConfigCardState();
}

class _SyncConfigCardState extends ConsumerState<_SyncConfigCard> {
  bool _isSyncing = false;

  Future<void> _editConfig() async {
    final l10n = AppLocalizations.of(context)!;
    if (widget.config.type == SyncType.openlist) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WebDavConfigScreen(
            config: widget.config,
            initialType: SyncType.openlist,
          ),
        ),
      ).then((result) {
        if (result == true) {
          ref.invalidate(syncConfigsProvider);
        }
      });
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => WebdavConfigDialog(config: widget.config),
      ).then((result) {
          if (result == true) {
              ref.invalidate(syncConfigsProvider);
          }
      });
    }
  }

  Future<void> _deleteConfig() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
        context: context, 
          builder: (c) => AlertDialog(
            title: Text(l10n.confirmDelete, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
            content: Text(l10n.removeSyncConfigConfirm, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)), // Ensure this text mentions data deletion
            actions: [
              TextButton(onPressed: ()=>Navigator.pop(c, false), child: Text(l10n.cancel)),
              TextButton(onPressed: ()=>Navigator.pop(c, true), child: Text(l10n.delete)),
            ],
          ),
    );
    if (confirm == true) {
        try {
            await ref.read(syncServiceProvider).deleteAccount(widget.config);
            ref.invalidate(syncConfigsProvider);
        } catch (e) {
            if (context.mounted) {
               CapsuleToast.show(context, 'Delete failed: $e');
            }
        }
    }
  }

  Future<void> _syncAccount() async {
    setState(() => _isSyncing = true);
    
    // Create progress notifiers
    final currentNotifier = ValueNotifier<int>(0);
    final totalNotifier = ValueNotifier<int>(0);
    final fileNameNotifier = ValueNotifier<String>('');
    final completedNotifier = ValueNotifier<bool>(false);
    
    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ScanProgressDialog(
        currentNotifier: currentNotifier,
        totalNotifier: totalNotifier,
        fileNameNotifier: fileNameNotifier,
        completedNotifier: completedNotifier,
      ),
    );
    
    try {
      final result = await ref.read(syncServiceProvider).syncAccount(widget.config, onProgress: (current, total, fileName) {
        currentNotifier.value = current;
        totalNotifier.value = total;
        fileNameNotifier.value = fileName;
      });
      completedNotifier.value = true;
      if (mounted) {
        CapsuleToast.show(
          context,
          'Sync completed: scanned ${result.totalScanned}, added ${result.added}, updated ${result.updated}, removed ${result.removed}, failed ${result.failed}',
        );
      }
    } catch (e) {
      completedNotifier.value = true;
      if (mounted) {
        CapsuleToast.show(context, 'Sync failed: $e');
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
        leading: Icon(
          widget.config.type == SyncType.webdav ? Icons.dns : Icons.cloud_circle,
          color: widget.config.isEnabled ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: Text(widget.config.name, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(widget.config.url),
        trailing: _isSyncing
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : widget.config.isEnabled
            ? Chip(
                label: Text(
                  l10n.connected,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer),
                ),
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2),
              )
            : Chip(label: Text(l10n.paused, style: Theme.of(context).textTheme.bodySmall)),
        children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: isSmallScreen ? [
                      FilledButton.icon(
                          icon: const Icon(Icons.sync, size: 18),
                          label: Text(l10n.checkSyncNow),
                          onPressed: _isSyncing ? null : _syncAccount,
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          BottomActionSheet.show(context, actions: [
                            ActionItem(
                              icon: Icons.edit,
                              title: l10n.edit,
                              onTap: _editConfig,
                            ),
                            ActionItem(
                              icon: Icons.delete,
                              title: l10n.delete,
                              onTap: _deleteConfig,
                            ),
                          ]);
                        },
                      ),
                    ] : [
                        Flexible(
                          child: TextButton.icon(
                              icon: const Icon(Icons.edit, size: 18),
                              label: Text(l10n.edit),
                              onPressed: _editConfig,
                          ),
                        ),
                        Flexible(
                          child: TextButton.icon(
                              icon: const Icon(Icons.delete, size: 18),
                              label: Text(l10n.delete),
                              onPressed: _deleteConfig,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: FilledButton.icon(
                              icon: const Icon(Icons.sync, size: 18),
                              label: Text(l10n.checkSyncNow),
                              onPressed: _isSyncing ? null : _syncAccount,
                          ),
                        ),
                    ],
                ),
            )
        ],
      ),
      ),
    );
  }
}

