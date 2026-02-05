import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/l10n/app_localizations.dart';
import 'package:jmusic/features/settings/presentation/proxy_config_dialog.dart';
import 'package:jmusic/features/settings/presentation/theme_settings_dialog.dart';
import 'package:jmusic/features/settings/presentation/default_page_settings_dialog.dart';
import 'package:jmusic/features/settings/presentation/language_settings_dialog.dart';
import 'package:jmusic/features/settings/presentation/storage_settings_dialog.dart';
import 'package:jmusic/features/settings/presentation/scraper_settings_dialog.dart';
import 'package:jmusic/features/settings/presentation/playback_settings_dialog.dart';
import 'package:jmusic/features/sync/openlist/openlist_settings_screen.dart';
import 'package:jmusic/core/theme/theme_provider.dart';
import 'package:jmusic/core/services/preferences_service.dart';
import 'package:jmusic/core/localization/language_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final defaultPageIndex = ref.watch(preferencesServiceProvider.select((p) => p.defaultPageIndex));
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(languageProvider);
    final localeStr = ref.watch(preferencesServiceProvider).locale;
    
    String getThemeModeText(ThemeMode mode) {
      switch (mode) {
        case ThemeMode.light:
          return l10n.themeLight;
        case ThemeMode.dark:
          return l10n.themeDark;
        case ThemeMode.system:
          return l10n.themeSystem;
      }
    }

    String getDefaultPageText(int index) {
      // ['首页', '音乐库', '歌单', '同步', '刮削', '设置']
      switch (index) {
        case 0: return l10n.home;
        case 1: return l10n.library;
        case 2: return l10n.playlists;
        case 3: return l10n.sync;
        case 4: return l10n.scraper;
        case 5: return l10n.settings;
        default: return l10n.home;
      }
    }

    String getLanguageText() {
       if (localeStr == 'system') return l10n.themeSystem;
       if (localeStr == 'zh') return '简体中文';
       if (localeStr == 'zh_Hant') return '繁體中文';
       if (localeStr == 'en') return 'English';
       return l10n.themeSystem;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
           ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l10n.language),
            subtitle: Text(getLanguageText()),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LanguageSettingsDialog()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l10n.theme),
            subtitle: Text(getThemeModeText(themeMode)),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ThemeSettingsDialog()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: Text(l10n.defaultPage), 
            subtitle: Text(getDefaultPageText(defaultPageIndex)),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DefaultPageSettingsDialog()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: Text(l10n.storageEvents),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StorageSettingsDialog()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome_outlined),
            title: Text(l10n.scraperSettings),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ScraperSettingsDialog()),
              );
            },
          ),
           ListTile(
            leading: const Icon(Icons.tune_outlined),
            title: Text(l10n.audioSettings),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PlaybackSettingsDialog()),
              );
            },
          ),
           ListTile(
            leading: const Icon(Icons.public_outlined), 
            title: Text(l10n.proxySettings),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProxyConfigDialog()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud_circle_outlined),
            title: Text(l10n.openlist),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const OpenListSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

