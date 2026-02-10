import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  throw UnimplementedError('Initialize this provider in main via overrides');
});

class PreferencesService {
  final SharedPreferences _prefs;
  PreferencesService(this._prefs);

  static const String keyProxyMode = 'proxy_mode'; // 'system', 'custom', 'none'
  static const String keyProxyHost = 'proxy_host';
  static const String keyProxyPort = 'proxy_port';
  static const String keyOpenListPort = 'openlist_port';
  static const String keyOpenListProxyMode =
      'openlist_proxy_mode'; // 'system', 'custom', 'none'
  static const String keyOpenListProxyHost = 'openlist_proxy_host';
  static const String keyOpenListProxyPort = 'openlist_proxy_port';
  static const String keyOpenListAutoStart = 'openlist_auto_start';
  static const String keyThemeMode = 'theme_mode'; // 'system', 'light', 'dark'
  static const String keyLastQueueSongIds =
      'last_queue_song_ids'; // List<String> of song IDs
  static const String keyLastQueueIndex =
      'last_queue_index'; // int current index
  static const String keyLastQueuePosition =
      'last_queue_position'; // int position in milliseconds
  static const String keyDefaultPageIndex =
      'default_page_index'; // int default page index
  static const String keyLocale = 'locale'; // 'system', 'zh', 'zh_Hant', 'en'

  // WebDAV
  static const String keyWebDavUrl = 'webdav_url';
  static const String keyWebDavUser = 'webdav_user';
  static const String keyWebDavPassword = 'webdav_password';
  static const String keyWebDavPath = 'webdav_path';
  // Scraper
  static const String keyScraperUsePrimaryArtist = 'scraper_use_primary_artist';
  static const String keyScraperSourceMusicBrainz =
      'scraper_source_musicbrainz';
  static const String keyScraperSourceItunes = 'scraper_source_itunes';
  static const String keyScraperArtistSourceMusicBrainz =
      'scraper_artist_source_musicbrainz';
  static const String keyScraperArtistSourceItunes =
      'scraper_artist_source_itunes';
  static const String keyScraperArtistSourceQQMusic =
      'scraper_artist_source_qq_music';
  static const String keyScraperLyricsEnabled = 'scraper_lyrics_enabled';
  static const String keyScraperLyricsSourceLrclib =
      'scraper_lyrics_source_lrclib';
  static const String keyScraperLyricsSourceRangotec =
      'scraper_lyrics_source_rangotec';
  static const String keyScraperLyricsSourceItunes =
      'scraper_lyrics_source_itunes';
  static const String keyScraperLyricsSourceQQMusic =
      'scraper_lyrics_source_qq_music';
  static const String keyScraperSourceQQMusic = 'scraper_source_qq_music';
    static const String keyScraperAutoScrapeOnPlay = 'scraper_auto_scrape_on_play';

  // Audio playback
  static const String keyCrossfadeEnabled = 'crossfade_enabled';
  static const String keyCrossfadeDuration = 'crossfade_duration'; // in seconds
  static const String keyLyricsDisplayMode =
      'lyrics_display_mode'; // 'off', 'compact', 'full'
  static const String keyShuffleEnabled = 'shuffle_enabled';
  static const String keyLoopMode = 'loop_mode'; // 'off', 'all', 'one'
  static const String keyDesktopVolume = 'desktop_volume'; // 0.0 ~ 1.0
  static const String _keyScrapeBackupPrefix = 'scrape_backup_';

  String get proxyMode => _prefs.getString(keyProxyMode) ?? 'system';
  String get proxyHost => _prefs.getString(keyProxyHost) ?? '127.0.0.1';
  int get proxyPort => _prefs.getInt(keyProxyPort) ?? 7890;
  int get openListPort => _prefs.getInt(keyOpenListPort) ?? 5244;
  String get openListProxyMode =>
      _prefs.getString(keyOpenListProxyMode) ?? 'none';
  String get openListProxyHost =>
      _prefs.getString(keyOpenListProxyHost) ?? '127.0.0.1';
  int get openListProxyPort => _prefs.getInt(keyOpenListProxyPort) ?? 7890;
  bool get openListAutoStart => _prefs.getBool(keyOpenListAutoStart) ?? false;
  String get themeMode => _prefs.getString(keyThemeMode) ?? 'system';
  String get locale => _prefs.getString(keyLocale) ?? 'system';
  int get defaultPageIndex =>
      _prefs.getInt(keyDefaultPageIndex) ?? 0; // Default to Home (index 0)

