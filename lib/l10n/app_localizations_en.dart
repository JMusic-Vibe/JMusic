// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'JMusic';

  @override
  String get home => 'Home';

  @override
  String get library => 'Library';

  @override
  String get playlists => 'Playlists';

  @override
  String get playlistRecommendations => 'Playlist Picks';

  @override
  String get more => 'More';

  @override
  String get playVideo => 'Play Video';

  @override
  String get restoreOriginalInfo => 'Restore Original Info';

  @override
  String restoreOriginalInfoConfirm(Object count) {
    return 'Restore original info for $count item(s)?';
  }

  @override
  String restoreOriginalInfoSuccess(Object count) {
    return 'Restored $count item(s)';
  }

  @override
  String get restoreOriginalInfoFailed => 'No original info to restore';

  @override
  String get batchRestore => 'Batch Restore';

  @override
  String get sync => 'Sync';

  @override
  String get scraper => 'Scraper';

  @override
  String get settings => 'Settings';

  @override
  String get clear => 'Clear';

  @override
  String get playingQueue => 'Playing Queue';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get storageEvents => 'Storage & Cache';

  @override
  String get coverCache => 'Cover Cache';

  @override
  String get clearCoverCacheConfirm => 'Clear cover cache?';

  @override
  String get coverCacheCleared => 'Cover cache cleared';

  @override
  String get artistAvatarCache => 'Artist Avatar Cache';

  @override
  String get clearArtistAvatarCacheConfirm => 'Clear artist avatar cache?';

  @override
  String get artistAvatarCacheCleared => 'Artist avatar cache cleared';

  @override
  String get embeddedCoverCache => 'Embedded Cover Cache';

  @override
  String get clearEmbeddedCoverCacheConfirm => 'Clear embedded cover cache?';

  @override
  String get embeddedCoverCacheCleared => 'Embedded cover cache cleared';

  @override
  String get appDataSize => 'App Data Size';

  @override
  String get logExport => 'Export Logs';

  @override
  String get logFileSize => 'Log Size';

  @override
  String get logExported => 'Logs exported';

  @override
  String get clearLogs => 'Clear Logs';

  @override
  String get clearLogsConfirm => 'Clear logs?';

  @override
  String get logsCleared => 'Logs cleared';

  @override
  String get scrapeCompleteWithLyrics =>
      'Scrape complete: album info updated, lyrics found';

  @override
  String get scrapeCompleteNoLyrics =>
      'Scrape complete: album info updated, lyrics not found';

  @override
  String get artistNameLabel => 'Artist Name';

  @override
  String get syncSettings => 'Sync Settings';

  @override
  String get serverSettings => 'Server Settings';

  @override
  String get defaultPage => 'Default Page';

  @override
  String get scraperSettings => 'Scraper Settings';

  @override
  String get usePrimaryArtistForScraper => 'Use primary artist for scraping';

  @override
  String get usePrimaryArtistForScraperDesc =>
      'When enabled, the scraper will query using the primary artist only; otherwise it will include featured and collaborating artists.';

  @override
  String get scraperMatchSources => 'Match Sources';

  @override
  String get scraperSourceAtLeastOne => 'Please enable at least one source';

  @override
  String get scraperSongSources => 'Song scraping sources';

  @override
  String get scraperArtistSources => 'Artist scraping sources';

  @override
  String get scraperLyricsSources => 'Lyrics scraping sources';

  @override
  String get audioSettings => 'Audio & Playback';

  @override
  String get playbackSettings => 'Playback Settings';

  @override
  String get desktopVolume => 'Desktop Volume';

  @override
  String get crossfadeEnabled => 'Enable Crossfade';

  @override
  String get crossfadeEnabledDesc =>
      'Enable crossfade effect when switching songs for a smoother listening experience';

  @override
  String get crossfadeDuration => 'Crossfade Duration';

  @override
  String get crossfadeDurationDesc =>
      'Set the duration of the crossfade effect between songs';

  @override
  String get mute => 'Mute';

  @override
  String get unmute => 'Unmute';

  @override
  String get loopingOn => 'Looping: On';

  @override
  String get loopingOff => 'Looping: Off';

  @override
  String get scraperSourceLrclib => 'lrclib';

  @override
  String get scraperSourceRangotec => 'rangotec';

  @override
  String get scraperLyricsSourcesFixed =>
      'Lyrics sources are fixed to lrclib + rangotec';

  @override
  String seconds(Object count) {
    return '$count seconds';
  }

  @override
  String get crossfadeEnabledInfo =>
      'Crossfade enabled, songs will transition smoothly';

  @override
  String get crossfadeDisabledInfo =>
      'Crossfade disabled, songs will switch directly';

  @override
  String get proxySettings => 'Network Proxy';

  @override
  String get about => 'About';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get systemProxy => 'System Proxy';

  @override
  String get noProxy => 'No Proxy';

  @override
  String get customProxy => 'Custom Proxy';

  @override
  String get port => 'Port';

  @override
  String get ipAddress => 'Ip Address';

  @override
  String get save => 'Save';

  @override
  String get recentlyPlayed => 'Recently Played';

  @override
  String get recentlyImported => 'Recently Added';

  @override
  String get toBeScraped => 'Missing Metadata';

  @override
  String get noData => 'No music found. Please import.';

  @override
  String get scanMusic => 'Scan Music';

  @override
  String get batchScrape => 'Batch Scrape';

  @override
  String get batchScrapeRunning => 'Scraping in background...';

  @override
  String get batchScrapeResult => 'Scrape Report';

  @override
  String successCount(Object count) {
    return 'Success: $count';
  }

  @override
  String failCount(Object count) {
    return 'Fail: $count';
  }

  @override
  String get confirm => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get editTags => 'Edit Tags';

  @override
  String get addToPlaylist => 'Add to Playlist';

  @override
  String get playAll => 'Play All';

  @override
  String get play => 'Play';

  @override
  String deleteConfirm(Object count) {
    return 'Delete $count selected songs?';
  }

  @override
  String deleteSingleConfirm(Object title) {
    return 'Delete \"$title\"?';
  }

  @override
  String get importMusic => 'Import Music';

  @override
  String get manualSync => 'Sync Now';

  @override
  String get developing => 'Coming Soon';

  @override
  String get importInLibrary => 'Go to Library to import';

  @override
  String get homeTitle => 'Home';

  @override
  String get importMusicTooltip => 'Import Music';

  @override
  String get syncFeatureDeveloping => 'Sync feature is under development';

  @override
  String get noMusicData =>
      'No data available\nPlease import music in Library first';

  @override
  String get scrapedCompletedTitle => 'Batch Scrape Completed';

  @override
  String totalTasks(Object count) {
    return 'Total Tasks: $count';
  }

  @override
  String get hide => 'Hide';

  @override
  String get createPlaylist => 'New Playlist';

  @override
  String get noPlaylists => 'No Playlists';

  @override
  String get playlistTitle => 'Playlists';

  @override
  String get confirmDelete => 'Delete?';

  @override
  String get edit => 'Edit';

  @override
  String get playlistName => 'Playlist Name';

  @override
  String get playlistNameHint => 'My Favorites';

  @override
  String get create => 'Create';

  @override
  String songCount(Object count) {
    return '$count songs';
  }

  @override
  String addedToPlaylist(Object name) {
    return 'Added to \"$name\"';
  }

  @override
  String songsAlreadyInPlaylist(Object playlistName) {
    return 'Songs already exist in \"$playlistName\"';
  }

  @override
  String toBeScrapedSubtitle(Object count) {
    return '$count songs missing metadata';
  }

  @override
  String get defaultPageDescription =>
      'Select the default page to show when the app starts';

  @override
  String get syncCenter => 'Sync Center';

  @override
  String get addSyncAccount => 'Add Sync Account';

  @override
  String get openListNotSupported => 'OpenList not supported yet';

  @override
  String get noSyncAccount => 'No Sync Accounts';

  @override
  String get addSyncAccountHint =>
      'Tap + at top right to add WebDAV or Alist account';

  @override
  String get connected => 'Connected';

  @override
  String get paused => 'Paused';

  @override
  String get accountName => 'Account Name';

  @override
  String get removeSyncConfigConfirm =>
      'This will remove this sync configuration';

  @override
  String get checkSyncNow => 'Sync';

  @override
  String get searchUnarchived => 'Search unarchived songs...';

  @override
  String selectedCount(Object count) {
    return '$count selected';
  }

  @override
  String get scraperCenter => 'Scraper Center';

  @override
  String get scraperCategoryAll => 'All Issues';

  @override
  String get scraperCategoryUnscraped => 'Not Scraped';

  @override
  String get scraperCategoryScraped => 'Scraped';

  @override
  String get scraperCategoryHasLyrics => 'Has Lyrics';

  @override
  String get scraperCategoryNoLyrics => 'No Lyrics';

  @override
  String get scraperCategoryMissingCover => 'Missing Cover';

  @override
  String get scraperCategoryMissingInfo => 'Missing Basic Info';

  @override
  String get scraperCategoryArtists => 'Artists';

  @override
  String get scraperSourceMusicBrainz => 'MusicBrainz';

  @override
  String get scraperSourceItunes => 'iTunes';

  @override
  String scraperSourceLabel(Object source) {
    return 'Source: $source';
  }

  @override
  String get viewOriginalInfo => 'View Original Info';

  @override
  String get clearLyrics => 'Clear Lyrics';

  @override
  String get clearSongInfo => 'Clear Song Info';

  @override
  String get restoreArtistAvatar => 'Restore Artist Avatar';

  @override
  String get refresh => 'Refresh';

  @override
  String get taskRunningBackground => 'Task running in background';

  @override
  String get unknownArtist => 'Unknown Artist';

  @override
  String get unknownAlbum => 'Unknown Album';

  @override
  String get nowPlaying => 'Now Playing';

  @override
  String get manualMatchMetadata => 'Manual Match Metadata';

  @override
  String get songTitleLabel => 'Song Title';

  @override
  String get artistLabel => 'Artist';

  @override
  String get albumLabel => 'Album';

  @override
  String get searchToSeeResults => 'Search to view results';

  @override
  String lyricsDuration(Object duration) {
    return 'Lyrics duration: $duration';
  }

  @override
  String get manualMatchLyrics => 'Manual Match Lyrics';

  @override
  String get lyricsComingSoon => 'Lyrics coming soon...';

  @override
  String get lyricsModeOff => 'Lyrics: Off';

  @override
  String get lyricsModeCompact => 'Lyrics: Under cover';

  @override
  String get lyricsModeFull => 'Lyrics: Full screen';

  @override
  String get noLyricsFound => 'No lyrics found';

  @override
  String get syncCenterSubtitle => 'Manual sync & Diff check';

  @override
  String get scraperCenterSubtitle => 'Manual scrape & Candidate confirm';

  @override
  String get settingsSubtitle => 'Storage, Audio, Sync & Scraper Strategy';

  @override
  String get deletePlaylist => 'Delete Playlist';

  @override
  String confirmDeletePlaylist(Object name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get clearPlaylist => 'Clear Playlist';

  @override
  String confirmClearPlaylist(Object name) {
    return 'Are you sure you want to clear all songs from \"$name\"?';
  }

  @override
  String get rename => 'Rename';

  @override
  String get importCover => 'Import Cover';

  @override
  String get coverImported => 'Cover imported';

  @override
  String get clearCover => 'Clear Cover';

  @override
  String confirmClearCover(Object name) {
    return 'Are you sure you want to clear the cover for \"$name\"?';
  }

  @override
  String get emptyPlaylist => 'Playlist is empty';

  @override
  String playbackError(Object error) {
    return 'Could not start playback: $error';
  }

  @override
  String get selectAll => 'Select All / Deselect All';

  @override
  String get search => 'Search';

  @override
  String get noMatchingSongs => 'No matching songs found';

  @override
  String get allSongsScraped => 'Congratulations, all songs scraped!';

  @override
  String foundUnscrapedSongs(Object count) {
    return 'Found $count unscraped songs';
  }

  @override
  String get deleteSongs => 'Delete Songs';

  @override
  String confirmDeleteSongs(Object count) {
    return 'Delete $count selected songs?\n(Only removes from library, files are kept)';
  }

  @override
  String songsDeleted(Object count) {
    return 'Deleted $count songs';
  }

  @override
  String addedToQueue(Object count) {
    return 'Added $count songs to queue';
  }

  @override
  String get pleaseSelectDetailed => 'Please select songs to scrape first';

  @override
  String get batchScrapeStarted => 'Batch scrape task started';

  @override
  String get scrapeLyrics => 'Scrape Lyrics';

  @override
  String get scrapeLyricsStarted => 'Lyrics scrape started';

  @override
  String get scanning => 'Scanning...';

  @override
  String addedCompSongs(Object count) {
    return 'Added $count songs';
  }

  @override
  String get processingFiles => 'Processing dropped files...';

  @override
  String importedSongs(Object count) {
    return 'Imported $count songs';
  }

  @override
  String get addFolder => 'Add Folder';

  @override
  String get emptyLibrary => 'Library is empty';

  @override
  String get addMusicFolder => 'Add Music Folder';

  @override
  String get unknown => 'Unknown';

  @override
  String get noItemsFound => 'No items found';

  @override
  String searchViewType(Object viewType) {
    return 'Search $viewType...';
  }

  @override
  String get forYou => 'For You';

  @override
  String get viewDetails => 'View Details';

  @override
  String get songDetails => 'Song Details';

  @override
  String get filePath => 'File Path';

  @override
  String get fileName => 'File Name';

  @override
  String get duration => 'Duration';

  @override
  String get size => 'Size';

  @override
  String get dateAdded => 'Date Added';

  @override
  String get lastPlayed => 'Last Played';

  @override
  String get genre => 'Genre';

  @override
  String get year => 'Year';

  @override
  String get trackNumber => 'Track Number';

  @override
  String get discNumber => 'Disc Number';

  @override
  String get lyrics => 'Lyrics';

  @override
  String get copyToClipboard => 'Copy to Clipboard';

  @override
  String get fullPath => 'Full Path';

  @override
  String get webdav => 'WebDAV';

  @override
  String get openlist => 'OpenList';

  @override
  String get webdavConfigTitle => 'WebDAV Configuration';

  @override
  String get webdavUrlLabel => 'WebDAV URL (e.g. https://dav.example.com)';

  @override
  String get keepAliveTitle => 'Keepalive';

  @override
  String get keepAliveDescription =>
      'If connection drops when the screen sleeps, allow auto-start in system settings.';

  @override
  String get openAutoStart => 'Open auto-start settings';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get musicFolderPath => 'Music Folder Path (e.g. /Music)';

  @override
  String get identify => 'Identify';

  @override
  String get identificationRules => 'Identification Rules';

  @override
  String get rulesTooltip => 'Rules: Artist/Album/Song or Filename';

  @override
  String scanComplete(Object count) {
    return 'Scan complete. Identified $count songs.';
  }

  @override
  String scanError(Object error) {
    return 'Error: $error';
  }

  @override
  String get permissionDenied => 'Storage permission denied';

  @override
  String scanningFile(Object fileName) {
    return 'Scanning: $fileName';
  }

  @override
  String get sourceLocal => 'Local';

  @override
  String get sourceCloud => 'Cloud';

  @override
  String get webdavAccountsCache => 'WebDAV Accounts Cache';

  @override
  String clearCacheForAccount(Object accountName) {
    return 'Clear cache for $accountName?';
  }

  @override
  String get accountCacheCleared => 'Account cache cleared';

  @override
  String get clearLegacyCache => 'Clear all legacy cached WebDAV songs?';

  @override
  String get legacyCacheCleared => 'Legacy cache cleared';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get scrapeAgain => 'Scrape Again';

  @override
  String get scrapeArtistAvatars => 'Scrape Artist Avatars';

  @override
  String get manualMatchArtist => 'Manual Match Artist';

  @override
  String get batchScrapeArtists => 'Batch Scrape Artists';

  @override
  String scrapeArtistAvatarsResult(Object count) {
    return 'Updated $count artist avatars';
  }

  @override
  String songDeletedWithTitle(Object title) {
    return 'Deleted \"$title\"';
  }

  @override
  String cacheClearedWithTitle(Object title) {
    return 'Cleared cache for \"$title\"';
  }

  @override
  String cannotAccessSong(Object title) {
    return 'Cannot access song file: $title';
  }

  @override
  String get addedToFavorites => 'Added to Favorites';

  @override
  String get removedFromFavorites => 'Removed from Favorites';

  @override
  String get favoritesPlaylistName => 'Favorites';

  @override
  String get favoritesPlaylistDescription => 'My favorite songs';

  @override
  String playlistAlreadyExists(Object playlistName) {
    return 'A playlist named \"$playlistName\" already exists';
  }

  @override
  String get resetAdminPasswordTitle => 'Reset Admin Password';

  @override
  String get resetFailed => 'Reset Failed';

  @override
  String get unknownError => 'Unknown Error';

  @override
  String get newPasswordGenerated => 'New Password Generated';

  @override
  String get usernameAdmin => 'Username: admin';

  @override
  String newPassword(Object pwd) {
    return 'New Password: $pwd';
  }

  @override
  String get portAndProxy => 'Port & Proxy';

  @override
  String get invalidPort => 'Invalid Port';

  @override
  String get proxyHostEmpty => 'Proxy Host Cannot Be Empty';

  @override
  String get invalidProxyPort => 'Invalid Proxy Port';

  @override
  String get savedRestartRequired => 'Saved, restart required to take effect';

  @override
  String get openListService => 'OpenList Service';

  @override
  String get statusRunning => 'Status: Running';

  @override
  String get statusStopped => 'Status: Stopped';

  @override
  String address(Object address, Object port) {
    return 'Address: http://$address:$port';
  }

  @override
  String get stop => 'Stop';

  @override
  String get start => 'Start';

  @override
  String get managementPage => 'Management Page';

  @override
  String get accessManagementPage => 'Access OpenList Management Page:';

  @override
  String get startServiceFirst => 'Please start the OpenList service first';

  @override
  String get openInApp => 'Open in App';

  @override
  String get openInBrowser => 'Open in Browser';

  @override
  String get adminInfo => 'Admin Information';

  @override
  String saveCredentials(Object password) {
    return 'Please save:\nUsername: admin\nInitial Password: $password';
  }

  @override
  String get saved => 'Saved';

  @override
  String get defaultUsernameAdmin => 'Default Username: admin';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get stopServiceToModify => 'Stop the service to modify';

  @override
  String get serviceRunningLocked => 'Service is running, locked';

  @override
  String get stopServiceExitHint =>
      'Stop OpenList manually before exiting the app so the service can be stopped';

  @override
  String get saveFailed => 'Save Failed';

  @override
  String get openListManagement => 'OpenList Management';

  @override
  String get autoStartOpenListOnAppLaunch => 'Auto-start OpenList';

  @override
  String get autoStartOpenListDescription =>
      'When enabled, the app will automatically start the OpenList service on launch';
}
