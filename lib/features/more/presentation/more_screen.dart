import 'package:flutter/material.dart';
import 'package:jmusic/features/scraper/presentation/scraper_center_screen.dart';
import 'package:jmusic/features/settings/presentation/settings_screen.dart';
import 'package:jmusic/features/sync/presentation/sync_center_screen.dart';
import 'package:jmusic/l10n/app_localizations.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.more),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _NavTile(
            title: l10n.syncCenter,
            subtitle: l10n.syncCenterSubtitle,
            icon: Icons.sync,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SyncCenterScreen()),
              );
            },
          ),
          _NavTile(
            title: l10n.scraperCenter,
            subtitle: l10n.scraperCenterSubtitle,
            icon: Icons.auto_awesome,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ScraperCenterScreen()),
              );
            },
          ),
          _NavTile(
            title: l10n.settings,
            subtitle: l10n.settingsSubtitle,
            icon: Icons.settings,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _NavTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