  // WebDAV
  String get webDavUrl => _prefs.getString(keyWebDavUrl) ?? '';
  String get webDavUser => _prefs.getString(keyWebDavUser) ?? '';
  String get webDavPassword => _prefs.getString(keyWebDavPassword) ?? '';
  String get webDavPath => _prefs.getString(keyWebDavPath) ?? '';

  // Scraper
  bool get scraperUsePrimaryArtist =>
      _prefs.getBool(keyScraperUsePrimaryArtist) ?? true;
  bool get scraperSourceMusicBrainz =>
      _prefs.getBool(keyScraperSourceMusicBrainz) ?? true;
  bool get scraperSourceItunes =>
      _prefs.getBool(keyScraperSourceItunes) ?? true;
  bool get scraperSourceQQMusic =>
      _prefs.getBool(keyScraperSourceQQMusic) ?? true;
  bool get scraperArtistSourceMusicBrainz =>
      _prefs.getBool(keyScraperArtistSourceMusicBrainz) ?? true;
  bool get scraperArtistSourceItunes =>
      _prefs.getBool(keyScraperArtistSourceItunes) ?? true;
  bool get scraperArtistSourceQQMusic =>
      _prefs.getBool(keyScraperArtistSourceQQMusic) ?? true;
  bool get scraperLyricsEnabled =>
      _prefs.getBool(keyScraperLyricsEnabled) ?? true;
  bool get scraperLyricsSourceLrclib =>
      _prefs.getBool(keyScraperLyricsSourceLrclib) ?? true;
  bool get scraperLyricsSourceRangotec =>
      _prefs.getBool(keyScraperLyricsSourceRangotec) ?? true;
  bool get scraperLyricsSourceItunes =>
      _prefs.getBool(keyScraperLyricsSourceItunes) ?? true;
  bool get scraperLyricsSourceQQMusic =>
      _prefs.getBool(keyScraperLyricsSourceQQMusic) ?? true;

  bool get scraperAutoScrapeOnPlay =>
      _prefs.getBool(keyScraperAutoScrapeOnPlay) ?? false;

  // Audio playback
  bool getCrossfadeEnabled() => _prefs.getBool(keyCrossfadeEnabled) ?? false;
  int getCrossfadeDuration() => _prefs.getInt(keyCrossfadeDuration) ?? 3; // 默认3
  String get lyricsDisplayMode =>
      _prefs.getString(keyLyricsDisplayMode) ?? 'off';
  bool get shuffleEnabled => _prefs.getBool(keyShuffleEnabled) ?? false;
  String get loopMode => _prefs.getString(keyLoopMode) ?? 'off';
  double get desktopVolume => _prefs.getDouble(keyDesktopVolume) ?? 1.0;

  List<String> get lastQueueSongIds =>
      _prefs.getStringList(keyLastQueueSongIds) ?? [];
  int get lastQueueIndex => _prefs.getInt(keyLastQueueIndex) ?? 0;
  int get lastQueuePosition => _prefs.getInt(keyLastQueuePosition) ?? 0;

  Future<void> setProxyMode(String mode) async =>
      await _prefs.setString(keyProxyMode, mode);
  Future<void> setProxyHost(String host) async =>
      await _prefs.setString(keyProxyHost, host);
  Future<void> setProxyPort(int port) async =>
      await _prefs.setInt(keyProxyPort, port);
  Future<void> setOpenListPort(int port) async =>
      await _prefs.setInt(keyOpenListPort, port);
  Future<void> setOpenListProxyMode(String mode) async =>
      await _prefs.setString(keyOpenListProxyMode, mode);
  Future<void> setOpenListProxyHost(String host) async =>
      await _prefs.setString(keyOpenListProxyHost, host);
  Future<void> setOpenListProxyPort(int port) async =>
      await _prefs.setInt(keyOpenListProxyPort, port);
  Future<void> setOpenListAutoStart(bool autoStart) async =>
      await _prefs.setBool(keyOpenListAutoStart, autoStart);
  Future<void> setThemeMode(String mode) async =>
      await _prefs.setString(keyThemeMode, mode);
  Future<void> setLocale(String locale) async =>
      await _prefs.setString(keyLocale, locale);
  Future<void> setDefaultPageIndex(int index) async =>
      await _prefs.setInt(keyDefaultPageIndex, index);

  Future<void> setLastQueue(
      List<String> songIds, int index, int positionMs) async {
    await _prefs.setStringList(keyLastQueueSongIds, songIds);
    await _prefs.setInt(keyLastQueueIndex, index);
    await _prefs.setInt(keyLastQueuePosition, positionMs);
  }

