import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/services/webdav_service.dart';
import 'package:jmusic/core/widgets/capsule_toast.dart';
import 'package:jmusic/features/sync/application/sync_service.dart';
import 'package:jmusic/features/sync/data/sync_config_repository.dart';
import 'package:jmusic/l10n/app_localizations.dart';

class StorageSettingsDialog extends ConsumerWidget {
  const StorageSettingsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(
        l10n.storageEvents,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: FutureBuilder(
          future: ref.read(syncConfigRepositoryProvider).getAllConfigs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final configs = snapshot.data ?? [];
            
            return ListView(
              shrinkWrap: true,
              children: [
                 if (configs.isNotEmpty) ...[
                   Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Text(l10n.webdavAccountsCache, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                   ),
                   ...configs.map((config) => ListTile(
                     title: Text(config.name),
                     subtitle: Text(config.url),
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
                            )
                          );
                          
                          if (confirm == true) {
                            await ref.read(syncServiceProvider).clearCacheForAccount(config);
                            if (context.mounted) {
                              CapsuleToast.show(context, l10n.accountCacheCleared);
                            }
                          }
                       },
                     ),
                   )),
                   const Divider(),
                 ],
                 
                /*
                 ListTile(
                   title: Text('Clear Legacy WebDAV Cache', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                   subtitle: Text('Delete unassigned downloaded songs', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                   trailing: IconButton(
                     icon: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
                     onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: Text(l10n.confirm, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                            content: Text('Clear all legacy cached WebDAV songs?', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l10n.cancel)),
                              TextButton(onPressed: () => Navigator.pop(c, true), child: Text(l10n.clear)),
                            ],
                          )
                        );
                        
                        if (confirm == true) {
                          await ref.read(webDavServiceProvider).clearCache(); // Only clears default folder
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Legacy cache cleared')));
                          }
                        }
                     },
                   ),
                 )
                 */
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.confirm)),
      ],
    );
  }
}


