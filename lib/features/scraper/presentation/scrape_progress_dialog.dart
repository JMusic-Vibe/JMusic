import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/features/scraper/presentation/scraper_providers.dart';
import 'package:jmusic/l10n/app_localizations.dart';

class ScrapeProgressDialog extends ConsumerWidget {
  const ScrapeProgressDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(scrapeProgressProvider);
    final notifier = ref.read(scrapeProgressProvider.notifier);

    if (!progress.isRunning) {
      // If no longer running, close dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
    }

    final total = progress.total;
    final done = progress.done;
    final percent = total > 0 ? done / total : 0.0;

    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.batchScrapeRunning, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
      content: SizedBox(
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LinearProgressIndicator(value: percent),
            const SizedBox(height: 12),
            Text('${done} / ${total}'),
            const SizedBox(height: 8),
            Text(progress.currentTitle ?? '正在准备...', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: progress.cancelled ? null : () => notifier.cancel(),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}

