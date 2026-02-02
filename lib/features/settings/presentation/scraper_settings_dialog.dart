import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/l10n/app_localizations.dart';
import 'package:jmusic/core/services/preferences_service.dart';

class ScraperSettingsDialog extends ConsumerStatefulWidget {
  const ScraperSettingsDialog({super.key});

  @override
  ConsumerState<ScraperSettingsDialog> createState() => _ScraperSettingsDialogState();
}

class _ScraperSettingsDialogState extends ConsumerState<ScraperSettingsDialog> {
  late bool _usePrimary;

  @override
  void initState() {
    super.initState();
    _usePrimary = ref.read(preferencesServiceProvider).scraperUsePrimaryArtist;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(
        l10n.scraperSettings,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: Text(l10n.usePrimaryArtistForScraper),
            // subtitle: Text(l10n.usePrimaryArtistForScraperDesc),
            value: _usePrimary,
            onChanged: (v) async {
              setState(() => _usePrimary = v);
              await ref.read(preferencesServiceProvider).setScraperUsePrimaryArtist(v);
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(context), child: Text(l10n.confirm)),
      ],
    );
  }
}

