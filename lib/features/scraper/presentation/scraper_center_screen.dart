import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/widgets/capsule_toast.dart';
import 'package:jmusic/core/widgets/bottom_action_sheet.dart';
import 'package:jmusic/core/widgets/cover_art.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';
import 'package:jmusic/features/music_lib/domain/entities/artist.dart';
import 'package:jmusic/features/scraper/presentation/scraper_providers.dart';
import 'package:jmusic/features/scraper/presentation/scraper_search_dialog.dart';
import 'package:jmusic/features/scraper/presentation/scraper_lyrics_match_dialog.dart';
import 'package:jmusic/features/scraper/presentation/batch_scraper_service.dart';
import 'package:jmusic/core/services/preferences_service.dart';
import 'package:jmusic/features/player/presentation/player_providers.dart';
import 'package:jmusic/features/music_lib/presentation/tag_editor_dialog.dart';
import 'package:jmusic/features/music_lib/presentation/widgets/song_details_dialog.dart';
import 'package:jmusic/core/services/database_service.dart';
import 'package:jmusic/features/scraper/presentation/artist_search_dialog.dart';
import 'package:jmusic/l10n/app_localizations.dart';
import 'package:isar/isar.dart';

class ScraperCenterScreen extends ConsumerStatefulWidget {
  const ScraperCenterScreen({super.key});

  @override
  ConsumerState<ScraperCenterScreen> createState() =>
      _ScraperCenterScreenState();
}

class _ScraperCenterScreenState extends ConsumerState<ScraperCenterScreen> {
  final Set<int> _selectedIds = {};
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  TabController? _tabController;
  int _activeTabIndex = 0;
  final Map<String, String?> _artistAvatarMap = {};
  final Map<String, String> _artistSourceMap = {};
  StreamSubscription<List<Artist>>? _artistSub;

