import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/localization/language_provider.dart';
import 'package:jmusic/core/services/preferences_service.dart';
import 'package:jmusic/l10n/app_localizations.dart';

class LanguageSettingsDialog extends ConsumerWidget {
  const LanguageSettingsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Current locale from provider (null means system)
    final currentLocale = ref.watch(languageProvider);
    // Persisted string value (to distinguish between explicit system setting vs active system locale)
    final savedLocaleStr = ref.watch(preferencesServiceProvider).locale;

    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(
        l10n.language,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRadioTile(
            context,
            ref,
            title: AppLocalizations.of(context)!.themeSystem,
            value: 'system',
            groupValue: savedLocaleStr,
          ),
          _buildRadioTile(
             context,
            ref,
            title: '简体中文',
            value: 'zh',
            groupValue: savedLocaleStr,
          ),
          _buildRadioTile(
             context,
            ref,
            title: '繁體中文',
            value: 'zh_Hant',
            groupValue: savedLocaleStr,
          ),
          _buildRadioTile(
             context,
            ref,
            title: 'English',
            value: 'en',
            groupValue: savedLocaleStr,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
      ],
    );
  }

  Widget _buildRadioTile(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String value,
    required String groupValue,
  }) {
    return RadioListTile<String>(
      title: Text(title),
      value: value,
      groupValue: groupValue,
      onChanged: (newValue) {
        if (newValue != null) {
          ref.read(languageProvider.notifier).setLocale(newValue);
          Navigator.pop(context);
        }
      },
    );
  }
}

