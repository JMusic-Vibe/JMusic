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
  String get more => '更多';

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
  String get syncSettings => '同步设置';

  @override
  String get serverSettings => '服务器设置';

  @override
  String get defaultPage => '默认启动页';

  @override
  String get scraperSettings => '刮削设置';

  @override
  String get usePrimaryArtistForScraper => '刮削仅使用主歌手';

  @override
  String get usePrimaryArtistForScraperDesc =>
      '启用后，刮削将仅使用主歌手进行查询；禁用时会包含客座/合作歌手。';

  @override
  String get audioSettings => '音频与播放';

  @override
  String get playbackSettings => '播放设置';

  @override
  String get crossfadeEnabled => '启用淡入淡出';

  @override
  String get crossfadeEnabledDesc => '歌曲切换时启用淡入淡出效果，提供更流畅的听觉体验';

  @override
  String get crossfadeDuration => '淡入淡出时长';

  @override
  String get crossfadeDurationDesc => '设置歌曲间淡入淡出效果的持续时间';

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
  String get openListNotSupported => 'OpenAList 暂未支持';

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
  String get lyricsComingSoon => '歌词功能即将上线...';

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
  String get openalist => 'OpenAList';

  @override
  String get webdavConfigTitle => 'WebDAV 配置';

  @override
  String get webdavUrlLabel => 'WebDAV URL (例如 https://dav.example.com)';

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
  String songDeletedWithTitle(Object title) {
    return '已删除 \"$title\"';
  }

  @override
  String cacheClearedWithTitle(Object title) {
    return '已清除 \"$title\" 的缓存';
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
  String get more => '更多';

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
  String get syncSettings => '同步設定';

  @override
  String get serverSettings => '服務器設定';

  @override
  String get defaultPage => '默認啟動頁';

  @override
  String get scraperSettings => '刮削設定';

  @override
  String get usePrimaryArtistForScraper => '刮削僅使用主歌手';

  @override
  String get usePrimaryArtistForScraperDesc =>
      '啟用後，刮削將僅使用主歌手進行查詢；停用時會包含客席/合作歌手。';

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
  String get openListNotSupported => 'OpenAList 暫未支持';

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
  String get openalist => 'OpenAList';

  @override
  String get webdavConfigTitle => 'WebDAV 配置';

  @override
  String get webdavUrlLabel => 'WebDAV URL (例如 https://dav.example.com)';

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
}