  String _searchQuery = '';
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      if (!_searchFocus.hasFocus && _showSearch) {
        setState(() => _showSearch = false);
      }
    });
    _watchArtists();
  }

  Future<void> _watchArtists() async {
    final db = await ref.read(databaseServiceProvider).db;
    _artistSub?.cancel();
    _artistSub =
        db.artists.where().watch(fireImmediately: true).listen((artists) {
      if (!mounted) return;
      final map = <String, String?>{};
      final sourceMap = <String, String>{};
      for (final artist in artists) {
        String? path;
        final local = artist.localImagePath;
        if (local != null && local.isNotEmpty) {
          final file = File(local);
          if (file.existsSync()) {
            path = local;
          }
        }
        path ??= artist.imageUrl;
        if (path != null && path.isNotEmpty) {
          map[artist.name] = path;
        }
        final mbId = artist.musicBrainzId;
        final imageUrl = artist.imageUrl ?? '';
        if (mbId != null && mbId.trim().isNotEmpty) {
          sourceMap[artist.name] = 'musicbrainz';
        } else if (imageUrl.contains('mzstatic')) {
          sourceMap[artist.name] = 'itunes';
        }
      }
      setState(() {
        _artistAvatarMap
          ..clear()
          ..addAll(map);
        _artistSourceMap
          ..clear()
          ..addAll(sourceMap);
      });
    });
  }

  void _handleTabChange() {
    if (!mounted) return;
    setState(() {
      _activeTabIndex = _tabController?.index ?? 0;
    });
  }

  void _attachTabController(BuildContext context) {
    final controller = DefaultTabController.maybeOf(context);
    if (controller != null && controller != _tabController) {
      _tabController?.removeListener(_handleTabChange);
      _tabController = controller;
      _activeTabIndex = controller.index;
      controller.addListener(_handleTabChange);
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabChange);
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _artistSub?.cancel();
    super.dispose();
  }

  bool get _isSelectionMode => _selectedIds.isNotEmpty;

  static const _tabs = [
    _ScraperTab.unscraped,
    _ScraperTab.scraped,
    _ScraperTab.hasLyrics,
    _ScraperTab.noLyrics,
    _ScraperTab.missingInfo,
    _ScraperTab.artists,
  ];

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
    });
  }

  void _selectAll(List<Song> songs) {
    final ids = songs.map((e) => e.id).toSet();
    final selectedInList = _selectedIds.intersection(ids).length;
    setState(() {
      if (ids.isEmpty) return;
      if (selectedInList == ids.length) {
        _selectedIds.removeAll(ids);
      } else {
        _selectedIds.addAll(ids);
      }
    });
  }

  void _showSelectionActionsSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Determine allowed batch actions based on current tab
    final tab = _currentTab();
    final actions = <ActionItem>[];

    if (tab == _ScraperTab.unscraped ||
        tab == _ScraperTab.scraped ||
        tab == _ScraperTab.missingInfo) {
      actions.add(ActionItem(
          icon: Icons.auto_fix_high,
          title: l10n.batchScrape,
          onTap: _scrapeSelected));
    }

    if (tab == _ScraperTab.noLyrics ||
        tab == _ScraperTab.hasLyrics ||
        tab == _ScraperTab.missingInfo ||
        tab == _ScraperTab.unscraped ||
        tab == _ScraperTab.scraped) {
      actions.add(ActionItem(
          icon: Icons.music_note,
          title: l10n.scrapeLyrics,
          onTap: () async {
            final notifier = ref.read(batchScraperProvider.notifier);
            final ids = _selectedIds.toList();
            notifier.startBatchLyricsScrape(ids);
            if (mounted) {
              CapsuleToast.show(context, l10n.scrapeLyricsStarted);
              _clearSelection();
            }
          }));
    }

    BottomActionSheet.show(context,
        title: l10n.selectedCount(_selectedIds.length), actions: actions);
  }

  Future<void> _scrapeSelectedArtists() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedIds.isEmpty) return;
    final db = await ref.read(databaseServiceProvider).db;
    final songsNullable = await db.songs.getAll(_selectedIds.toList());
    final songs = songsNullable.whereType<Song>().toList();
    if (songs.isEmpty) return;
    final ok = await ref
        .read(artistScraperControllerProvider)
        .scrapeArtistsForSongs(songs);
    if (mounted) {
      CapsuleToast.show(context, l10n.scrapeArtistAvatarsResult(ok));
      _clearSelection();
    }
  }

  Future<void> _restoreSelected() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedIds.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.restoreOriginalInfo),
        content: Text(l10n.restoreOriginalInfoConfirm(_selectedIds.length)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.confirm)),
        ],
      ),
    );

    if (confirmed == true) {
      final restored = await ref
          .read(scraperControllerProvider)
          .restoreSongsMetadata(_selectedIds.toList());
      _clearSelection();
      if (mounted) {
        CapsuleToast.show(
            context,
            restored > 0
                ? l10n.restoreOriginalInfoSuccess(restored)
                : l10n.restoreOriginalInfoFailed);
      }
    }
  }

  Future<void> _editSelectedTags() async {
    final db = await ref.read(databaseServiceProvider).db;
    // getAll returns List<Song?> so need to filter nulls
    final songsNullable = await db.songs.getAll(_selectedIds.toList());
    final songs = songsNullable.whereType<Song>().toList();

    if (songs.isNotEmpty) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => TagEditorDialog(songs: songs),
        );
        _clearSelection();
      }
    }
  }

  void _scrapeSelected() {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedIds.isEmpty) {
      if (mounted) CapsuleToast.show(context, l10n.pleaseSelectDetailed);
      return;
    }

    final prefs = ref.read(preferencesServiceProvider);
    if (!prefs.scraperSourceMusicBrainz && !prefs.scraperSourceItunes) {
      if (mounted) CapsuleToast.show(context, l10n.scraperSourceAtLeastOne);
      return;
    }

    final notifier = ref.read(batchScraperProvider.notifier);
    if (ref.read(batchScraperProvider).isRunning) {
      if (mounted) CapsuleToast.show(context, l10n.batchScrapeRunning);
      return;
    }

    // 开始任务
    notifier.startBatchScrape(_selectedIds.toList());

    if (mounted) {
      setState(() {
        _selectedIds.clear();
      });
      CapsuleToast.show(context, l10n.batchScrapeStarted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final songsAsync = ref.watch(scraperCandidatesProvider);
    final l10n = AppLocalizations.of(context)!;
    final prefs = ref.watch(preferencesServiceProvider);

    return DefaultTabController(
      length: _tabs.length,
      child: Builder(
        builder: (innerContext) {
          _attachTabController(innerContext);
          return Scaffold(
            appBar: AppBar(
              leading: _isSelectionMode
                  ? IconButton(
                      icon: const Icon(Icons.close), onPressed: _clearSelection)
                  : null,
              title: _showSearch
                  ? TextField(
                      controller: _searchCtrl,
                      focusNode: _searchFocus,
                      decoration: InputDecoration(
                        hintText: l10n.searchUnarchived,
                        border: InputBorder.none,
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    )
                  : Text(_isSelectionMode
                      ? l10n.selectedCount(_selectedIds.length)
                      : l10n.scraperCenter),
              actions: _isSelectionMode
                  ? [
                      IconButton(
                        icon: const Icon(Icons.select_all),
                        onPressed: () {
                          final songs = songsAsync.value;
                          if (songs == null) return;
                          final filtered =
                              _filterSongs(songs, _currentTab(), prefs);
                          _selectAll(filtered);
                        },
                        tooltip: l10n.selectAll,
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () => _showSelectionActionsSheet(context),
                        tooltip: l10n.more,
                      ),
                    ]
                  : [
                      if (!_showSearch)
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            setState(() => _showSearch = true);
                            WidgetsBinding.instance.addPostFrameCallback(
                                (_) => _searchFocus.requestFocus());
                          },
                          tooltip: l10n.search,
                        ),
                    ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(44),
                child: songsAsync.when(
                  data: (songs) {
                    final counts = _buildCounts(songs, prefs);
                    return TabBar(
                      isScrollable: true,
                      tabs: [
                        Tab(
                            text:
                                '${l10n.scraperCategoryUnscraped} (${counts[_ScraperTab.unscraped]})'),
                        Tab(
                            text:
                                '${l10n.scraperCategoryScraped} (${counts[_ScraperTab.scraped]})'),
                        Tab(
                            text:
                                '${l10n.scraperCategoryHasLyrics} (${counts[_ScraperTab.hasLyrics]})'),
                        Tab(
                            text:
                                '${l10n.scraperCategoryNoLyrics} (${counts[_ScraperTab.noLyrics]})'),
                        Tab(
                            text:
                                '${l10n.scraperCategoryMissingInfo} (${counts[_ScraperTab.missingInfo]})'),
                        Tab(
                            text:
                                '${l10n.scraperCategoryArtists} (${counts[_ScraperTab.artists]})'),
                      ],
                    );
                  },
                  loading: () => const SizedBox(height: 44),
                  error: (_, __) => const SizedBox(height: 44),
                ),
              ),
            ),
            body: songsAsync.when(
              data: (songs) {
                return TabBarView(
                  children: _tabs
                      .map(
                          (tab) => _buildListForTab(context, songs, tab, prefs))
                      .toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          );
        },
      ),
    );
  }

  _ScraperTab _currentTab() {
    return _tabs[_activeTabIndex.clamp(0, _tabs.length - 1)];
  }

  Map<_ScraperTab, int> _buildCounts(
      List<Song> songs, PreferencesService prefs) {
    return {
      _ScraperTab.unscraped:
          _filterByIssue(songs, _ScraperTab.unscraped, prefs).length,
      _ScraperTab.scraped:
          _filterByIssue(songs, _ScraperTab.scraped, prefs).length,
      _ScraperTab.hasLyrics:
          _filterByIssue(songs, _ScraperTab.hasLyrics, prefs).length,
      _ScraperTab.noLyrics:
          _filterByIssue(songs, _ScraperTab.noLyrics, prefs).length,
      _ScraperTab.missingInfo:
          _filterByIssue(songs, _ScraperTab.missingInfo, prefs).length,
      _ScraperTab.artists: _buildArtistItems(songs).length,
    };
  }

  Widget _buildListForTab(BuildContext context, List<Song> songs,
      _ScraperTab tab, PreferencesService prefs) {
    final l10n = AppLocalizations.of(context)!;
    if (tab == _ScraperTab.artists) {
      final artists = _buildArtistItems(songs);
      final filtered = _searchQuery.isEmpty
          ? artists
          : artists
              .where((a) =>
                  a.name.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();
      if (filtered.isEmpty) {
        return Center(child: Text(l10n.noMatchingSongs));
      }
      return ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final item = filtered[index];
          final avatar = _artistAvatarMap[item.name];
          final sourceKey = _artistSourceMap[item.name];
          final sourceLabel = sourceKey == 'musicbrainz'
              ? l10n.scraperSourceMusicBrainz
              : sourceKey == 'itunes'
                  ? l10n.scraperSourceItunes
                  : null;
          return ListTile(
            leading: ClipOval(
              child: SizedBox(
                width: 44,
                height: 44,
                child:
                    CoverArt(path: avatar, fit: BoxFit.cover, isVideo: false),
              ),
            ),
            title: Text(item.name,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.songCount(item.count),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
                if (sourceLabel != null)
                  Text(
                    l10n.scraperSourceLabel(sourceLabel),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ArtistSearchDialog(artistName: item.name, asPage: true),
                ),
              );
            },
            onLongPress: () => _showArtistActions(context, item.name),
          );
        },
      );
    }
    final filteredSongs = _filterSongs(songs, tab, prefs);

    if (filteredSongs.isEmpty) {
      if (_searchQuery.isNotEmpty) {
        return Center(child: Text(l10n.noMatchingSongs));
      }
      final emptyText = tab == _ScraperTab.unscraped
          ? l10n.allSongsScraped
          : l10n.noMatchingSongs;
      return Center(
        child: Text(
          emptyText,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredSongs.length,
      itemBuilder: (context, index) {
        final song = filteredSongs[index];
        final isSelected = _selectedIds.contains(song.id);

        return ListTile(
          leading: _isSelectionMode
              ? Checkbox(
                  value: isSelected,
                  onChanged: (v) => _toggleSelection(song.id))
              : ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: CoverArt(
                        path: song.coverPath,
                        fit: BoxFit.cover,
                        isVideo: song.mediaType == MediaType.video),
                  ),
                ),
          title: Text(
            song.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.normal,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          subtitle: Text(
            '${song.artists.isNotEmpty ? song.artists.join(' / ') : song.artist} - ${song.album}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          selected: isSelected,
          onLongPress: () {
            _toggleSelection(song.id);
          },
          onTap: () {
            if (_isSelectionMode) {
              _toggleSelection(song.id);
            } else {
              _openManualMatch(context, song, tab);
            }
          },
          trailing: _isSelectionMode
              ? null
              : IconButton(
                  icon: const Icon(Icons.more_vert),
                  tooltip: l10n.more,
                  onPressed: () => _showItemActions(context, song, tab),
                ),
        );
      },
    );
  }

  List<_ArtistItem> _buildArtistItems(List<Song> songs) {
    final map = <String, int>{};
    for (final song in songs) {
      final names = song.artists.isNotEmpty ? song.artists : [song.artist];
      for (final name in names) {
        if (_isUnknownOrEmpty(name)) continue;
        map[name] = (map[name] ?? 0) + 1;
      }
    }
    final list = map.entries
        .map((e) => _ArtistItem(name: e.key, count: e.value))
        .toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  void _showArtistActions(BuildContext context, String artistName) {
    final l10n = AppLocalizations.of(context)!;
    BottomActionSheet.show(
      context,
      title: artistName,
      actions: [
        ActionItem(
          icon: Icons.person_search,
          title: l10n.manualMatchArtist,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ArtistSearchDialog(artistName: artistName, asPage: true),
              ),
            );
          },
        ),
        ActionItem(
          icon: Icons.restore,
          title: l10n.restoreArtistAvatar,
          onTap: () async {
            final ok = await ref
                .read(artistScraperControllerProvider)
                .scrapeArtist(artistName, force: true);
            if (mounted) {
              CapsuleToast.show(
                  context, l10n.scrapeArtistAvatarsResult(ok ? 1 : 0));
            }
          },
        ),
      ],
    );
  }

  void _showItemActions(BuildContext context, Song song, _ScraperTab tab) {
    final l10n = AppLocalizations.of(context)!;
    final actions = <ActionItem>[];
    if (tab == _ScraperTab.hasLyrics || tab == _ScraperTab.noLyrics) {
      actions.addAll([
        ActionItem(
          icon: Icons.play_arrow,
          title: l10n.play,
          onTap: () async {
            await ref.read(playerControllerProvider).playSingle(song);
          },
        ),
        ActionItem(
          icon: Icons.music_note,
          title: l10n.manualMatchLyrics,
          onTap: () => _openLyricsMatch(context, song),
        ),
        ActionItem(
          icon: Icons.delete_outline,
          title: l10n.clearLyrics,
          onTap: () => _confirmClearLyrics(context, song),
        ),
        ActionItem(
          icon: Icons.info_outline,
          title: l10n.viewDetails,
          onTap: () => showDialog(
            context: context,
            builder: (_) => SongDetailsDialog(song: song),
          ),
        ),
      ]);
    } else if (tab == _ScraperTab.missingInfo) {
      actions.addAll([
        ActionItem(
          icon: Icons.play_arrow,
          title: l10n.play,
          onTap: () async {
            await ref.read(playerControllerProvider).playSingle(song);
          },
        ),
        ActionItem(
          icon: Icons.auto_fix_high,
          title: l10n.manualMatchMetadata,
          onTap: () => _openMetadataMatch(context, song, includeLyrics: false),
        ),
        ActionItem(
          icon: Icons.delete_outline,
          title: l10n.clearSongInfo,
          onTap: () => _confirmClearBasicInfo(context, song),
        ),
        ActionItem(
          icon: Icons.info_outline,
          title: l10n.viewDetails,
          onTap: () => showDialog(
            context: context,
            builder: (_) => SongDetailsDialog(song: song),
          ),
        ),
      ]);
    } else {
      actions.addAll([
        ActionItem(
          icon: Icons.play_arrow,
          title: l10n.play,
          onTap: () async {
            await ref.read(playerControllerProvider).playSingle(song);
          },
        ),
        ActionItem(
          icon: Icons.auto_fix_high,
          title: l10n.manualMatchMetadata,
          onTap: () => _openMetadataMatch(context, song, includeLyrics: true),
        ),
        ActionItem(
          icon: Icons.music_note,
          title: l10n.manualMatchLyrics,
          onTap: () => _openLyricsMatch(context, song),
        ),
        ActionItem(
          icon: Icons.edit,
          title: l10n.editTags,
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => TagEditorDialog(songs: [song]),
            );
          },
        ),
        ActionItem(
          icon: Icons.info_outline,
          title: l10n.viewDetails,
          onTap: () => showDialog(
            context: context,
            builder: (_) => SongDetailsDialog(song: song),
          ),
        ),
      ]);
    }

    BottomActionSheet.show(context, title: song.title, actions: actions);
  }

  void _openManualMatch(BuildContext context, Song song, _ScraperTab tab) {
    if (tab == _ScraperTab.hasLyrics || tab == _ScraperTab.noLyrics) {
      _openLyricsMatch(context, song);
      return;
    }
    if (tab == _ScraperTab.missingInfo) {
      _openMetadataMatch(context, song, includeLyrics: false);
      return;
    }
    _openMetadataMatch(context, song, includeLyrics: true);
  }

  void _openLyricsMatch(BuildContext context, Song song) {
    final useDialog = MediaQuery.of(context).size.width >= 600;
    if (useDialog) {
      showDialog(
        context: context,
        builder: (_) => ScraperLyricsMatchDialog(song: song, asPage: false),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ScraperLyricsMatchDialog(song: song, asPage: true),
        ),
      );
    }
  }

  void _openMetadataMatch(BuildContext context, Song song,
      {required bool includeLyrics}) {
    final useDialog = MediaQuery.of(context).size.width >= 600;
    if (useDialog) {
      showDialog(
        context: context,
        builder: (_) => ScraperSearchDialog(
          song: song,
          asPage: false,
          includeLyrics: includeLyrics,
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ScraperSearchDialog(
            song: song,
            asPage: true,
            includeLyrics: includeLyrics,
          ),
        ),
      );
    }
  }

  Future<void> _confirmClearLyrics(BuildContext context, Song song) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearLyrics),
        content: Text(l10n.confirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.confirm)),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(scraperControllerProvider).clearLyrics(song.id);
      if (mounted) {
        CapsuleToast.show(context, l10n.clearLyrics);
      }
    }
  }

  Future<void> _confirmClearBasicInfo(BuildContext context, Song song) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearSongInfo),
        content: Text(l10n.confirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.confirm)),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(scraperControllerProvider).clearBasicInfo(song.id);
      if (mounted) {
        CapsuleToast.show(context, l10n.clearSongInfo);
      }
    }
  }



  List<Song> _filterSongs(
      List<Song> songs, _ScraperTab tab, PreferencesService prefs) {
    final base = _filterByIssue(songs, tab, prefs);
    if (_searchQuery.isEmpty) return base;
    final q = _searchQuery.toLowerCase();
    return base
        .where((s) =>
            s.title.toLowerCase().contains(q) ||
            (s.artist.toLowerCase().contains(q)) ||
            (s.artists.any((a) => a.toLowerCase().contains(q))) ||
            (s.album.toLowerCase().contains(q)))
        .toList();
  }

  bool _isUnknownOrEmpty(String? value) {
    if (value == null) return true;
    final v = value.trim();
    if (v.isEmpty) return true;
    final lower = v.toLowerCase();
    if (lower.contains('unknown') || lower.contains('unknow')) return true;
    if (v.contains('未知')) return true;
    return false;
  }

  bool _hasKnownArtist(Song song) {
    if (song.artists.isNotEmpty) {
      return song.artists.any((a) => !_isUnknownOrEmpty(a));
    }
    return !_isUnknownOrEmpty(song.artist);
  }

  bool _hasScrapeRecord(Song song, PreferencesService prefs) {
    final backup = prefs.getScrapeBackup(song.id);
    if (backup != null) return true;
    final mbId = song.musicBrainzId;
    return mbId != null && mbId.trim().isNotEmpty;
  }

  bool _missingCover(Song song) =>
      song.coverPath == null || song.coverPath!.trim().isEmpty;

  bool _missingLyrics(Song song) =>
      song.lyrics == null || song.lyrics!.trim().isEmpty;

  bool _hasLyrics(Song song) => !_missingLyrics(song);

  bool _missingInfo(Song song) =>
      !_hasKnownArtist(song) || _isUnknownOrEmpty(song.album);

  bool _missingBasicInfo(Song song) =>
      _missingCover(song) || _missingInfo(song);

  List<Song> _filterByIssue(
      List<Song> songs, _ScraperTab tab, PreferencesService prefs) {
    switch (tab) {
      case _ScraperTab.unscraped:
        return songs.where((s) => !_hasScrapeRecord(s, prefs)).toList();
      case _ScraperTab.scraped:
        return songs.where((s) => _hasScrapeRecord(s, prefs)).toList();
      case _ScraperTab.hasLyrics:
        return songs.where(_hasLyrics).toList();
      case _ScraperTab.noLyrics:
        return songs.where(_missingLyrics).toList();
      case _ScraperTab.missingInfo:
      default:
        return songs.where(_missingBasicInfo).toList();
    }
  }
}

enum _ScraperTab {
  unscraped,
  scraped,
  hasLyrics,
  noLyrics,
  missingInfo,
  artists
}

class _ArtistItem {
  final String name;
  final int count;

  const _ArtistItem({required this.name, required this.count});
}
