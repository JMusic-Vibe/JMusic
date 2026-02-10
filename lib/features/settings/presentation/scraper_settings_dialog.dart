import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/l10n/app_localizations.dart';
import 'package:jmusic/core/services/preferences_service.dart';

class ScraperSettingsDialog extends ConsumerStatefulWidget {
  const ScraperSettingsDialog({super.key});

  @override
  ConsumerState<ScraperSettingsDialog> createState() =>
      _ScraperSettingsDialogState();
}

class _ScraperSettingsDialogState extends ConsumerState<ScraperSettingsDialog> {
  late bool _usePrimary;
  late bool _autoScrapeOnPlay;
  late bool _useSongMusicBrainz;
  late bool _useSongItunes;
  late bool _useSongQQMusic;
  late bool _useArtistMusicBrainz;
  late bool _useArtistItunes;
  late bool _useArtistQQ;
  late bool _lyricsEnabled;
  late bool _lyricsLrclib;
  late bool _lyricsRangotec;
  late bool _lyricsItunes;
  late bool _lyricsQQ;

  @override
  void initState() {
    super.initState();
    _usePrimary = ref.read(preferencesServiceProvider).scraperUsePrimaryArtist;
    _autoScrapeOnPlay = ref.read(preferencesServiceProvider).scraperAutoScrapeOnPlay;
    _useSongMusicBrainz =
        ref.read(preferencesServiceProvider).scraperSourceMusicBrainz;
    _useSongItunes = ref.read(preferencesServiceProvider).scraperSourceItunes;
    _useSongQQMusic = ref.read(preferencesServiceProvider).scraperSourceQQMusic;
    _useArtistMusicBrainz =
        ref.read(preferencesServiceProvider).scraperArtistSourceMusicBrainz;
    _useArtistItunes =
        ref.read(preferencesServiceProvider).scraperArtistSourceItunes;
    _useArtistQQ =
        ref.read(preferencesServiceProvider).scraperArtistSourceQQMusic;
    _lyricsEnabled = ref.read(preferencesServiceProvider).scraperLyricsEnabled;
    _lyricsLrclib =
        ref.read(preferencesServiceProvider).scraperLyricsSourceLrclib;
    _lyricsRangotec =
        ref.read(preferencesServiceProvider).scraperLyricsSourceRangotec;
    _lyricsItunes =
        ref.read(preferencesServiceProvider).scraperLyricsSourceItunes;
    _lyricsQQ = ref.read(preferencesServiceProvider).scraperLyricsSourceQQMusic;
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
                  title: Text(l10n.autoScrapeOnPlayTitle),
                  // subtitle: Text(l10n.autoScrapeOnPlayDesc),
                  value: _autoScrapeOnPlay,
                  onChanged: (v) async {
                    setState(() => _autoScrapeOnPlay = v);
                    await ref
                        .read(preferencesServiceProvider)
                        .setScraperAutoScrapeOnPlay(v);
                  },
                ),
                SwitchListTile(
                  title: Text(l10n.usePrimaryArtistForScraper),
                  // subtitle: Text(l10n.usePrimaryArtistForScraperDesc),
                  value: _usePrimary,
                  onChanged: (v) async {
                    setState(() => _usePrimary = v);
                    await ref
                        .read(preferencesServiceProvider)
                        .setScraperUsePrimaryArtist(v);
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
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(l10n.scraperSourceMusicBrainz),
                  value: _useSongMusicBrainz,
                  onChanged: (v) async {
                    setState(() => _useSongMusicBrainz = v);
                    await ref
                        .read(preferencesServiceProvider)
                        .setScraperSourceMusicBrainz(v);
                  },
                ),
                SwitchListTile(
                  title: Text(l10n.scraperSourceItunes),
                  value: _useSongItunes,
                  onChanged: (v) async {
                    setState(() => _useSongItunes = v);
                    await ref
                        .read(preferencesServiceProvider)
                        .setScraperSourceItunes(v);
                  },
                ),
                SwitchListTile(
                  title: Text(l10n.scraperSourceQQMusic),
                  value: _useSongQQMusic,
                  onChanged: (v) async {
                    setState(() => _useSongQQMusic = v);
                    await ref
                        .read(preferencesServiceProvider)
                        .setScraperSourceQQMusic(v);
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
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(l10n.scraperSourceMusicBrainz),
                  value: _useArtistMusicBrainz,
                  onChanged: (v) async {
                    setState(() => _useArtistMusicBrainz = v);
                    await ref
                        .read(preferencesServiceProvider)
                        .setScraperArtistSourceMusicBrainz(v);
                  },
                ),
                SwitchListTile(
                  title: Text(l10n.scraperSourceItunes),
                  value: _useArtistItunes,
                  onChanged: (v) async {
                    setState(() => _useArtistItunes = v);
                    await ref
                        .read(preferencesServiceProvider)
                        .setScraperArtistSourceItunes(v);
                  },
                ),
                SwitchListTile(
                  title: Text(l10n.scraperSourceQQMusic),
                  value: _useArtistQQ,
                  onChanged: (v) async {
                    setState(() => _useArtistQQ = v);
                    await ref
                        .read(preferencesServiceProvider)
                        .setScraperArtistSourceQQMusic(v);
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
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(l10n.scraperSourceLrclib),
                  value: _lyricsLrclib,
                  onChanged: (v) async {
                    setState(() => _lyricsLrclib = v);
                    await ref
                        .read(preferencesServiceProvider)
                        .setScraperLyricsSourceLrclib(v);
                  },
                ),
                SwitchListTile(
                  title: Text(l10n.scraperSourceRangotec),
                  value: _lyricsRangotec,
                  onChanged: (v) async {
                    setState(() => _lyricsRangotec = v);
                    await ref
                        .read(preferencesServiceProvider)
                        .setScraperLyricsSourceRangotec(v);
                  },
                ),
                SwitchListTile(
                  title: Text(l10n.scraperSourceQQMusic),
                  value: _lyricsQQ,
                  onChanged: (v) async {
                    setState(() => _lyricsQQ = v);
                    await ref
                        .read(preferencesServiceProvider)
                        .setScraperLyricsSourceQQMusic(v);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
