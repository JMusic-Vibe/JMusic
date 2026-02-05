import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/services/preferences_service.dart';
import 'package:jmusic/l10n/app_localizations.dart';

class DefaultPageSettingsDialog extends ConsumerStatefulWidget {
  const DefaultPageSettingsDialog({super.key});

  @override
  ConsumerState<DefaultPageSettingsDialog> createState() => _DefaultPageSettingsDialogState();
}

class _DefaultPageSettingsDialogState extends ConsumerState<DefaultPageSettingsDialog> {
  late int _selectedIndex;

  // Labels come from localization at build time.

  @override
  void initState() {
    super.initState();
    _selectedIndex = ref.read(preferencesServiceProvider).defaultPageIndex;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final pageOptions = [
      _PageOption(label: l10n.home, icon: Icons.home),
      _PageOption(label: l10n.library, icon: Icons.library_music),
      _PageOption(label: l10n.playlists, icon: Icons.queue_music),
      _PageOption(label: l10n.sync, icon: Icons.sync),
      _PageOption(label: l10n.scraper, icon: Icons.auto_awesome),
      _PageOption(label: l10n.settings, icon: Icons.settings),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.defaultPage),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                const SizedBox(height: 8),
                ...List.generate(pageOptions.length, (index) {
                  final option = pageOptions[index];
                  return RadioListTile<int>(
                    title: Row(
                      children: [
                        Icon(option.icon, size: 20),
                        const SizedBox(width: 12),
                        Text(option.label),
                      ],
                    ),
                    value: index,
                    groupValue: _selectedIndex,
                    onChanged: (value) async {
                      setState(() {
                        _selectedIndex = value!;
                      });
                      await ref.read(preferencesServiceProvider).setDefaultPageIndex(value!);
                    },
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageOption {
  const _PageOption({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

