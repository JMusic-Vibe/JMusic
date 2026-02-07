import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
  ];

  /// No description provided for @appName.
  ///
  /// In zh, this message translates to:
  /// **'JMusic'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get home;

  /// No description provided for @library.
  ///
  /// In zh, this message translates to:
  /// **'音乐库'**
  String get library;

  /// No description provided for @playlists.
  ///
  /// In zh, this message translates to:
  /// **'歌单'**
  String get playlists;

  /// No description provided for @playlistRecommendations.
  ///
  /// In zh, this message translates to:
  /// **'播放列表推荐'**
  String get playlistRecommendations;

  /// No description provided for @more.
  ///
  /// In zh, this message translates to:
  /// **'更多'**
  String get more;

  /// No description provided for @playVideo.
  ///
  /// In zh, this message translates to:
  /// **'播放视频'**
  String get playVideo;

  /// No description provided for @restoreOriginalInfo.
  ///
  /// In zh, this message translates to:
  /// **'恢复原始信息'**
  String get restoreOriginalInfo;

  /// No description provided for @restoreOriginalInfoConfirm.
  ///
  /// In zh, this message translates to:
  /// **'是否恢复 {count} 首的原始信息？'**
  String restoreOriginalInfoConfirm(Object count);

  /// No description provided for @restoreOriginalInfoSuccess.
  ///
  /// In zh, this message translates to:
  /// **'已恢复 {count} 首'**
  String restoreOriginalInfoSuccess(Object count);

  /// No description provided for @restoreOriginalInfoFailed.
  ///
  /// In zh, this message translates to:
  /// **'没有可恢复的原始信息'**
  String get restoreOriginalInfoFailed;

  /// No description provided for @batchRestore.
  ///
  /// In zh, this message translates to:
  /// **'批量恢复'**
  String get batchRestore;

  /// No description provided for @sync.
  ///
  /// In zh, this message translates to:
  /// **'同步'**
  String get sync;

  /// No description provided for @scraper.
  ///
  /// In zh, this message translates to:
  /// **'刮削'**
  String get scraper;

  /// No description provided for @settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// No description provided for @clear.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get clear;

  /// No description provided for @playingQueue.
  ///
  /// In zh, this message translates to:
  /// **'播放队列'**
  String get playingQueue;

  /// No description provided for @language.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In zh, this message translates to:
  /// **'主题'**
  String get theme;

  /// No description provided for @storageEvents.
  ///
  /// In zh, this message translates to:
  /// **'存储与缓存'**
  String get storageEvents;

  /// No description provided for @coverCache.
  ///
  /// In zh, this message translates to:
  /// **'封面缓存'**
  String get coverCache;

  /// No description provided for @clearCoverCacheConfirm.
  ///
  /// In zh, this message translates to:
  /// **'清除封面缓存？'**
  String get clearCoverCacheConfirm;

  /// No description provided for @coverCacheCleared.
  ///
  /// In zh, this message translates to:
  /// **'封面缓存已清除'**
  String get coverCacheCleared;

  /// No description provided for @artistAvatarCache.
  ///
  /// In zh, this message translates to:
  /// **'歌手头像缓存'**
  String get artistAvatarCache;

  /// No description provided for @clearArtistAvatarCacheConfirm.
  ///
  /// In zh, this message translates to:
  /// **'清除歌手头像缓存？'**
  String get clearArtistAvatarCacheConfirm;

  /// No description provided for @artistAvatarCacheCleared.
  ///
  /// In zh, this message translates to:
  /// **'歌手头像缓存已清除'**
  String get artistAvatarCacheCleared;

  /// No description provided for @embeddedCoverCache.
  ///
  /// In zh, this message translates to:
  /// **'内嵌封面缓存'**
  String get embeddedCoverCache;

  /// No description provided for @clearEmbeddedCoverCacheConfirm.
  ///
  /// In zh, this message translates to:
  /// **'清除内嵌封面缓存？'**
  String get clearEmbeddedCoverCacheConfirm;

  /// No description provided for @embeddedCoverCacheCleared.
  ///
  /// In zh, this message translates to:
  /// **'内嵌封面缓存已清除'**
  String get embeddedCoverCacheCleared;

  /// No description provided for @appDataSize.
  ///
  /// In zh, this message translates to:
  /// **'应用数据占用'**
  String get appDataSize;

  /// No description provided for @logExport.
  ///
  /// In zh, this message translates to:
  /// **'导出日志'**
  String get logExport;

  /// No description provided for @logFileSize.
  ///
  /// In zh, this message translates to:
  /// **'日志大小'**
  String get logFileSize;

  /// No description provided for @logExported.
  ///
  /// In zh, this message translates to:
  /// **'日志已导出'**
  String get logExported;

  /// No description provided for @clearLogs.
  ///
  /// In zh, this message translates to:
  /// **'清空日志'**
  String get clearLogs;

  /// No description provided for @clearLogsConfirm.
  ///
  /// In zh, this message translates to:
  /// **'清空日志？'**
  String get clearLogsConfirm;

  /// No description provided for @logsCleared.
  ///
  /// In zh, this message translates to:
  /// **'日志已清空'**
  String get logsCleared;

  /// No description provided for @scrapeCompleteWithLyrics.
  ///
  /// In zh, this message translates to:
  /// **'刮削完成：专辑信息已更新，歌词已找到'**
  String get scrapeCompleteWithLyrics;

  /// No description provided for @scrapeCompleteNoLyrics.
  ///
  /// In zh, this message translates to:
  /// **'刮削完成：专辑信息已更新，未找到歌词'**
  String get scrapeCompleteNoLyrics;

  /// No description provided for @artistNameLabel.
  ///
  /// In zh, this message translates to:
  /// **'歌手名称'**
  String get artistNameLabel;

  /// No description provided for @syncSettings.
  ///
  /// In zh, this message translates to:
  /// **'同步设置'**
  String get syncSettings;

  /// No description provided for @serverSettings.
  ///
  /// In zh, this message translates to:
  /// **'服务器设置'**
  String get serverSettings;

  /// No description provided for @defaultPage.
  ///
  /// In zh, this message translates to:
  /// **'默认启动页'**
  String get defaultPage;

  /// No description provided for @scraperSettings.
  ///
  /// In zh, this message translates to:
  /// **'刮削设置'**
  String get scraperSettings;

  /// No description provided for @usePrimaryArtistForScraper.
  ///
  /// In zh, this message translates to:
  /// **'刮削仅使用主歌手'**
  String get usePrimaryArtistForScraper;

  /// No description provided for @usePrimaryArtistForScraperDesc.
  ///
  /// In zh, this message translates to:
  /// **'启用后，刮削将仅使用主歌手进行查询；禁用时会包含客座/合作歌手。'**
  String get usePrimaryArtistForScraperDesc;

  /// No description provided for @scraperMatchSources.
  ///
  /// In zh, this message translates to:
  /// **'匹配来源'**
  String get scraperMatchSources;

  /// No description provided for @scraperSourceAtLeastOne.
  ///
  /// In zh, this message translates to:
  /// **'请至少启用一个来源'**
  String get scraperSourceAtLeastOne;

  /// No description provided for @scraperSongSources.
  ///
  /// In zh, this message translates to:
  /// **'歌曲刮削源'**
  String get scraperSongSources;

  /// No description provided for @scraperArtistSources.
  ///
  /// In zh, this message translates to:
  /// **'歌手刮削源'**
  String get scraperArtistSources;

  /// No description provided for @scraperLyricsSources.
  ///
  /// In zh, this message translates to:
  /// **'歌词刮削源'**
  String get scraperLyricsSources;

  /// No description provided for @audioSettings.
  ///
  /// In zh, this message translates to:
  /// **'音频与播放'**
  String get audioSettings;

  /// No description provided for @playbackSettings.
  ///
  /// In zh, this message translates to:
  /// **'播放设置'**
  String get playbackSettings;

  /// No description provided for @desktopVolume.
  ///
  /// In zh, this message translates to:
  /// **'桌面端音量'**
  String get desktopVolume;

  /// No description provided for @crossfadeEnabled.
  ///
  /// In zh, this message translates to:
  /// **'启用淡入淡出'**
  String get crossfadeEnabled;

  /// No description provided for @crossfadeEnabledDesc.
  ///
  /// In zh, this message translates to:
  /// **'歌曲切换时启用淡入淡出效果，提供更流畅的听觉体验'**
  String get crossfadeEnabledDesc;

  /// No description provided for @crossfadeDuration.
  ///
  /// In zh, this message translates to:
  /// **'淡入淡出时长'**
  String get crossfadeDuration;

  /// No description provided for @crossfadeDurationDesc.
  ///
  /// In zh, this message translates to:
  /// **'设置歌曲间淡入淡出效果的持续时间'**
  String get crossfadeDurationDesc;

  /// No description provided for @mute.
  ///
  /// In zh, this message translates to:
  /// **'静音'**
  String get mute;

  /// No description provided for @unmute.
  ///
  /// In zh, this message translates to:
  /// **'取消静音'**
  String get unmute;

  /// No description provided for @loopingOn.
  ///
  /// In zh, this message translates to:
  /// **'循环：开'**
  String get loopingOn;

  /// No description provided for @loopingOff.
  ///
  /// In zh, this message translates to:
  /// **'循环：关'**
  String get loopingOff;

  /// No description provided for @scraperSourceLrclib.
  ///
  /// In zh, this message translates to:
  /// **'lrclib'**
  String get scraperSourceLrclib;

  /// No description provided for @scraperSourceRangotec.
  ///
  /// In zh, this message translates to:
  /// **'rangotec'**
  String get scraperSourceRangotec;

  /// No description provided for @scraperLyricsSourcesFixed.
  ///
  /// In zh, this message translates to:
  /// **'歌词刮削源固定为 lrclib + rangotec'**
  String get scraperLyricsSourcesFixed;

  /// No description provided for @seconds.
  ///
  /// In zh, this message translates to:
  /// **'{count} 秒'**
  String seconds(Object count);

  /// No description provided for @crossfadeEnabledInfo.
  ///
  /// In zh, this message translates to:
  /// **'已启用淡入淡出,歌曲将平滑过渡'**
  String get crossfadeEnabledInfo;

  /// No description provided for @crossfadeDisabledInfo.
  ///
  /// In zh, this message translates to:
  /// **'淡入淡出已禁用,歌曲将直接切换'**
  String get crossfadeDisabledInfo;

  /// No description provided for @proxySettings.
  ///
  /// In zh, this message translates to:
  /// **'网络代理'**
  String get proxySettings;

  /// No description provided for @about.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get about;

  /// No description provided for @themeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get themeSystem;

  /// No description provided for @systemProxy.
  ///
  /// In zh, this message translates to:
  /// **'系统代理'**
  String get systemProxy;

  /// No description provided for @noProxy.
  ///
  /// In zh, this message translates to:
  /// **'无代理'**
  String get noProxy;

  /// No description provided for @customProxy.
  ///
  /// In zh, this message translates to:
  /// **'自定义代理'**
  String get customProxy;

  /// No description provided for @port.
  ///
  /// In zh, this message translates to:
  /// **'端口'**
  String get port;

  /// No description provided for @ipAddress.
  ///
  /// In zh, this message translates to:
  /// **'IP地址'**
  String get ipAddress;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @recentlyPlayed.
  ///
  /// In zh, this message translates to:
  /// **'最近播放'**
  String get recentlyPlayed;

  /// No description provided for @recentlyImported.
  ///
  /// In zh, this message translates to:
  /// **'最近导入'**
  String get recentlyImported;

  /// No description provided for @toBeScraped.
  ///
  /// In zh, this message translates to:
  /// **'待刮削处理'**
  String get toBeScraped;

  /// No description provided for @noData.
  ///
  /// In zh, this message translates to:
  /// **'暂无数据，请先导入'**
  String get noData;

  /// No description provided for @scanMusic.
  ///
  /// In zh, this message translates to:
  /// **'扫描音乐'**
  String get scanMusic;

  /// No description provided for @batchScrape.
  ///
  /// In zh, this message translates to:
  /// **'批量刮削'**
  String get batchScrape;

  /// No description provided for @batchScrapeRunning.
  ///
  /// In zh, this message translates to:
  /// **'后台刮削中...'**
  String get batchScrapeRunning;

  /// No description provided for @batchScrapeResult.
  ///
  /// In zh, this message translates to:
  /// **'刮削报告'**
  String get batchScrapeResult;

  /// No description provided for @successCount.
  ///
  /// In zh, this message translates to:
  /// **'成功: {count}'**
  String successCount(Object count);

  /// No description provided for @failCount.
  ///
  /// In zh, this message translates to:
  /// **'失败: {count}'**
  String failCount(Object count);

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @editTags.
  ///
  /// In zh, this message translates to:
  /// **'编辑标签'**
  String get editTags;

  /// No description provided for @addToPlaylist.
  ///
  /// In zh, this message translates to:
  /// **'添加到歌单'**
  String get addToPlaylist;

  /// No description provided for @playAll.
  ///
  /// In zh, this message translates to:
  /// **'播放全部'**
  String get playAll;

  /// No description provided for @play.
  ///
  /// In zh, this message translates to:
  /// **'播放'**
  String get play;

  /// No description provided for @deleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定删除选中的 {count} 首歌曲吗？'**
  String deleteConfirm(Object count);

  /// No description provided for @deleteSingleConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定删除 \"{title}\" 吗？'**
  String deleteSingleConfirm(Object title);

  /// No description provided for @importMusic.
  ///
  /// In zh, this message translates to:
  /// **'导入音乐'**
  String get importMusic;

  /// No description provided for @manualSync.
  ///
  /// In zh, this message translates to:
  /// **'手动同步'**
  String get manualSync;

  /// No description provided for @developing.
  ///
  /// In zh, this message translates to:
  /// **'功能开发中'**
  String get developing;

  /// No description provided for @importInLibrary.
  ///
  /// In zh, this message translates to:
  /// **'请前往资料库导入'**
  String get importInLibrary;

  /// No description provided for @homeTitle.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get homeTitle;

  /// No description provided for @importMusicTooltip.
  ///
  /// In zh, this message translates to:
  /// **'导入音乐'**
  String get importMusicTooltip;

  /// No description provided for @syncFeatureDeveloping.
  ///
  /// In zh, this message translates to:
  /// **'同步功能开发中'**
  String get syncFeatureDeveloping;

  /// No description provided for @noMusicData.
  ///
  /// In zh, this message translates to:
  /// **'暂无数据\n请先前往资料库导入音乐'**
  String get noMusicData;

  /// No description provided for @scrapedCompletedTitle.
  ///
  /// In zh, this message translates to:
  /// **'批量刮削完成'**
  String get scrapedCompletedTitle;

  /// No description provided for @totalTasks.
  ///
  /// In zh, this message translates to:
  /// **'总计任务: {count}'**
  String totalTasks(Object count);

  /// No description provided for @hide.
  ///
  /// In zh, this message translates to:
  /// **'隐藏'**
  String get hide;

  /// No description provided for @createPlaylist.
  ///
  /// In zh, this message translates to:
  /// **'新建歌单'**
  String get createPlaylist;

  /// No description provided for @noPlaylists.
  ///
  /// In zh, this message translates to:
  /// **'暂无歌单'**
  String get noPlaylists;

  /// No description provided for @playlistTitle.
  ///
  /// In zh, this message translates to:
  /// **'歌单'**
  String get playlistTitle;

  /// No description provided for @confirmDelete.
  ///
  /// In zh, this message translates to:
  /// **'确认删除?'**
  String get confirmDelete;

  /// No description provided for @edit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get edit;

  /// No description provided for @playlistName.
  ///
  /// In zh, this message translates to:
  /// **'歌单名称'**
  String get playlistName;

  /// No description provided for @playlistNameHint.
  ///
  /// In zh, this message translates to:
  /// **'我的最爱'**
  String get playlistNameHint;

  /// No description provided for @create.
  ///
  /// In zh, this message translates to:
  /// **'创建'**
  String get create;

  /// No description provided for @songCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 首歌曲'**
  String songCount(Object count);

  /// No description provided for @addedToPlaylist.
  ///
  /// In zh, this message translates to:
  /// **'已添加到 \"{name}\"'**
  String addedToPlaylist(Object name);

  /// No description provided for @songsAlreadyInPlaylist.
  ///
  /// In zh, this message translates to:
  /// **'已存在于 \"{playlistName}\"'**
  String songsAlreadyInPlaylist(Object playlistName);

  /// No description provided for @toBeScrapedSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'{count} 首歌曲元数据不全'**
  String toBeScrapedSubtitle(Object count);

  /// No description provided for @defaultPageDescription.
  ///
  /// In zh, this message translates to:
  /// **'选择应用启动时显示的默认页面'**
  String get defaultPageDescription;

  /// No description provided for @syncCenter.
  ///
  /// In zh, this message translates to:
  /// **'同步中心'**
  String get syncCenter;

  /// No description provided for @addSyncAccount.
  ///
  /// In zh, this message translates to:
  /// **'新增同步账号'**
  String get addSyncAccount;

  /// No description provided for @openListNotSupported.
  ///
  /// In zh, this message translates to:
  /// **'OpenList 暂未支持'**
  String get openListNotSupported;

  /// No description provided for @noSyncAccount.
  ///
  /// In zh, this message translates to:
  /// **'暂无同步账号'**
  String get noSyncAccount;

  /// No description provided for @addSyncAccountHint.
  ///
  /// In zh, this message translates to:
  /// **'点击右上角 + 号添加 WebDAV 或 Alist 账号'**
  String get addSyncAccountHint;

  /// No description provided for @connected.
  ///
  /// In zh, this message translates to:
  /// **'已连接'**
  String get connected;

  /// No description provided for @paused.
  ///
  /// In zh, this message translates to:
  /// **'已暂停'**
  String get paused;

  /// No description provided for @accountName.
  ///
  /// In zh, this message translates to:
  /// **'账户名称'**
  String get accountName;

  /// No description provided for @removeSyncConfigConfirm.
  ///
  /// In zh, this message translates to:
  /// **'这将移除此同步源配置'**
  String get removeSyncConfigConfirm;

  /// No description provided for @checkSyncNow.
  ///
  /// In zh, this message translates to:
  /// **'同步'**
  String get checkSyncNow;

  /// No description provided for @searchUnarchived.
  ///
  /// In zh, this message translates to:
  /// **'搜索未归档歌曲...'**
  String get searchUnarchived;

  /// No description provided for @selectedCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 已选择'**
  String selectedCount(Object count);

  /// No description provided for @scraperCenter.
  ///
  /// In zh, this message translates to:
  /// **'刮削中心'**
  String get scraperCenter;

  /// No description provided for @scraperCategoryAll.
  ///
  /// In zh, this message translates to:
  /// **'全部问题'**
  String get scraperCategoryAll;

  /// No description provided for @scraperCategoryUnscraped.
  ///
  /// In zh, this message translates to:
  /// **'未刮削'**
  String get scraperCategoryUnscraped;

  /// No description provided for @scraperCategoryScraped.
  ///
  /// In zh, this message translates to:
  /// **'已刮削'**
  String get scraperCategoryScraped;

  /// No description provided for @scraperCategoryHasLyrics.
  ///
  /// In zh, this message translates to:
  /// **'有歌词'**
  String get scraperCategoryHasLyrics;

  /// No description provided for @scraperCategoryNoLyrics.
  ///
  /// In zh, this message translates to:
  /// **'无歌词'**
  String get scraperCategoryNoLyrics;

  /// No description provided for @scraperCategoryMissingCover.
  ///
  /// In zh, this message translates to:
  /// **'缺少封面'**
  String get scraperCategoryMissingCover;

  /// No description provided for @scraperCategoryMissingInfo.
  ///
  /// In zh, this message translates to:
  /// **'缺失基本信息'**
  String get scraperCategoryMissingInfo;

  /// No description provided for @scraperCategoryArtists.
  ///
  /// In zh, this message translates to:
  /// **'歌手'**
  String get scraperCategoryArtists;

  /// No description provided for @scraperSourceMusicBrainz.
  ///
  /// In zh, this message translates to:
  /// **'MusicBrainz'**
  String get scraperSourceMusicBrainz;

  /// No description provided for @scraperSourceItunes.
  ///
  /// In zh, this message translates to:
  /// **'iTunes'**
  String get scraperSourceItunes;

  /// No description provided for @scraperSourceLabel.
  ///
  /// In zh, this message translates to:
  /// **'来源：{source}'**
  String scraperSourceLabel(Object source);

  /// No description provided for @viewOriginalInfo.
  ///
  /// In zh, this message translates to:
  /// **'查看原始信息'**
  String get viewOriginalInfo;

  /// No description provided for @clearLyrics.
  ///
  /// In zh, this message translates to:
  /// **'清除歌词'**
  String get clearLyrics;

  /// No description provided for @clearSongInfo.
  ///
  /// In zh, this message translates to:
  /// **'清除歌曲信息'**
  String get clearSongInfo;

  /// No description provided for @restoreArtistAvatar.
  ///
  /// In zh, this message translates to:
  /// **'恢复歌手头像'**
  String get restoreArtistAvatar;

  /// No description provided for @refresh.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get refresh;

  /// No description provided for @taskRunningBackground.
  ///
  /// In zh, this message translates to:
  /// **'任务已后台运行'**
  String get taskRunningBackground;

  /// No description provided for @unknownArtist.
  ///
  /// In zh, this message translates to:
  /// **'未知艺术家'**
  String get unknownArtist;

  /// No description provided for @unknownAlbum.
  ///
  /// In zh, this message translates to:
  /// **'未知专辑'**
  String get unknownAlbum;

  /// No description provided for @nowPlaying.
  ///
  /// In zh, this message translates to:
  /// **'正在播放'**
  String get nowPlaying;

  /// No description provided for @manualMatchMetadata.
  ///
  /// In zh, this message translates to:
  /// **'手动匹配元数据'**
  String get manualMatchMetadata;

  /// No description provided for @songTitleLabel.
  ///
  /// In zh, this message translates to:
  /// **'歌曲名'**
  String get songTitleLabel;

  /// No description provided for @artistLabel.
  ///
  /// In zh, this message translates to:
  /// **'艺术家'**
  String get artistLabel;

  /// No description provided for @albumLabel.
  ///
  /// In zh, this message translates to:
  /// **'专辑'**
  String get albumLabel;

  /// No description provided for @searchToSeeResults.
  ///
  /// In zh, this message translates to:
  /// **'搜索以查看结果'**
  String get searchToSeeResults;

  /// No description provided for @lyricsDuration.
  ///
  /// In zh, this message translates to:
  /// **'歌词时长：{duration}'**
  String lyricsDuration(Object duration);

  /// No description provided for @manualMatchLyrics.
  ///
  /// In zh, this message translates to:
  /// **'手动匹配歌词'**
  String get manualMatchLyrics;

  /// No description provided for @lyricsComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'歌词功能即将上线...'**
  String get lyricsComingSoon;

  /// No description provided for @lyricsModeOff.
  ///
  /// In zh, this message translates to:
  /// **'歌词：关闭'**
  String get lyricsModeOff;

  /// No description provided for @lyricsModeCompact.
  ///
  /// In zh, this message translates to:
  /// **'歌词：封面下方'**
  String get lyricsModeCompact;

  /// No description provided for @lyricsModeFull.
  ///
  /// In zh, this message translates to:
  /// **'歌词：全屏显示'**
  String get lyricsModeFull;

  /// No description provided for @noLyricsFound.
  ///
  /// In zh, this message translates to:
  /// **'未找到歌词'**
  String get noLyricsFound;

  /// No description provided for @syncCenterSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'手动同步与差异检查'**
  String get syncCenterSubtitle;

  /// No description provided for @scraperCenterSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'手动刮削与候选确认'**
  String get scraperCenterSubtitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'存储、音频、同步与刮削策略'**
  String get settingsSubtitle;

  /// No description provided for @deletePlaylist.
  ///
  /// In zh, this message translates to:
  /// **'删除歌单'**
  String get deletePlaylist;

  /// No description provided for @confirmDeletePlaylist.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除 \"{name}\" 吗?'**
  String confirmDeletePlaylist(Object name);

  /// No description provided for @clearPlaylist.
  ///
  /// In zh, this message translates to:
  /// **'清空歌单'**
  String get clearPlaylist;

  /// No description provided for @confirmClearPlaylist.
  ///
  /// In zh, this message translates to:
  /// **'确定要清空 \"{name}\" 的所有歌曲吗?'**
  String confirmClearPlaylist(Object name);

  /// No description provided for @rename.
  ///
  /// In zh, this message translates to:
  /// **'重命名'**
  String get rename;

  /// No description provided for @importCover.
  ///
  /// In zh, this message translates to:
  /// **'导入封面'**
  String get importCover;

  /// No description provided for @coverImported.
  ///
  /// In zh, this message translates to:
  /// **'封面已导入'**
  String get coverImported;

  /// No description provided for @clearCover.
  ///
  /// In zh, this message translates to:
  /// **'清空封面'**
  String get clearCover;

  /// No description provided for @confirmClearCover.
  ///
  /// In zh, this message translates to:
  /// **'确定要清空 \"{name}\" 的封面吗?'**
  String confirmClearCover(Object name);

  /// No description provided for @emptyPlaylist.
  ///
  /// In zh, this message translates to:
  /// **'歌单是空的'**
  String get emptyPlaylist;

  /// No description provided for @playbackError.
  ///
  /// In zh, this message translates to:
  /// **'无法开始播放: {error}'**
  String playbackError(Object error);

  /// No description provided for @selectAll.
  ///
  /// In zh, this message translates to:
  /// **'全选/取消全选'**
  String get selectAll;

  /// No description provided for @search.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get search;

  /// No description provided for @noMatchingSongs.
  ///
  /// In zh, this message translates to:
  /// **'没有找到匹配的歌曲'**
  String get noMatchingSongs;

  /// No description provided for @allSongsScraped.
  ///
  /// In zh, this message translates to:
  /// **'恭喜，所有歌曲都已刮削完成！'**
  String get allSongsScraped;

  /// No description provided for @foundUnscrapedSongs.
  ///
  /// In zh, this message translates to:
  /// **'发现 {count} 首未归档歌曲'**
  String foundUnscrapedSongs(Object count);

  /// No description provided for @deleteSongs.
  ///
  /// In zh, this message translates to:
  /// **'删除歌曲'**
  String get deleteSongs;

  /// No description provided for @confirmDeleteSongs.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除选中的 {count} 首歌曲吗？\n(仅从库中删除，文件保留)'**
  String confirmDeleteSongs(Object count);

  /// No description provided for @songsDeleted.
  ///
  /// In zh, this message translates to:
  /// **'已删除 {count} 首歌曲'**
  String songsDeleted(Object count);

  /// No description provided for @addedToQueue.
  ///
  /// In zh, this message translates to:
  /// **'已添加到播放 {count} 首歌曲'**
  String addedToQueue(Object count);

  /// No description provided for @pleaseSelectDetailed.
  ///
  /// In zh, this message translates to:
  /// **'请先选择要刮削的歌曲'**
  String get pleaseSelectDetailed;

  /// No description provided for @batchScrapeStarted.
  ///
  /// In zh, this message translates to:
  /// **'已启动后台刮削任务'**
  String get batchScrapeStarted;

  /// No description provided for @scrapeLyrics.
  ///
  /// In zh, this message translates to:
  /// **'刮削歌词'**
  String get scrapeLyrics;

  /// No description provided for @scrapeLyricsStarted.
  ///
  /// In zh, this message translates to:
  /// **'开始刮削歌词'**
  String get scrapeLyricsStarted;

  /// No description provided for @scanning.
  ///
  /// In zh, this message translates to:
  /// **'扫描中...'**
  String get scanning;

  /// No description provided for @addedCompSongs.
  ///
  /// In zh, this message translates to:
  /// **'已添加 {count} 首歌曲'**
  String addedCompSongs(Object count);

  /// No description provided for @processingFiles.
  ///
  /// In zh, this message translates to:
  /// **'正在处理文件...'**
  String get processingFiles;

  /// No description provided for @importedSongs.
  ///
  /// In zh, this message translates to:
  /// **'已导入 {count} 首歌曲'**
  String importedSongs(Object count);

  /// No description provided for @addFolder.
  ///
  /// In zh, this message translates to:
  /// **'添加文件夹'**
  String get addFolder;

  /// No description provided for @emptyLibrary.
  ///
  /// In zh, this message translates to:
  /// **'资料库为空'**
  String get emptyLibrary;

  /// No description provided for @addMusicFolder.
  ///
  /// In zh, this message translates to:
  /// **'添加音乐文件夹'**
  String get addMusicFolder;

  /// No description provided for @unknown.
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get unknown;

  /// No description provided for @noItemsFound.
  ///
  /// In zh, this message translates to:
  /// **'未找到项目'**
  String get noItemsFound;

  /// No description provided for @searchViewType.
  ///
  /// In zh, this message translates to:
  /// **'搜索 {viewType}...'**
  String searchViewType(Object viewType);

  /// No description provided for @forYou.
  ///
  /// In zh, this message translates to:
  /// **'为你推荐'**
  String get forYou;

  /// No description provided for @viewDetails.
  ///
  /// In zh, this message translates to:
  /// **'查看详情'**
  String get viewDetails;

  /// No description provided for @songDetails.
  ///
  /// In zh, this message translates to:
  /// **'歌曲详情'**
  String get songDetails;

  /// No description provided for @filePath.
  ///
  /// In zh, this message translates to:
  /// **'文件路径'**
  String get filePath;

  /// No description provided for @fileName.
  ///
  /// In zh, this message translates to:
  /// **'文件名'**
  String get fileName;

  /// No description provided for @duration.
  ///
  /// In zh, this message translates to:
  /// **'时长'**
  String get duration;

  /// No description provided for @size.
  ///
  /// In zh, this message translates to:
  /// **'大小'**
  String get size;

  /// No description provided for @dateAdded.
  ///
  /// In zh, this message translates to:
  /// **'添加日期'**
  String get dateAdded;

  /// No description provided for @lastPlayed.
  ///
  /// In zh, this message translates to:
  /// **'最后播放'**
  String get lastPlayed;

  /// No description provided for @genre.
  ///
  /// In zh, this message translates to:
  /// **'流派'**
  String get genre;

  /// No description provided for @year.
  ///
  /// In zh, this message translates to:
  /// **'年份'**
  String get year;

  /// No description provided for @trackNumber.
  ///
  /// In zh, this message translates to:
  /// **'音轨号'**
  String get trackNumber;

  /// No description provided for @discNumber.
  ///
  /// In zh, this message translates to:
  /// **'碟号'**
  String get discNumber;

  /// No description provided for @lyrics.
  ///
  /// In zh, this message translates to:
  /// **'歌词'**
  String get lyrics;

  /// No description provided for @copyToClipboard.
  ///
  /// In zh, this message translates to:
  /// **'复制到剪贴板'**
  String get copyToClipboard;

  /// No description provided for @fullPath.
  ///
  /// In zh, this message translates to:
  /// **'完整路径'**
  String get fullPath;

  /// No description provided for @webdav.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV'**
  String get webdav;

  /// No description provided for @openlist.
  ///
  /// In zh, this message translates to:
  /// **'OpenList'**
  String get openlist;

  /// No description provided for @webdavConfigTitle.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 配置'**
  String get webdavConfigTitle;

  /// No description provided for @webdavUrlLabel.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV URL (例如 https://dav.example.com)'**
  String get webdavUrlLabel;

  /// No description provided for @keepAliveTitle.
  ///
  /// In zh, this message translates to:
  /// **'保活'**
  String get keepAliveTitle;

  /// No description provided for @keepAliveDescription.
  ///
  /// In zh, this message translates to:
  /// **'如熄屏时连接断开，请在系统设置中允许应用自启动。'**
  String get keepAliveDescription;

  /// No description provided for @openAutoStart.
  ///
  /// In zh, this message translates to:
  /// **'打开自启动设置'**
  String get openAutoStart;

  /// No description provided for @username.
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get username;

  /// No description provided for @password.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get password;

  /// No description provided for @musicFolderPath.
  ///
  /// In zh, this message translates to:
  /// **'音乐文件夹路径 (例如 /Music)'**
  String get musicFolderPath;

  /// No description provided for @identify.
  ///
  /// In zh, this message translates to:
  /// **'识别'**
  String get identify;

  /// No description provided for @identificationRules.
  ///
  /// In zh, this message translates to:
  /// **'识别规则'**
  String get identificationRules;

  /// No description provided for @rulesTooltip.
  ///
  /// In zh, this message translates to:
  /// **'规则：艺术家/专辑/歌曲 或 文件名'**
  String get rulesTooltip;

  /// No description provided for @scanComplete.
  ///
  /// In zh, this message translates to:
  /// **'扫描完成。识别了 {count} 首歌曲。'**
  String scanComplete(Object count);

  /// No description provided for @scanError.
  ///
  /// In zh, this message translates to:
  /// **'错误：{error}'**
  String scanError(Object error);

  /// No description provided for @permissionDenied.
  ///
  /// In zh, this message translates to:
  /// **'存储权限被拒绝'**
  String get permissionDenied;

  /// No description provided for @scanningFile.
  ///
  /// In zh, this message translates to:
  /// **'正在扫描: {fileName}'**
  String scanningFile(Object fileName);

  /// No description provided for @sourceLocal.
  ///
  /// In zh, this message translates to:
  /// **'本地'**
  String get sourceLocal;

  /// No description provided for @sourceCloud.
  ///
  /// In zh, this message translates to:
  /// **'云端'**
  String get sourceCloud;

  /// No description provided for @webdavAccountsCache.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 账户缓存'**
  String get webdavAccountsCache;

  /// No description provided for @clearCacheForAccount.
  ///
  /// In zh, this message translates to:
  /// **'清除 {accountName} 的缓存？'**
  String clearCacheForAccount(Object accountName);

  /// No description provided for @accountCacheCleared.
  ///
  /// In zh, this message translates to:
  /// **'账户缓存已清除'**
  String get accountCacheCleared;

  /// No description provided for @clearLegacyCache.
  ///
  /// In zh, this message translates to:
  /// **'清除所有旧版缓存的 WebDAV 歌曲？'**
  String get clearLegacyCache;

  /// No description provided for @legacyCacheCleared.
  ///
  /// In zh, this message translates to:
  /// **'旧版缓存已清除'**
  String get legacyCacheCleared;

  /// No description provided for @clearCache.
  ///
  /// In zh, this message translates to:
  /// **'清除缓存'**
  String get clearCache;

  /// No description provided for @scrapeAgain.
  ///
  /// In zh, this message translates to:
  /// **'重新刮削'**
  String get scrapeAgain;

  /// No description provided for @scrapeArtistAvatars.
  ///
  /// In zh, this message translates to:
  /// **'刮削歌手头像'**
  String get scrapeArtistAvatars;

  /// No description provided for @manualMatchArtist.
  ///
  /// In zh, this message translates to:
  /// **'手动匹配歌手'**
  String get manualMatchArtist;

  /// No description provided for @batchScrapeArtists.
  ///
  /// In zh, this message translates to:
  /// **'批量刮削歌手'**
  String get batchScrapeArtists;

  /// No description provided for @scrapeArtistAvatarsResult.
  ///
  /// In zh, this message translates to:
  /// **'已更新 {count} 个歌手头像'**
  String scrapeArtistAvatarsResult(Object count);

  /// No description provided for @songDeletedWithTitle.
  ///
  /// In zh, this message translates to:
  /// **'已删除 \"{title}\"'**
  String songDeletedWithTitle(Object title);

  /// No description provided for @cacheClearedWithTitle.
  ///
  /// In zh, this message translates to:
  /// **'已清除 \"{title}\" 的缓存'**
  String cacheClearedWithTitle(Object title);

  /// No description provided for @cannotAccessSong.
  ///
  /// In zh, this message translates to:
  /// **'无法访问歌曲文件：{title}'**
  String cannotAccessSong(Object title);

  /// No description provided for @addedToFavorites.
  ///
  /// In zh, this message translates to:
  /// **'已添加到收藏'**
  String get addedToFavorites;

  /// No description provided for @removedFromFavorites.
  ///
  /// In zh, this message translates to:
  /// **'已从收藏中移除'**
  String get removedFromFavorites;

  /// No description provided for @favoritesPlaylistName.
  ///
  /// In zh, this message translates to:
  /// **'收藏'**
  String get favoritesPlaylistName;

  /// No description provided for @favoritesPlaylistDescription.
  ///
  /// In zh, this message translates to:
  /// **'我喜欢的歌曲'**
  String get favoritesPlaylistDescription;

  /// No description provided for @playlistAlreadyExists.
  ///
  /// In zh, this message translates to:
  /// **'名为 \"{playlistName}\" 的歌单已存在'**
  String playlistAlreadyExists(Object playlistName);

  /// No description provided for @resetAdminPasswordTitle.
  ///
  /// In zh, this message translates to:
  /// **'重置管理员密码'**
  String get resetAdminPasswordTitle;

  /// No description provided for @resetFailed.
  ///
  /// In zh, this message translates to:
  /// **'重置失败'**
  String get resetFailed;

  /// No description provided for @unknownError.
  ///
  /// In zh, this message translates to:
  /// **'未知错误'**
  String get unknownError;

  /// No description provided for @newPasswordGenerated.
  ///
  /// In zh, this message translates to:
  /// **'新密码已生成'**
  String get newPasswordGenerated;

  /// No description provided for @usernameAdmin.
  ///
  /// In zh, this message translates to:
  /// **'用户名：admin'**
  String get usernameAdmin;

  /// No description provided for @newPassword.
  ///
  /// In zh, this message translates to:
  /// **'新密码：{pwd}'**
  String newPassword(Object pwd);

  /// No description provided for @portAndProxy.
  ///
  /// In zh, this message translates to:
  /// **'端口与代理'**
  String get portAndProxy;

  /// No description provided for @invalidPort.
  ///
  /// In zh, this message translates to:
  /// **'端口无效'**
  String get invalidPort;

  /// No description provided for @proxyHostEmpty.
  ///
  /// In zh, this message translates to:
  /// **'代理地址不能为空'**
  String get proxyHostEmpty;

  /// No description provided for @invalidProxyPort.
  ///
  /// In zh, this message translates to:
  /// **'代理端口无效'**
  String get invalidProxyPort;

  /// No description provided for @savedRestartRequired.
  ///
  /// In zh, this message translates to:
  /// **'已保存，需重启后生效'**
  String get savedRestartRequired;

  /// No description provided for @openListService.
  ///
  /// In zh, this message translates to:
  /// **'OpenList 服务'**
  String get openListService;

  /// No description provided for @statusRunning.
  ///
  /// In zh, this message translates to:
  /// **'状态: 运行中'**
  String get statusRunning;

  /// No description provided for @statusStopped.
  ///
  /// In zh, this message translates to:
  /// **'状态: 已停止'**
  String get statusStopped;

  /// No description provided for @address.
  ///
  /// In zh, this message translates to:
  /// **'地址: http://{address}:{port}'**
  String address(Object address, Object port);

  /// No description provided for @stop.
  ///
  /// In zh, this message translates to:
  /// **'停止'**
  String get stop;

  /// No description provided for @start.
  ///
  /// In zh, this message translates to:
  /// **'启动'**
  String get start;

  /// No description provided for @managementPage.
  ///
  /// In zh, this message translates to:
  /// **'管理页面'**
  String get managementPage;

  /// No description provided for @accessManagementPage.
  ///
  /// In zh, this message translates to:
  /// **'访问 OpenList 管理页面：'**
  String get accessManagementPage;

  /// No description provided for @startServiceFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先启动 OpenList 服务'**
  String get startServiceFirst;

  /// No description provided for @openInApp.
  ///
  /// In zh, this message translates to:
  /// **'APP内打开'**
  String get openInApp;

  /// No description provided for @openInBrowser.
  ///
  /// In zh, this message translates to:
  /// **'浏览器打开'**
  String get openInBrowser;

  /// No description provided for @adminInfo.
  ///
  /// In zh, this message translates to:
  /// **'管理员信息'**
  String get adminInfo;

  /// No description provided for @saveCredentials.
  ///
  /// In zh, this message translates to:
  /// **'请保存：\n用户名：admin\n初始密码：{password}'**
  String saveCredentials(Object password);

  /// No description provided for @saved.
  ///
  /// In zh, this message translates to:
  /// **'我已保存'**
  String get saved;

  /// No description provided for @defaultUsernameAdmin.
  ///
  /// In zh, this message translates to:
  /// **'默认用户名：admin'**
  String get defaultUsernameAdmin;

  /// No description provided for @resetPassword.
  ///
  /// In zh, this message translates to:
  /// **'重置密码'**
  String get resetPassword;

  /// No description provided for @stopServiceToModify.
  ///
  /// In zh, this message translates to:
  /// **'停止服务后才可修改'**
  String get stopServiceToModify;

  /// No description provided for @serviceRunningLocked.
  ///
  /// In zh, this message translates to:
  /// **'服务运行中，已锁定'**
  String get serviceRunningLocked;

  /// No description provided for @stopServiceExitHint.
  ///
  /// In zh, this message translates to:
  /// **'请手动停止 OpenList 后再退出软件，才能停止 OpenList'**
  String get stopServiceExitHint;

  /// No description provided for @saveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败'**
  String get saveFailed;

  /// No description provided for @openListManagement.
  ///
  /// In zh, this message translates to:
  /// **'OpenList 管理'**
  String get openListManagement;

  /// No description provided for @autoStartOpenListOnAppLaunch.
  ///
  /// In zh, this message translates to:
  /// **'自动启动OpenList'**
  String get autoStartOpenListOnAppLaunch;

  /// No description provided for @autoStartOpenListDescription.
  ///
  /// In zh, this message translates to:
  /// **'启用后，APP启动时将自动启动OpenList服务'**
  String get autoStartOpenListDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
