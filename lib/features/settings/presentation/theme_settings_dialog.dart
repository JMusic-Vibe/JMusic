import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/theme/theme_provider.dart';
import 'package:jmusic/l10n/app_localizations.dart';

class ThemeSettingsDialog extends ConsumerWidget {
  const ThemeSettingsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeModeProvider);
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(
        l10n.theme,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<ThemeMode>(
            title: Text(l10n.themeLight),
            value: ThemeMode.light,
            groupValue: currentThemeMode,
            onChanged: (value) {
              if (value != null) {
                ref.read(themeModeProvider.notifier).setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.themeDark),
            value: ThemeMode.dark,
            groupValue: currentThemeMode,
            onChanged: (value) {
              if (value != null) {
                ref.read(themeModeProvider.notifier).setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.themeSystem),
            value: ThemeMode.system,
            groupValue: currentThemeMode,
            onChanged: (value) {
              if (value != null) {
                ref.read(themeModeProvider.notifier).setThemeMode(value);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.confirm),
        ),
      ],
    );
  }
}

