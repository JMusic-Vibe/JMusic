import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/l10n/app_localizations.dart';
import 'package:jmusic/core/services/audio_player_service.dart';

class PlaybackSettingsDialog extends ConsumerStatefulWidget {
  const PlaybackSettingsDialog({super.key});

  @override
  ConsumerState<PlaybackSettingsDialog> createState() => _PlaybackSettingsDialogState();
}

class _PlaybackSettingsDialogState extends ConsumerState<PlaybackSettingsDialog> {
  late bool _crossfadeEnabled;
  late double _crossfadeDuration;

  @override
  void initState() {
    super.initState();
    final audioService = ref.read(audioPlayerServiceProvider);
    _crossfadeEnabled = audioService.getCrossfadeEnabled();
    _crossfadeDuration = audioService.getCrossfadeDuration().toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final audioService = ref.watch(audioPlayerServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.playbackSettings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            // 淡入淡出开关
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.crossfadeEnabled,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              // subtitle: Padding(
              //   padding: const EdgeInsets.only(top: 4),
              //   child: Text(
              //     l10n.crossfadeEnabledDesc,
              //     style: theme.textTheme.bodySmall?.copyWith(
              //       color: theme.colorScheme.onSurfaceVariant,
              //     ),
              //   ),
              // ),
              value: _crossfadeEnabled,
              onChanged: (value) async {
                setState(() {
                  _crossfadeEnabled = value;
                });
                await audioService.setCrossfadeEnabled(value);
              },
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // 淡入淡出时长设置
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.crossfadeDuration,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _crossfadeEnabled
                            ? theme.colorScheme.onSurface
                            : theme.disabledColor,
                      ),
                    ),
                    Text(
                      l10n.seconds(_crossfadeDuration.round().toString()),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: _crossfadeEnabled
                            ? theme.colorScheme.primary
                            : theme.disabledColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // const SizedBox(height: 8),
                // Text(
                //   l10n.crossfadeDurationDesc,
                //   style: theme.textTheme.bodySmall?.copyWith(
                //     color: theme.colorScheme.onSurfaceVariant.withOpacity(
                //       _crossfadeEnabled ? 1.0 : 0.5,
                //     ),
                //   ),
                // ),
                const SizedBox(height: 12),
                Slider(
                  value: _crossfadeDuration,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: l10n.seconds(_crossfadeDuration.round().toString()),
                  onChanged: _crossfadeEnabled
                      ? (value) {
                          setState(() {
                            _crossfadeDuration = value;
                          });
                        }
                      : null,
                  onChangeEnd: (value) async {
                    await audioService.setCrossfadeDuration(value.round());
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // 说明卡片
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _crossfadeEnabled
                          ? l10n.crossfadeEnabledInfo
                          : l10n.crossfadeDisabledInfo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

