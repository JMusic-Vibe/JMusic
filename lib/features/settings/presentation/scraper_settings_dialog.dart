import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/l10n/app_localizations.dart';
import 'package:jmusic/core/services/preferences_service.dart';
import 'package:jmusic/core/widgets/capsule_toast.dart';

class ScraperSettingsDialog extends ConsumerStatefulWidget {
  const ScraperSettingsDialog({super.key});

  @override
  ConsumerState<ScraperSettingsDialog> createState() => _ScraperSettingsDialogState();
}

class _ScraperSettingsDialogState extends ConsumerState<ScraperSettingsDialog> {
  late bool _usePrimary;
  late bool _useSongMusicBrainz;
  late bool _useSongItunes;
  late bool _useArtistMusicBrainz;
  late bool _useArtistItunes;
  late bool _lyricsEnabled;

  @override
  void initState() {
    super.initState();
    _usePrimary = ref.read(preferencesServiceProvider).scraperUsePrimaryArtist;
    _useSongMusicBrainz = ref.read(preferencesServiceProvider).scraperSourceMusicBrainz;
    _useSongItunes = ref.read(preferencesServiceProvider).scraperSourceItunes;
    _useArtistMusicBrainz = ref.read(preferencesServiceProvider).scraperArtistSourceMusicBrainz;
    _useArtistItunes = ref.read(preferencesServiceProvider).scraperArtistSourceItunes;
    _lyricsEnabled = ref.read(preferencesServiceProvider).scraperLyricsEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scraperSettings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
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
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.scraperSongSources,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(l10n.scraperSourceMusicBrainz),
                  value: _useSongMusicBrainz,
                  onChanged: (v) async {
                    if (!v && !_useSongItunes) {
                      CapsuleToast.show(context, l10n.scraperSourceAtLeastOne);
                      return;
                    }
                    setState(() => _useSongMusicBrainz = v);
                    await ref.read(preferencesServiceProvider).setScraperSourceMusicBrainz(v);
                  },
                ),
                SwitchListTile(
                  title: Text(l10n.scraperSourceItunes),
                  value: _useSongItunes,
                  onChanged: (v) async {
                    if (!v && !_useSongMusicBrainz) {
                      CapsuleToast.show(context, l10n.scraperSourceAtLeastOne);
                      return;
                    }
                    setState(() => _useSongItunes = v);
                    await ref.read(preferencesServiceProvider).setScraperSourceItunes(v);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.scraperArtistSources,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(l10n.scraperSourceMusicBrainz),
                  value: _useArtistMusicBrainz,
                  onChanged: (v) async {
                    if (!v && !_useArtistItunes) {
                      CapsuleToast.show(context, l10n.scraperSourceAtLeastOne);
                      return;
                    }
                    setState(() => _useArtistMusicBrainz = v);
                    await ref.read(preferencesServiceProvider).setScraperArtistSourceMusicBrainz(v);
                  },
                ),
                SwitchListTile(
                  title: Text(l10n.scraperSourceItunes),
                  value: _useArtistItunes,
                  onChanged: (v) async {
                    if (!v && !_useArtistMusicBrainz) {
                      CapsuleToast.show(context, l10n.scraperSourceAtLeastOne);
                      return;
                    }
                    setState(() => _useArtistItunes = v);
                    await ref.read(preferencesServiceProvider).setScraperArtistSourceItunes(v);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.scraperLyricsSources,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(l10n.scraperLyricsSources),
                  subtitle: Text(l10n.scraperLyricsSourcesFixed),
                  value: _lyricsEnabled,
                  onChanged: (v) async {
                    setState(() => _lyricsEnabled = v);
                    await ref.read(preferencesServiceProvider).setScraperLyricsEnabled(v);
                  },
                ),
                SwitchListTile(
                  title: Text(l10n.scraperSourceLrclib),
                  value: _lyricsEnabled,
                  onChanged: null,
                ),
                SwitchListTile(
                  title: Text(l10n.scraperSourceRangotec),
                  value: _lyricsEnabled,
                  onChanged: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

