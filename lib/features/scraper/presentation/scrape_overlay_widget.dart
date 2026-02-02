import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/l10n/app_localizations.dart';
import 'batch_scraper_service.dart';

class ScrapeOverlayWidget extends ConsumerWidget {
  const ScrapeOverlayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(batchScraperProvider);
    final notifier = ref.read(batchScraperProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayColor = Theme.of(context).colorScheme.onSurface.withOpacity(isDark ? 0.6 : 0.2);

    // 1. 显示结果弹窗
    if (state.showResult) {
       return Container( // 全屏透明容器作为背景拦截点击，或者直接用 AlertDialog
          color: overlayColor,
          child: Center(
            child: AlertDialog(
               title: Text(l10n.scrapedCompletedTitle),
               content: Column(
                 mainAxisSize: MainAxisSize.min,
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(l10n.totalTasks(state.total)),
                   const SizedBox(height: 8),
                   Text(l10n.successCount(state.successCount), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
                   Text(l10n.failCount(state.failCount), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error)),
                 ],
               ),
               actions: [
                 FilledButton(
                   onPressed: notifier.closeResultDialog,
                   child: Text(l10n.confirm),
                 ),
               ],
            ),
          ),
       );
    }

    // 2. 如果不在运行状态，隐藏
    if (!state.isRunning) return const SizedBox.shrink();

    // 3. 运行中..
    if (state.isMinimized) {
      // 最小化模式：悬浮图标
      return Positioned(
        top: 100,
        right: 16,
        child: Material(
          color: Theme.of(context).colorScheme.primaryContainer,
          elevation: 8,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: notifier.maximize,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: CircularProgressIndicator(
                      value: state.total > 0 ? state.done / state.total : 0,
                      color: Theme.of(context).colorScheme.primary,
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      strokeWidth: 4,
                    ),
                  ),
                  Icon(Icons.cloud_sync, 
                    size: 20, 
                    color: Theme.of(context).colorScheme.onPrimaryContainer
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 完整模式：带透明背景 Dialog
    // 使用 SizedBox.expand 确保撑满整个屏幕，从而使 Positioned.fill 生效
    return SizedBox.expand(
      child: Stack(
      children: [
        // 透明遮罩，点击外部最小化
        Positioned.fill(
          child: GestureDetector(
            onTap: notifier.minimize,
            behavior: HitTestBehavior.opaque, 
            child: Container(
              color: overlayColor, // 半透明背景
            ),
          ),
        ),
        // 居中 Dialog
        Center(
          child: GestureDetector(
            onTap: () {}, // 拦截点击，防止最小化
            child: Material(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              elevation: 24,
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.batchScrapeRunning, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 24),
                    LinearProgressIndicator(
                      value: state.total > 0 ? state.done / state.total : 0,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            state.currentTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${state.done} / ${state.total}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: notifier.minimize, 
                          child: Text(l10n.hide),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonal(
                          onPressed: state.cancelled ? null : notifier.cancel,
                          child: Text(l10n.cancel),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }
}

