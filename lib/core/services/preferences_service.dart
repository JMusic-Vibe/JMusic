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
  static const String keyThemeMode = 'theme_mode'; // 'system', 'light', 'dark'
  static const String keyLastQueueSongIds = 'last_queue_song_ids'; // List<String> of song IDs
  static const String keyLastQueueIndex = 'last_queue_index'; // int current index
  static const String keyLastQueuePosition = 'last_queue_position'; // int position in milliseconds
  static const String keyDefaultPageIndex = 'default_page_index'; // int default page index
  static const String keyLocale = 'locale'; // 'system', 'zh', 'zh_Hant', 'en'
  
  // WebDAV
  static const String keyWebDavUrl = 'webdav_url';
  static const String keyWebDavUser = 'webdav_user';
  static const String keyWebDavPassword = 'webdav_password';
  static const String keyWebDavPath = 'webdav_path';
  // Scraper
  static const String keyScraperUsePrimaryArtist = 'scraper_use_primary_artist';
  
  // Audio playback
  static const String keyCrossfadeEnabled = 'crossfade_enabled';
  static const String keyCrossfadeDuration = 'crossfade_duration'; // in seconds

  String get proxyMode => _prefs.getString(keyProxyMode) ?? 'system';
  String get proxyHost => _prefs.getString(keyProxyHost) ?? '127.0.0.1';
  int get proxyPort => _prefs.getInt(keyProxyPort) ?? 7890;
  String get themeMode => _prefs.getString(keyThemeMode) ?? 'system';
  String get locale => _prefs.getString(keyLocale) ?? 'system';
  int get defaultPageIndex => _prefs.getInt(keyDefaultPageIndex) ?? 0; // Default to Home (index 0)

  // WebDAV
  String get webDavUrl => _prefs.getString(keyWebDavUrl) ?? '';
  String get webDavUser => _prefs.getString(keyWebDavUser) ?? '';
  String get webDavPassword => _prefs.getString(keyWebDavPassword) ?? '';
  String get webDavPath => _prefs.getString(keyWebDavPath) ?? '';

  // Scraper
  bool get scraperUsePrimaryArtist => _prefs.getBool(keyScraperUsePrimaryArtist) ?? true;
  
  // Audio playback
  bool getCrossfadeEnabled() => _prefs.getBool(keyCrossfadeEnabled) ?? false;
  int getCrossfadeDuration() => _prefs.getInt(keyCrossfadeDuration) ?? 3; // 默认3

  List<String> get lastQueueSongIds => _prefs.getStringList(keyLastQueueSongIds) ?? [];
  int get lastQueueIndex => _prefs.getInt(keyLastQueueIndex) ?? 0;
  int get lastQueuePosition => _prefs.getInt(keyLastQueuePosition) ?? 0;

  Future<void> setProxyMode(String mode) async => await _prefs.setString(keyProxyMode, mode);
  Future<void> setProxyHost(String host) async => await _prefs.setString(keyProxyHost, host);
  Future<void> setProxyPort(int port) async => await _prefs.setInt(keyProxyPort, port);
  Future<void> setThemeMode(String mode) async => await _prefs.setString(keyThemeMode, mode);
  Future<void> setLocale(String locale) async => await _prefs.setString(keyLocale, locale);
  Future<void> setDefaultPageIndex(int index) async => await _prefs.setInt(keyDefaultPageIndex, index);

  Future<void> setLastQueue(List<String> songIds, int index, int positionMs) async {
    await _prefs.setStringList(keyLastQueueSongIds, songIds);
    await _prefs.setInt(keyLastQueueIndex, index);
    await _prefs.setInt(keyLastQueuePosition, positionMs);
  }

  Future<void> setLastQueuePosition(int index, int positionMs) async {
    await _prefs.setInt(keyLastQueueIndex, index);
    await _prefs.setInt(keyLastQueuePosition, positionMs);
  }

  // WebDAV
  Future<void> setWebDavUrl(String url) async => await _prefs.setString(keyWebDavUrl, url);
  Future<void> setWebDavUser(String user) async => await _prefs.setString(keyWebDavUser, user);
  Future<void> setWebDavPassword(String password) async => await _prefs.setString(keyWebDavPassword, password);
  Future<void> setWebDavPath(String path) async => await _prefs.setString(keyWebDavPath, path);
  Future<void> setScraperUsePrimaryArtist(bool v) async => await _prefs.setBool(keyScraperUsePrimaryArtist, v);
  
  // Audio playback
  Future<void> setCrossfadeEnabled(bool enabled) async => await _prefs.setBool(keyCrossfadeEnabled, enabled);
  Future<void> setCrossfadeDuration(int seconds) async => await _prefs.setInt(keyCrossfadeDuration, seconds);
}

