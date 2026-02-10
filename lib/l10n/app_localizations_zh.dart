// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'JMusic';

  @override
  String get home => '首页';

  @override
  String get library => '音乐库';

  @override
  String get playlists => '歌单';

  @override
  String get playlistRecommendations => '播放列表推荐';

  @override
  String get more => '更多';

  @override
  String get playVideo => '播放视频';

  @override
  String get restoreOriginalInfo => '恢复原始信息';

  @override
  String restoreOriginalInfoConfirm(Object count) {
    return '是否恢复 $count 首的原始信息？';
  }

  @override
  String restoreOriginalInfoSuccess(Object count) {
    return '已恢复 $count 首';
  }

  @override
  String get restoreOriginalInfoFailed => '没有可恢复的原始信息';

  @override
  String get batchRestore => '批量恢复';

  @override
  String get sync => '同步';

  @override
  String get scraper => '刮削';

  @override
  String get settings => '设置';

  @override
  String get clear => '清空';

  @override
  String get playingQueue => '播放队列';

  @override
  String get language => '语言';

  @override
  String get theme => '主题';

  @override
  String get storageEvents => '存储与缓存';

  @override
  String get coverCache => '封面缓存';

  @override
  String get clearCoverCacheConfirm => '清除封面缓存？';

  @override
  String get coverCacheCleared => '封面缓存已清除';

  @override
  String get artistAvatarCache => '歌手头像缓存';

  @override
  String get clearArtistAvatarCacheConfirm => '清除歌手头像缓存？';

  @override
  String get artistAvatarCacheCleared => '歌手头像缓存已清除';

  @override
  String get embeddedCoverCache => '内嵌封面缓存';

  @override
  String get clearEmbeddedCoverCacheConfirm => '清除内嵌封面缓存？';

  @override
  String get embeddedCoverCacheCleared => '内嵌封面缓存已清除';

  @override
  String get appDataSize => '应用数据占用';

  @override
  String get logExport => '导出日志';

  @override
  String get logFileSize => '日志大小';

  @override
  String get logExported => '日志已导出';

  @override
  String get clearLogs => '清空日志';

  @override
  String get clearLogsConfirm => '清空日志？';

  @override
  String get logsCleared => '日志已清空';

  @override
  String get scrapeCompleteWithLyrics => '刮削完成：专辑信息已更新，歌词已找到';

  @override
  String get scrapeCompleteNoLyrics => '刮削完成：专辑信息已更新，未找到歌词';

  @override
  String autoScrapeLyricsSuccess(Object title) {
    return '自动刮削成功：仅歌词\n$title';
  }

  @override
  String autoScrapeLyricsFail(Object title) {
    return '自动刮削失败：歌词\n$title';
  }

  @override
  String autoScrapeFullSuccess(Object title) {
    return '自动刮削成功：信息+歌词\n$title';
  }

  @override
  String autoScrapeFullFail(Object title) {
    return '自动刮削失败：信息+歌词\n$title';
  }

  @override
  String get artistNameLabel => '歌手名称';

  @override
  String get syncSettings => '同步设置';

  @override
  String get serverSettings => '服务器设置';

  @override
  String get defaultPage => '默认启动页';

  @override
  String get scraperSettings => '刮削设置';

  @override
  String get autoScrapeOnPlayTitle => '播放时自动刮削';

  @override
  String get autoScrapeOnPlayDesc => '播放开始时后台执行完整歌曲信息+歌词刮削（默认关闭）';

  @override
  String get usePrimaryArtistForScraper => '刮削仅使用主歌手';

  @override
  String get usePrimaryArtistForScraperDesc =>
      '启用后，刮削将仅使用主歌手进行查询；禁用时会包含客座/合作歌手。';

  @override
  String get scraperMatchSources => '匹配来源';

  @override
  String get scraperSourceAtLeastOne => '请至少启用一个来源';

  @override
  String get scraperSongSources => '歌曲刮削源';

  @override
  String get scraperSourceQQMusic => 'QQ 音乐';

  @override
  String get scraperArtistSources => '歌手刮削源';

  @override
  String get scraperLyricsSources => '歌词刮削源';

  @override
  String get audioSettings => '音频与播放';

  @override
  String get playbackSettings => '播放设置';

  @override
  String get desktopVolume => '桌面端音量';

  @override
  String get crossfadeEnabled => '启用淡入淡出';

  @override
  String get crossfadeEnabledDesc => '歌曲切换时启用淡入淡出效果，提供更流畅的听觉体验';

  @override
  String get crossfadeDuration => '淡入淡出时长';

  @override
  String get crossfadeDurationDesc => '设置歌曲间淡入淡出效果的持续时间';

  @override
  String get mute => '静音';

  @override
  String get unmute => '取消静音';

  @override
  String get loopingOn => '循环：开';

  @override
  String get loopingOff => '循环：关';

  @override
  String get scraperSourceLrclib => 'lrclib';

  @override
  String get scraperSourceRangotec => 'rangotec';

  @override
  String get scraperLyricsSourcesFixed => '歌词刮削源固定为 lrclib + rangotec';

  @override
  String seconds(Object count) {
    return '$count 秒';
  }

  @override
  String get crossfadeEnabledInfo => '已启用淡入淡出,歌曲将平滑过渡';

  @override
  String get crossfadeDisabledInfo => '淡入淡出已禁用,歌曲将直接切换';

  @override
  String get proxySettings => '网络代理';

  @override
  String get about => '关于';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get systemProxy => '系统代理';

  @override
  String get noProxy => '无代理';

  @override
  String get customProxy => '自定义代理';

  @override
  String get port => '端口';

  @override
  String get ipAddress => 'IP地址';

  @override
  String get save => '保存';

  @override
  String get recentlyPlayed => '最近播放';

  @override
  String get recentlyImported => '最近导入';

  @override
  String get toBeScraped => '待刮削处理';

  @override
  String get noData => '暂无数据，请先导入';

  @override
  String get scanMusic => '扫描音乐';

  @override
  String get batchScrape => '批量刮削';

  @override
  String get batchScrapeRunning => '后台刮削中...';

  @override
  String get batchScrapeResult => '刮削报告';

  @override
  String successCount(Object count) {
    return '成功: $count';
  }

  @override
  String failCount(Object count) {
    return '失败: $count';
  }

  @override
  String get confirm => '确定';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get editTags => '编辑标签';

  @override
  String get addToPlaylist => '添加到歌单';

  @override
  String get playAll => '播放全部';

  @override
  String get play => '播放';

  @override
  String deleteConfirm(Object count) {
    return '确定删除选中的 $count 首歌曲吗？';
  }

  @override
  String deleteSingleConfirm(Object title) {
    return '确定删除 \"$title\" 吗？';
  }

  @override
  String get importMusic => '导入音乐';

  @override
  String get manualSync => '手动同步';

  @override
  String get developing => '功能开发中';

  @override
  String get importInLibrary => '请前往资料库导入';

  @override
  String get homeTitle => '首页';

  @override
  String get importMusicTooltip => '导入音乐';

  @override
  String get syncFeatureDeveloping => '同步功能开发中';

  @override
  String get noMusicData => '暂无数据\n请先前往资料库导入音乐';

  @override
  String get scrapedCompletedTitle => '批量刮削完成';

  @override
  String totalTasks(Object count) {
    return '总计任务: $count';
  }

  @override
  String get hide => '隐藏';

  @override
  String get createPlaylist => '新建歌单';

  @override
  String get noPlaylists => '暂无歌单';

  @override
  String get playlistTitle => '歌单';

  @override
  String get confirmDelete => '确认删除?';

  @override
  String get edit => '编辑';

  @override
  String get playlistName => '歌单名称';

  @override
  String get playlistNameHint => '我的最爱';

  @override
  String get create => '创建';

  @override
  String songCount(Object count) {
    return '$count 首歌曲';
  }

  @override
  String addedToPlaylist(Object name) {
    return '已添加到 \"$name\"';
  }

  @override
  String songsAlreadyInPlaylist(Object playlistName) {
    return '已存在于 \"$playlistName\"';
  }

  @override
  String toBeScrapedSubtitle(Object count) {
    return '$count 首歌曲元数据不全';
  }

  @override
  String get defaultPageDescription => '选择应用启动时显示的默认页面';

  @override
  String get syncCenter => '同步中心';

  @override
  String get addSyncAccount => '新增同步账号';

  @override
  String get openListNotSupported => 'OpenList 暂未支持';

  @override
  String get noSyncAccount => '暂无同步账号';

  @override
  String get addSyncAccountHint => '点击右上角 + 号添加 WebDAV 或 Alist 账号';

  @override
  String get connected => '已连接';

  @override
  String get paused => '已暂停';

  @override
  String get accountName => '账户名称';

  @override
  String get removeSyncConfigConfirm => '这将移除此同步源配置';

  @override
  String get checkSyncNow => '同步';

  @override
  String get searchUnarchived => '搜索未归档歌曲...';

  @override
  String selectedCount(Object count) {
    return '$count 已选择';
  }

  @override
  String get scraperCenter => '刮削中心';

  @override
  String get scraperCategoryAll => '全部问题';

  @override
  String get scraperCategoryUnscraped => '未刮削';

  @override
  String get scraperCategoryScraped => '已刮削';

  @override
  String get scraperCategoryHasLyrics => '有歌词';

  @override
  String get scraperCategoryNoLyrics => '无歌词';

  @override
  String get scraperCategoryMissingCover => '缺少封面';

  @override
  String get scraperCategoryMissingInfo => '缺失基本信息';

  @override
  String get scraperCategoryArtists => '歌手';

  @override
  String get scraperSourceMusicBrainz => 'MusicBrainz';

  @override
  String get scraperSourceItunes => 'iTunes';

  @override
  String scraperSourceLabel(Object source) {
    return '来源：$source';
  }

  @override
  String get viewOriginalInfo => '查看原始信息';

  @override
  String get clearLyrics => '清除歌词';

  @override
  String get clearSongInfo => '清除歌曲信息';

  @override
  String get restoreArtistAvatar => '恢复歌手头像';

  @override
  String get batchScrapeArtistAvatars => '批量刮削歌手头像';

  @override
  String get restoreArtistAvatars => '恢复歌手头像';

  @override
  String restoreArtistAvatarsResult(Object count) {
    return '成功恢复 $count 个歌手头像';
  }

  @override
  String get restoreArtistAvatarsFailed => '恢复歌手头像失败';

  @override
  String get refresh => '刷新';

  @override
  String get taskRunningBackground => '任务已后台运行';

  @override
  String get unknownArtist => '未知艺术家';

  @override
  String get unknownAlbum => '未知专辑';

  @override
  String get nowPlaying => '正在播放';

  @override
  String get manualMatchMetadata => '手动匹配元数据';

  @override
  String get songTitleLabel => '歌曲名';

  @override
  String get artistLabel => '艺术家';

  @override
  String get albumLabel => '专辑';

  @override
  String get searchToSeeResults => '搜索以查看结果';

  @override
  String lyricsDuration(Object duration) {
    return '歌词时长：$duration';
  }

  @override
  String get manualMatchLyrics => '手动匹配歌词';

  @override
  String get lyricsComingSoon => '歌词功能即将上线...';

  @override
  String get lyricsModeOff => '歌词：关闭';

  @override
  String get lyricsModeCompact => '歌词：封面下方';

  @override
  String get lyricsModeFull => '歌词：全屏显示';

  @override
  String get noLyricsFound => '未找到歌词';

  @override
  String get syncCenterSubtitle => '手动同步与差异检查';

  @override
  String get scraperCenterSubtitle => '手动刮削与候选确认';

  @override
  String get settingsSubtitle => '存储、音频、同步与刮削策略';

  @override
  String get deletePlaylist => '删除歌单';

  @override
  String confirmDeletePlaylist(Object name) {
    return '确定要删除 \"$name\" 吗?';
  }

  @override
  String get clearPlaylist => '清空歌单';

  @override
  String confirmClearPlaylist(Object name) {
    return '确定要清空 \"$name\" 的所有歌曲吗?';
  }

  @override
  String get rename => '重命名';

  @override
  String get importCover => '导入封面';

  @override
  String get coverImported => '封面已导入';

  @override
  String get clearCover => '清空封面';

  @override
  String confirmClearCover(Object name) {
    return '确定要清空 \"$name\" 的封面吗?';
  }

  @override
  String get emptyPlaylist => '歌单是空的';

  @override
  String playbackError(Object error) {
    return '无法开始播放: $error';
  }

  @override
  String get selectAll => '全选/取消全选';

  @override
  String get search => '搜索';

  @override
  String get noMatchingSongs => '没有找到匹配的歌曲';

  @override
  String get allSongsScraped => '恭喜，所有歌曲都已刮削完成！';

  @override
  String foundUnscrapedSongs(Object count) {
    return '发现 $count 首未归档歌曲';
  }

  @override
  String get deleteSongs => '删除歌曲';

  @override
  String confirmDeleteSongs(Object count) {
    return '确定要删除选中的 $count 首歌曲吗？\n(仅从库中删除，文件保留)';
  }

  @override
  String songsDeleted(Object count) {
    return '已删除 $count 首歌曲';
  }

  @override
  String addedToQueue(Object count) {
    return '已添加到播放 $count 首歌曲';
  }

  @override
  String get pleaseSelectDetailed => '请先选择要刮削的歌曲';

  @override
  String get batchScrapeStarted => '已启动后台刮削任务';

  @override
  String get scrapeLyrics => '刮削歌词';

  @override
  String get scrapeLyricsStarted => '开始刮削歌词';

  @override
  String get scanning => '扫描中...';

  @override
  String addedCompSongs(Object count) {
    return '已添加 $count 首歌曲';
  }

  @override
  String get processingFiles => '正在处理文件...';

  @override
  String importedSongs(Object count) {
    return '已导入 $count 首歌曲';
  }

  @override
  String get addFolder => '添加文件夹';

  @override
  String get emptyLibrary => '资料库为空';

  @override
  String get addMusicFolder => '添加音乐文件夹';

  @override
  String get unknown => '未知';

  @override
  String get noItemsFound => '未找到项目';

  @override
  String searchViewType(Object viewType) {
    return '搜索 $viewType...';
  }

  @override
  String get forYou => '为你推荐';

  @override
  String get viewDetails => '查看详情';

  @override
  String get songDetails => '歌曲详情';

  @override
  String get filePath => '文件路径';

  @override
  String get fileName => '文件名';

  @override
  String get duration => '时长';

  @override
  String get size => '大小';

  @override
  String get dateAdded => '添加日期';

  @override
  String get lastPlayed => '最后播放';

  @override
  String get genre => '流派';

  @override
  String get year => '年份';

  @override
  String get trackNumber => '音轨号';

  @override
  String get discNumber => '碟号';

  @override
  String get lyrics => '歌词';

  @override
  String get copyToClipboard => '复制到剪贴板';

  @override
  String get fullPath => '完整路径';

  @override
  String get webdav => 'WebDAV';

  @override
  String get openlist => 'OpenList';

  @override
  String get webdavConfigTitle => 'WebDAV 配置';

  @override
  String get webdavUrlLabel => 'WebDAV URL (例如 https://dav.example.com)';

  @override
  String get keepAliveTitle => '保活';

  @override
  String get keepAliveDescription => '如熄屏时连接断开，请在系统设置中允许应用自启动。';

  @override
  String get openAutoStart => '打开自启动设置';

  @override
  String get username => '用户名';

  @override
  String get password => '密码';

  @override
  String get musicFolderPath => '音乐文件夹路径 (例如 /Music)';

  @override
  String get identify => '识别';

  @override
  String get identificationRules => '识别规则';

  @override
  String get rulesTooltip => '规则：艺术家/专辑/歌曲 或 文件名';

  @override
  String scanComplete(Object count) {
    return '扫描完成。识别了 $count 首歌曲。';
  }

  @override
  String scanError(Object error) {
    return '错误：$error';
  }

  @override
  String get permissionDenied => '存储权限被拒绝';

  @override
  String scanningFile(Object fileName) {
    return '正在扫描: $fileName';
  }

  @override
  String get sourceLocal => '本地';

  @override
  String get sourceCloud => '云端';

  @override
  String get webdavAccountsCache => 'WebDAV 账户缓存';

  @override
  String clearCacheForAccount(Object accountName) {
    return '清除 $accountName 的缓存？';
  }

  @override
  String get accountCacheCleared => '账户缓存已清除';

  @override
  String get clearLegacyCache => '清除所有旧版缓存的 WebDAV 歌曲？';

  @override
  String get legacyCacheCleared => '旧版缓存已清除';

  @override
  String get clearCache => '清除缓存';

  @override
  String get scrapeAgain => '重新刮削';

  @override
  String get scrapeArtistAvatars => '刮削歌手头像';

  @override
  String get manualMatchArtist => '手动匹配歌手';

  @override
  String get batchScrapeArtists => '批量刮削歌手';

  @override
  String scrapeArtistAvatarsResult(Object count) {
    return '已更新 $count 个歌手头像';
  }

  @override
  String songDeletedWithTitle(Object title) {
    return '已删除 \"$title\"';
  }

  @override
  String cacheClearedWithTitle(Object title) {
    return '已清除 \"$title\" 的缓存';
  }

  @override
  String cannotAccessSong(Object title) {
    return '无法访问歌曲文件：$title';
  }

  @override
  String get addedToFavorites => '已添加到收藏';

  @override
  String get removedFromFavorites => '已从收藏中移除';

  @override
  String get favoritesPlaylistName => '收藏';

  @override
  String get favoritesPlaylistDescription => '我喜欢的歌曲';

  @override
  String playlistAlreadyExists(Object playlistName) {
    return '名为 \"$playlistName\" 的歌单已存在';
  }

  @override
  String get resetAdminPasswordTitle => '重置管理员密码';

  @override
  String get resetFailed => '重置失败';

  @override
  String get unknownError => '未知错误';

  @override
  String get newPasswordGenerated => '新密码已生成';

  @override
  String get usernameAdmin => '用户名：admin';

  @override
  String newPassword(Object pwd) {
    return '新密码：$pwd';
  }

  @override
  String get portAndProxy => '端口与代理';

  @override
  String get invalidPort => '端口无效';

  @override
  String get proxyHostEmpty => '代理地址不能为空';

  @override
  String get invalidProxyPort => '代理端口无效';

  @override
  String get savedRestartRequired => '已保存，需重启后生效';

  @override
  String get openListService => 'OpenList 服务';

  @override
  String get statusRunning => '状态: 运行中';

  @override
  String get statusStopped => '状态: 已停止';

  @override
  String address(Object address, Object port) {
    return '地址: http://$address:$port';
  }

  @override
  String get stop => '停止';

  @override
  String get start => '启动';

  @override
  String get managementPage => '管理页面';

  @override
  String get accessManagementPage => '访问 OpenList 管理页面：';

  @override
  String get startServiceFirst => '请先启动 OpenList 服务';

  @override
  String get openInApp => 'APP内打开';

  @override
  String get openInBrowser => '浏览器打开';

  @override
  String get adminInfo => '管理员信息';

  @override
  String saveCredentials(Object password) {
    return '请保存：\n用户名：admin\n初始密码：$password';
  }

  @override
  String get saved => '我已保存';

  @override
  String get defaultUsernameAdmin => '默认用户名：admin';

  @override
  String get resetPassword => '重置密码';

  @override
  String get stopServiceToModify => '停止服务后才可修改';

  @override
  String get serviceRunningLocked => '服务运行中，已锁定';

  @override
  String get stopServiceExitHint => '请手动停止 OpenList 后再退出软件，才能停止 OpenList';

  @override
  String get saveFailed => '保存失败';

  @override
  String get openListManagement => 'OpenList 管理';

  @override
  String get autoStartOpenListOnAppLaunch => '自动启动OpenList';

  @override
  String get autoStartOpenListDescription => '启用后，APP启动时将自动启动OpenList服务';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appName => 'JMusic';

  @override
  String get home => '首頁';

  @override
  String get library => '音樂庫';

  @override
  String get playlists => '播放清單';

  @override
  String get playlistRecommendations => '播放列表推薦';

  @override
  String get more => '更多';

  @override
  String get playVideo => '播放影片';

  @override
  String get restoreOriginalInfo => '還原原始資訊';

  @override
  String restoreOriginalInfoConfirm(Object count) {
    return '是否還原 $count 首的原始資訊？';
  }

  @override
  String restoreOriginalInfoSuccess(Object count) {
    return '已還原 $count 首';
  }

  @override
  String get restoreOriginalInfoFailed => '沒有可還原的原始資訊';

  @override
  String get batchRestore => '批量還原';

  @override
  String get sync => '同步';

  @override
  String get scraper => '刮削器';

  @override
  String get settings => '設定';

  @override
  String get clear => '清空';

  @override
  String get playingQueue => '播放佇列';

  @override
  String get language => '語言';

  @override
  String get theme => '主題';

  @override
  String get storageEvents => '存儲與緩存';

  @override
  String get coverCache => '封面緩存';

  @override
  String get clearCoverCacheConfirm => '清除封面緩存？';

  @override
  String get coverCacheCleared => '封面緩存已清除';

  @override
  String get artistAvatarCache => '歌手頭像緩存';

  @override
  String get clearArtistAvatarCacheConfirm => '清除歌手頭像緩存？';

  @override
  String get artistAvatarCacheCleared => '歌手頭像緩存已清除';

  @override
  String get embeddedCoverCache => '內嵌封面緩存';

  @override
  String get clearEmbeddedCoverCacheConfirm => '清除內嵌封面緩存？';

  @override
  String get embeddedCoverCacheCleared => '內嵌封面緩存已清除';

  @override
  String get appDataSize => '應用數據佔用';

  @override
  String get logExport => '匯出日誌';

  @override
  String get logFileSize => '日誌大小';

  @override
  String get logExported => '日誌已匯出';

  @override
  String get clearLogs => '清空日誌';

  @override
  String get clearLogsConfirm => '清空日誌？';

  @override
  String get logsCleared => '日誌已清空';

  @override
  String autoScrapeLyricsSuccess(Object title) {
    return '自動刮削成功：$title（僅歌詞）';
  }

  @override
  String autoScrapeLyricsFail(Object title) {
    return '自動刮削失敗：$title（歌詞）';
  }

  @override
  String autoScrapeFullSuccess(Object title) {
    return '自動刮削成功：$title（資訊+歌詞）';
  }

  @override
  String autoScrapeFullFail(Object title) {
    return '自動刮削失敗：$title（資訊+歌詞）';
  }

  @override
  String get syncSettings => '同步設定';

  @override
  String get serverSettings => '服務器設定';

  @override
  String get defaultPage => '默認啟動頁';

  @override
  String get scraperSettings => '刮削設定';

  @override
  String get autoScrapeOnPlayTitle => '播放時自動刮削';

  @override
  String get autoScrapeOnPlayDesc => '播放開始時於後台執行完整歌曲資訊+歌詞刮削（默認關閉）';

  @override
  String get usePrimaryArtistForScraper => '刮削僅使用主歌手';

  @override
  String get usePrimaryArtistForScraperDesc =>
      '啟用後，刮削將僅使用主歌手進行查詢；停用時會包含客席/合作歌手。';

  @override
  String get scraperMatchSources => '匹配來源';

  @override
  String get scraperSourceAtLeastOne => '請至少啟用一個來源';

  @override
  String get scraperSongSources => '歌曲刮削來源';

  @override
  String get scraperSourceQQMusic => 'QQ 音樂';

  @override
  String get scraperArtistSources => '歌手刮削來源';

  @override
  String get scraperLyricsSources => '歌詞刮削來源';

  @override
  String get audioSettings => '音頻與播放';

  @override
  String get playbackSettings => '播放設置';

  @override
  String get crossfadeEnabled => '啟用淡入淡出';

  @override
  String get crossfadeEnabledDesc => '歌曲切換時啟用淡入淡出效果，提供更流暢的聽覺體驗';

  @override
  String get crossfadeDuration => '淡入淡出時長';

  @override
  String get mute => '靜音';

  @override
  String get unmute => '取消靜音';

  @override
  String get loopingOn => '循環：開';

  @override
  String get loopingOff => '循環：關';

  @override
  String get scraperSourceLrclib => 'lrclib';

  @override
  String get scraperSourceRangotec => 'rangotec';

  @override
  String get scraperLyricsSourcesFixed => '歌詞刮削來源固定為 lrclib + rangotec';

  @override
  String get crossfadeEnabledInfo => '已啟用淡入淡出,歌曲將平滑過渡';

  @override
  String get crossfadeDisabledInfo => '淡入淡出已禁用,歌曲將直接切換';

  @override
  String get proxySettings => '網絡代理';

  @override
  String get about => '關於';

  @override
  String get themeLight => '淺色';

  @override
  String get themeDark => '深色';

  @override
  String get themeSystem => '跟隨系統';

  @override
  String get systemProxy => '系統代理';

  @override
  String get noProxy => '無代理';

  @override
  String get customProxy => '自訂代理';

  @override
  String get port => '通訊埠';

  @override
  String get ipAddress => 'IP位址';

  @override
  String get save => '儲存';

  @override
  String get recentlyPlayed => '最近播放';

  @override
  String get recentlyImported => '最近添加';

  @override
  String get toBeScraped => '待刮削';

  @override
  String get noData => '還沒有音樂，快去添加吧';

  @override
  String get scanMusic => '掃描音樂';

  @override
  String get batchScrape => '批量刮削';

  @override
  String get batchScrapeRunning => '正在後台刮削...';

  @override
  String get batchScrapeResult => '刮削報告';

  @override
  String successCount(Object count) {
    return '成功: $count';
  }

  @override
  String failCount(Object count) {
    return '失敗: $count';
  }

  @override
  String get confirm => '確定';

  @override
  String get cancel => '取消';

  @override
  String get delete => '刪除';

  @override
  String get editTags => '編輯標籤';

  @override
  String get addToPlaylist => '添加到播放清單';

  @override
  String get playAll => '播放全部';

  @override
  String get play => '播放';

  @override
  String deleteConfirm(Object count) {
    return '確認刪除這 $count 首歌曲嗎？';
  }

  @override
  String deleteSingleConfirm(Object title) {
    return '確認刪除 \"$title\" 嗎？';
  }

  @override
  String get importMusic => '導入音樂';

  @override
  String get manualSync => '手動同步';

  @override
  String get developing => '功能開發中';

  @override
  String get importInLibrary => '請到音樂庫進行導入';

  @override
  String get homeTitle => '首頁';

  @override
  String get importMusicTooltip => '導入音樂';

  @override
  String get syncFeatureDeveloping => '同步功能開發中';

  @override
  String get noMusicData => '暫無數據\n請先前往資料庫導入音樂';

  @override
  String get scrapedCompletedTitle => '批量刮削完成';

  @override
  String totalTasks(Object count) {
    return '總計任務: $count';
  }

  @override
  String get hide => '隱藏';

  @override
  String get createPlaylist => '新建播放清單';

  @override
  String get noPlaylists => '暫無播放清單';

  @override
  String get playlistTitle => '播放清單';

  @override
  String get confirmDelete => '確認刪除?';

  @override
  String get edit => '編輯';

  @override
  String get playlistName => '播放清單名稱';

  @override
  String get playlistNameHint => '我的最愛';

  @override
  String get create => '創建';

  @override
  String songCount(Object count) {
    return '$count 首歌曲';
  }

  @override
  String addedToPlaylist(Object name) {
    return '已添加到 \"$name\"';
  }

  @override
  String songsAlreadyInPlaylist(Object playlistName) {
    return '已存在於 \"$playlistName\"';
  }

  @override
  String get syncCenter => '同步中心';

  @override
  String get addSyncAccount => '新增同步賬號';

  @override
  String get openListNotSupported => 'OpenList 暫未支持';

  @override
  String get noSyncAccount => '暫無同步賬號';

  @override
  String get addSyncAccountHint => '點擊右上角 + 號添加 WebDAV 或 Alist 賬號';

  @override
  String get connected => '已連接';

  @override
  String get paused => '已暫停';

  @override
  String get accountName => '賬戶名稱';

  @override
  String get removeSyncConfigConfirm => '這將移除此同步源配置';

  @override
  String get checkSyncNow => '同步';

  @override
  String get searchUnarchived => '搜索未歸檔歌曲...';

  @override
  String selectedCount(Object count) {
    return '$count 已選擇';
  }

  @override
  String get scraperCenter => '刮削中心';

  @override
  String get scraperCategoryAll => '全部問題';

  @override
  String get scraperCategoryUnscraped => '未刮削';

  @override
  String get scraperCategoryScraped => '已刮削';

  @override
  String get scraperCategoryHasLyrics => '有歌詞';

  @override
  String get scraperCategoryNoLyrics => '無歌詞';

  @override
  String get scraperCategoryMissingCover => '缺少封面';

  @override
  String get scraperCategoryMissingInfo => '缺失基本資訊';

  @override
  String get scraperSourceMusicBrainz => 'MusicBrainz';

  @override
  String get scraperSourceItunes => 'iTunes';

  @override
  String scraperSourceLabel(Object source) {
    return '來源：$source';
  }

  @override
  String get viewOriginalInfo => '查看原始資訊';

  @override
  String get clearLyrics => '清除歌詞';

  @override
  String get clearSongInfo => '清除歌曲資訊';

  @override
  String get restoreArtistAvatar => '恢復歌手頭像';

  @override
  String get refresh => '刷新';

  @override
  String get taskRunningBackground => '任務已後台運行';

  @override
  String get unknownArtist => '未知藝術家';

  @override
  String get unknownAlbum => '未知專輯';

  @override
  String get nowPlaying => '正在播放';

  @override
  String get manualMatchMetadata => '手動匹配元數據';

  @override
  String get lyricsComingSoon => '歌詞功能即將上線...';

  @override
  String get lyricsModeOff => '歌詞：關閉';

  @override
  String get lyricsModeCompact => '歌詞：封面下方';

  @override
  String get lyricsModeFull => '歌詞：全螢幕顯示';

  @override
  String get noLyricsFound => '未找到歌詞';

  @override
  String get syncCenterSubtitle => '手動同步與差異檢查';

  @override
  String get scraperCenterSubtitle => '手動刮削與候選確認';

  @override
  String get settingsSubtitle => '存儲、音頻、同步與刮削策略';

  @override
  String get deletePlaylist => '刪除播放清單';

  @override
  String confirmDeletePlaylist(Object name) {
    return '確定要刪除 \"$name\"?';
  }

  @override
  String get clearPlaylist => '清空播放清單';

  @override
  String confirmClearPlaylist(Object name) {
    return '確定要清空 \"$name\" 的所有歌曲嗎?';
  }

  @override
  String get rename => '重新命名';

  @override
  String get importCover => '匯入封面';

  @override
  String get coverImported => '封面已匯入';

  @override
  String get clearCover => '清空封面';

  @override
  String confirmClearCover(Object name) {
    return '確定要清空 \"$name\" 的封面嗎?';
  }

  @override
  String get emptyPlaylist => '播放清單為空';

  @override
  String playbackError(Object error) {
    return '無法開始播放：$error';
  }

  @override
  String get selectAll => '全選 / 取消全選';

  @override
  String get search => '搜尋';

  @override
  String get noMatchingSongs => '沒有找到匹配的歌曲';

  @override
  String get allSongsScraped => '恭喜，所有歌曲都已刮削！';

  @override
  String foundUnscrapedSongs(Object count) {
    return '發現 $count 首未刮削的歌曲';
  }

  @override
  String get deleteSongs => '刪除歌曲';

  @override
  String confirmDeleteSongs(Object count) {
    return '刪除 $count 首選中的歌曲?\n(只會從音樂庫移除，檔案保留)';
  }

  @override
  String songsDeleted(Object count) {
    return '已刪除 $count 首歌曲';
  }

  @override
  String addedToQueue(Object count) {
    return '已將 $count 首歌曲添加到佇列';
  }

  @override
  String get pleaseSelectDetailed => '請先選擇要刮削的歌曲';

  @override
  String get batchScrapeStarted => '批量刮削任務已啟動';

  @override
  String get scrapeLyrics => '刮削歌詞';

  @override
  String get scrapeLyricsStarted => '開始刮削歌詞';

  @override
  String get scanning => '掃描中...';

  @override
  String addedCompSongs(Object count) {
    return '已添加 $count 首歌曲';
  }

  @override
  String get processingFiles => '正在處理拖入的檔案...';

  @override
  String importedSongs(Object count) {
    return '已導入 $count 首歌曲';
  }

  @override
  String get addFolder => '添加資料夾';

  @override
  String get emptyLibrary => '音樂庫為空';

  @override
  String get addMusicFolder => '添加音樂資料夾';

  @override
  String get unknown => '未知';

  @override
  String get noItemsFound => '沒有找到項目';

  @override
  String searchViewType(Object viewType) {
    return '搜尋 $viewType...';
  }

  @override
  String get forYou => '為你推薦';

  @override
  String get viewDetails => '查看詳情';

  @override
  String get songDetails => '歌曲詳情';

  @override
  String get filePath => '檔案路徑';

  @override
  String get fileName => '檔案名稱';

  @override
  String get duration => '時長';

  @override
  String get size => '大小';

  @override
  String get dateAdded => '添加日期';

  @override
  String get lastPlayed => '最後播放';

  @override
  String get genre => '流派';

  @override
  String get year => '年份';

  @override
  String get trackNumber => '音軌號';

  @override
  String get discNumber => '碟號';

  @override
  String get lyrics => '歌詞';

  @override
  String get copyToClipboard => '複製到剪貼簿';

  @override
  String get fullPath => '完整路徑';

  @override
  String get webdav => 'WebDAV';

  @override
  String get openlist => 'OpenList';

  @override
  String get webdavConfigTitle => 'WebDAV 配置';

  @override
  String get webdavUrlLabel => 'WebDAV URL (例如 https://dav.example.com)';

  @override
  String get keepAliveTitle => '保活';

  @override
  String get keepAliveDescription => '若熄屏時連線中斷，請在系統設定中允許應用自動啟動。';

  @override
  String get openAutoStart => '開啟自動啟動設定';

  @override
  String get username => '用戶名';

  @override
  String get password => '密碼';

  @override
  String get musicFolderPath => '音樂文件夾路徑 (例如 /Music)';

  @override
  String get identify => '識別';

  @override
  String get identificationRules => '識別規則';

  @override
  String get rulesTooltip => '規則：藝術家/專輯/歌曲 或 文件名';

  @override
  String scanComplete(Object count) {
    return '掃描完成。識別了 $count 首歌曲。';
  }

  @override
  String scanError(Object error) {
    return '錯誤：$error';
  }

  @override
  String get permissionDenied => '存儲權限被拒絕';

  @override
  String scanningFile(Object fileName) {
    return '正在掃描: $fileName';
  }

  @override
  String get sourceLocal => '本地';

  @override
  String get sourceCloud => '雲端';

  @override
  String get webdavAccountsCache => 'WebDAV 賬戶緩存';

  @override
  String clearCacheForAccount(Object accountName) {
    return '清除 $accountName 的緩存？';
  }

  @override
  String get accountCacheCleared => '賬戶緩存已清除';

  @override
  String get clearLegacyCache => '清除所有舊版緩存的 WebDAV 歌曲？';

  @override
  String get legacyCacheCleared => '舊版緩存已清除';

  @override
  String get clearCache => '清除緩存';

  @override
  String get scrapeAgain => '重新刮削';

  @override
  String songDeletedWithTitle(Object title) {
    return '已刪除 \"$title\"';
  }

  @override
  String cacheClearedWithTitle(Object title) {
    return '已清除 \"$title\" 的緩存';
  }

  @override
  String cannotAccessSong(Object title) {
    return '無法訪問歌曲文件：$title';
  }

  @override
  String get addedToFavorites => '已添加到收藏';

  @override
  String get removedFromFavorites => '已從收藏中移除';

  @override
  String get favoritesPlaylistName => '收藏';

  @override
  String get favoritesPlaylistDescription => '我喜歡的歌曲';

  @override
  String playlistAlreadyExists(Object playlistName) {
    return '名為 \"$playlistName\" 的播放清單已存在';
  }

  @override
  String get resetAdminPasswordTitle => '重置管理員密碼';

  @override
  String get resetFailed => '重置失敗';

  @override
  String get unknownError => '未知錯誤';

  @override
  String get newPasswordGenerated => '新密碼已生成';

  @override
  String get usernameAdmin => '用戶名：admin';

  @override
  String newPassword(Object pwd) {
    return '新密碼：$pwd';
  }

  @override
  String get portAndProxy => '通訊埠與代理';

  @override
  String get invalidPort => '通訊埠無效';

  @override
  String get proxyHostEmpty => '代理位址不能為空';

  @override
  String get invalidProxyPort => '代理通訊埠無效';

  @override
  String get savedRestartRequired => '已儲存，需重啟後生效';

  @override
  String get openListService => 'OpenList 服務';

  @override
  String get statusRunning => '狀態: 運行中';

  @override
  String get statusStopped => '狀態: 已停止';

  @override
  String address(Object address, Object port) {
    return '位址: http://$address:$port';
  }

  @override
  String get stop => '停止';

  @override
  String get start => '啟動';

  @override
  String get managementPage => '管理頁面';

  @override
  String get accessManagementPage => '訪問 OpenList 管理頁面：';

  @override
  String get startServiceFirst => '請先啟動 OpenList 服務';

  @override
  String get openInApp => 'APP內打開';

  @override
  String get openInBrowser => '瀏覽器打開';

  @override
  String get adminInfo => '管理員資訊';

  @override
  String saveCredentials(Object password) {
    return '請儲存：\n用戶名：admin\n初始密碼：$password';
  }

  @override
  String get saved => '我已儲存';

  @override
  String get defaultUsernameAdmin => '預設用戶名：admin';

  @override
  String get resetPassword => '重置密碼';

  @override
  String get stopServiceToModify => '停止服務後才可修改';

  @override
  String get serviceRunningLocked => '服務運行中，已鎖定';

  @override
  String get stopServiceExitHint => '請手動停止 OpenList 後再退出軟體，才能停止 OpenList';

  @override
  String get saveFailed => '儲存失敗';

  @override
  String get openListManagement => 'OpenList 管理';

  @override
  String get autoStartOpenListOnAppLaunch => '自動啟動OpenList';

  @override
  String get autoStartOpenListDescription => '啟用後，APP啟動時將自動啟動OpenList服務';
}