  Future<void> setLastQueuePosition(int index, int positionMs) async {
    await _prefs.setInt(keyLastQueueIndex, index);
    await _prefs.setInt(keyLastQueuePosition, positionMs);
  }

  // WebDAV
  Future<void> setWebDavUrl(String url) async =>
      await _prefs.setString(keyWebDavUrl, url);
  Future<void> setWebDavUser(String user) async =>
      await _prefs.setString(keyWebDavUser, user);
  Future<void> setWebDavPassword(String password) async =>
      await _prefs.setString(keyWebDavPassword, password);
  Future<void> setWebDavPath(String path) async =>
      await _prefs.setString(keyWebDavPath, path);
  Future<void> setScraperUsePrimaryArtist(bool v) async =>
      await _prefs.setBool(keyScraperUsePrimaryArtist, v);
  Future<void> setScraperSourceMusicBrainz(bool v) async =>
      await _prefs.setBool(keyScraperSourceMusicBrainz, v);
  Future<void> setScraperSourceItunes(bool v) async =>
      await _prefs.setBool(keyScraperSourceItunes, v);
  Future<void> setScraperSourceQQMusic(bool v) async =>
      await _prefs.setBool(keyScraperSourceQQMusic, v);
  Future<void> setScraperArtistSourceMusicBrainz(bool v) async =>
      await _prefs.setBool(keyScraperArtistSourceMusicBrainz, v);
  Future<void> setScraperArtistSourceItunes(bool v) async =>
      await _prefs.setBool(keyScraperArtistSourceItunes, v);
  Future<void> setScraperArtistSourceQQMusic(bool v) async =>
      await _prefs.setBool(keyScraperArtistSourceQQMusic, v);
  Future<void> setScraperLyricsEnabled(bool v) async =>
      await _prefs.setBool(keyScraperLyricsEnabled, v);
  Future<void> setScraperLyricsSourceLrclib(bool v) async =>
      await _prefs.setBool(keyScraperLyricsSourceLrclib, v);
  Future<void> setScraperLyricsSourceRangotec(bool v) async =>
      await _prefs.setBool(keyScraperLyricsSourceRangotec, v);
  Future<void> setScraperLyricsSourceItunes(bool v) async =>
      await _prefs.setBool(keyScraperLyricsSourceItunes, v);
  Future<void> setScraperLyricsSourceQQMusic(bool v) async =>
      await _prefs.setBool(keyScraperLyricsSourceQQMusic, v);

  Future<void> setScraperAutoScrapeOnPlay(bool v) async =>
      await _prefs.setBool(keyScraperAutoScrapeOnPlay, v);

  // Audio playback
  Future<void> setCrossfadeEnabled(bool enabled) async =>
      await _prefs.setBool(keyCrossfadeEnabled, enabled);
  Future<void> setCrossfadeDuration(int seconds) async =>
      await _prefs.setInt(keyCrossfadeDuration, seconds);
  Future<void> setLyricsDisplayMode(String mode) async =>
      await _prefs.setString(keyLyricsDisplayMode, mode);
  Future<void> setShuffleEnabled(bool enabled) async =>
      await _prefs.setBool(keyShuffleEnabled, enabled);
  Future<void> setLoopMode(String mode) async =>
      await _prefs.setString(keyLoopMode, mode);
  Future<void> setDesktopVolume(double volume) async =>
      await _prefs.setDouble(keyDesktopVolume, volume);

  // Generic accessors for internal services
  String? getString(String key) => _prefs.getString(key);
  Future<void> setString(String key, String value) async =>
      await _prefs.setString(key, value);
  List<String> getStringList(String key) => _prefs.getStringList(key) ?? [];
  Future<void> setStringList(String key, List<String> value) async =>
      await _prefs.setStringList(key, value);
  Future<void> removeKey(String key) async => await _prefs.remove(key);

  String _scrapeBackupKey(int songId) => '$_keyScrapeBackupPrefix$songId';

  Map<String, dynamic>? getScrapeBackup(int songId) {
    final raw = _prefs.getString(_scrapeBackupKey(songId));
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> saveScrapeBackup(int songId, Map<String, dynamic> data) async {
    await _prefs.setString(_scrapeBackupKey(songId), jsonEncode(data));
  }

  Future<void> removeScrapeBackup(int songId) async {
    await _prefs.remove(_scrapeBackupKey(songId));
  }

  Future<void> removeScrapeBackups(Iterable<int> songIds) async {
    for (final id in songIds) {
      await removeScrapeBackup(id);
    }
  }
}
