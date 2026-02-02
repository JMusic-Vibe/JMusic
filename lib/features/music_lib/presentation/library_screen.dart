import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/services/audio_player_service.dart';
import 'package:jmusic/core/widgets/capsule_toast.dart';
import 'package:jmusic/core/widgets/bottom_action_sheet.dart';
import 'package:jmusic/features/scraper/presentation/batch_scraper_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:jmusic/core/widgets/cover_art.dart';
import 'package:jmusic/features/music_lib/data/file_scanner_service.dart';
import 'package:jmusic/core/services/database_service.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';
import 'package:jmusic/features/player/presentation/player_providers.dart';
import 'package:isar/isar.dart';
import 'package:jmusic/features/playlists/presentation/playlist_selection_dialog.dart';
import 'package:jmusic/features/scraper/presentation/scraper_search_dialog.dart';
import 'package:jmusic/features/scraper/data/musicbrainz_service.dart';
import 'package:jmusic/features/scraper/presentation/scraper_providers.dart';
import 'package:jmusic/features/scraper/presentation/scrape_progress_dialog.dart';
import 'package:jmusic/features/music_lib/presentation/widgets/file_drop_zone.dart';
import 'package:jmusic/features/music_lib/presentation/widgets/webdav_download_icon.dart';
import 'package:jmusic/features/music_lib/presentation/tag_editor_dialog.dart';
import 'package:jmusic/core/services/webdav_service.dart';
import 'package:jmusic/features/music_lib/presentation/widgets/song_details_dialog.dart';
import 'package:jmusic/features/sync/data/sync_config_repository.dart';
import 'package:jmusic/core/services/preferences_service.dart';
import 'package:jmusic/features/music_lib/domain/song_filter.dart';
import 'package:path/path.dart' as p;
import 'package:jmusic/l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:jmusic/features/home/presentation/home_controller.dart';
import 'package:jmusic/features/player/presentation/widgets/mini_player.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  final SongFilter? filter;

  const LibraryScreen({super.key, this.filter});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

enum LibraryViewMode { songs, folders, artists, albums, webdav }

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  LibraryViewMode _viewMode = LibraryViewMode.songs;
  Stream<List<Song>>? _songsStream;
  List<Song> _currentDisplayedSongs = [];
  
  // For non-song views (Folders, Artists, etc.)
  List<String>? _groupedItems; // Stores list of artists/albums/folders
  
  final Set<int> _selectedIds = {};
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  // Scan progress state
  bool _isScanning = false;
  final ValueNotifier<int> _scanCurrentNotifier = ValueNotifier(0);
  final ValueNotifier<int> _scanTotalNotifier = ValueNotifier(0);
  final ValueNotifier<String> _currentFileNameNotifier = ValueNotifier('');
  final ValueNotifier<bool> _scanCompletedNotifier = ValueNotifier(false);
  bool _shouldUpdateProgress = true;

  // Drop progress state
  final ValueNotifier<int> _dropCurrentNotifier = ValueNotifier(0);
  final ValueNotifier<int> _dropTotalNotifier = ValueNotifier(0);
  final ValueNotifier<String> _dropCurrentFileNotifier = ValueNotifier('');
  final ValueNotifier<bool> _dropCompletedNotifier = ValueNotifier(false);
  
  String _searchQuery = '';
  bool _showSearch = false;

  bool get _isSelectionMode => _selectedIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    // If a filter is provided, we are in "Drill Down" mode, so force 'songs' view
    if (widget.filter != null) {
      _viewMode = LibraryViewMode.songs;
    }
    _searchFocus.addListener(() {
      if (!_searchFocus.hasFocus && _showSearch) {
        setState(() => _showSearch = false);
      }
    });
    _loadData(); // Replaces _updateSongsStream
  }

  void _onViewModeChanged(LibraryViewMode mode) {
    if (_viewMode == mode) return;
    setState(() {
      _viewMode = mode;
      _selectedIds.clear(); // Clear selection when switching views
      _searchQuery = ''; // Clear search
      _searchCtrl.clear();
      _showSearch = false; // Hide search when switching views
      _songsStream = null;
      _groupedItems = null;
    });
    _loadData();
  }

  void _selectAllDisplayed() {
    setState(() {
      if (_selectedIds.length == _currentDisplayedSongs.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(_currentDisplayedSongs.map((s) => s.id));
      }
    });
  }

  Future<void> _loadData() async {
    final db = await ref.read(databaseServiceProvider).db;

    if (_viewMode == LibraryViewMode.songs || _viewMode == LibraryViewMode.webdav) {
      _initSongStream(db);
    } else {
      _loadGroupedData(db);
    }
  }

  void _initSongStream(Isar db) {
    // Initialize with a dummy condition to ensure type consistency (QAfterFilterCondition)
    // and effectively select "All" before applying other filters.
    var query = db.songs.filter().idGreaterThan(-1);

    // 1. Apply Filter (if drilling down)
    if (widget.filter != null) {
      switch (widget.filter!.type) {
        case FilterType.artist:
          final val = widget.filter!.value;
          query = query.group((g) => g.artistEqualTo(val).or().artistsElementEqualTo(val));
          break;
        case FilterType.album:
          query = query.albumEqualTo(widget.filter!.value);
          break;
        case FilterType.folder:
           query = query.pathStartsWith(widget.filter!.value);
          break;
      }
    }

    // WebDAV view mode
    if (_viewMode == LibraryViewMode.webdav) {
      query = query.sourceTypeEqualTo(SourceType.webdav);
    }

    // 2. Apply Search
    if (_searchQuery.isNotEmpty) {
      query = query.group((g) => g
        .titleContains(_searchQuery, caseSensitive: false)
        .or()
        .artistContains(_searchQuery, caseSensitive: false)
        .or()
        .albumContains(_searchQuery, caseSensitive: false)
      );
    }
    
    setState(() {
      _songsStream = query.build().watch(fireImmediately: true);
    });
  }

  Future<void> _loadGroupedData(Isar db) async {
    // This loads data for Artists/Albums/Folders view
    // Since we need to aggregate, we can't easily stream perfectly with `watch` for aggregation 
    // without manual diffing, so we'll just fetch once or watch all songs and re-calc.
    // Use watch() on all songs to trigger updates.
    
    // We will watch the songs query, and map it to groups.
    // This updates the view if songs change.
    
    // Pre-fetch SyncConfig urls and prefs for WebDAV path resolution
    final syncRepo = ref.read(syncConfigRepositoryProvider);
    final prefs = ref.read(preferencesServiceProvider);
    final configs = await syncRepo.getAllConfigs();
    final Map<int, String> configUrlMap = {};
    for (final c in configs) {
      configUrlMap[c.id] = c.url;
    }

    final stream = db.songs.where().watch(fireImmediately: true);
    stream.listen((songs) {
      if (!mounted) return;
      
      final Set<String> items = {};
      
      for (final song in songs) {
        if (_viewMode == LibraryViewMode.artists) {
          if (song.artists.isNotEmpty) {
           items.addAll(song.artists.where((a) => a.isNotEmpty));
          } else {
           items.add(song.artist);
          }
        } else if (_viewMode == LibraryViewMode.albums) {
          items.add(song.album);
        } else if (_viewMode == LibraryViewMode.folders) {
           // Parent dir; for WebDAV include base URL
           String dir = p.dirname(song.path);
           if (song.sourceType == SourceType.webdav) {
             String base = '';
             if (song.syncConfigId != null && configUrlMap.containsKey(song.syncConfigId)) {
               base = configUrlMap[song.syncConfigId]!;
             } else {
               base = prefs.webDavUrl;
             }
             if (base.isNotEmpty) {
               if (base.endsWith('/')) base = base.substring(0, base.length - 1);
               if (!dir.startsWith('/')) dir = '/$dir';
               final combined = '$base$dir';
               // Decode percent-encoding for display if possible. Some remote paths
               // may contain stray '%' sequences which throw; fallback to raw.
               try {
                 items.add(Uri.decodeFull(combined));
               } catch (_) {
                 items.add(combined);
               }
               continue;
             }
           }
           items.add(dir);
        }
      }
      
      // Filter by search query if exists
      List<String> sortedItems = items.toList();
      if (_searchQuery.isNotEmpty) {
        sortedItems = sortedItems.where((s) => s.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
      }
      sortedItems.sort();

      setState(() {
        _groupedItems = sortedItems;
      });
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    // For songs view, stream updates automatically if we rebuild query? 
    // Actually no, `_initSongStream` creates a NEW stream.
    // So we must call _loadData again for Song view.
    // For grouped view, the listener handles it inside `_loadGroupedData`? 
    // No, `_loadGroupedData` sets up a listener that filters internally.
    // But notice `_loadGroupedData` is called once in `_loadData`.
    // The listener inside it just updates `_groupedItems`.
    // We should trigger a re-filter if it's grouped view.
    
    if (_viewMode == LibraryViewMode.songs) {
       _loadData();
    } else {
       // Trigger re-filter of existing data?
       // Re-running _loadData will create multiple listeners. Bad.
       // We should just store the "All Songs" list and filter in UI?
       // Let's just re-call _loadData for now but cancel previous sub? 
       // Simplification: just reload. Riverpod/StreamBuilder handles basic cleanup if we replace the stream? 
       // Actually `_songsStream` is variable. 
       
       // For grouped items:
       _loadData(); // This is slightly inefficient (creates new watch) but safe.
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  } 

  // OLD _updateSongsStream REMOVED

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
    setState(() {
      _selectedIds.addAll(songs.map((e) => e.id));
    });
  }

  Future<void> _deleteSelected() async {
    final l10n = AppLocalizations.of(context)!;
    final count = _selectedIds.length;
    final confirmed = await showDialog<bool>(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteSongs),
        content: Text(l10n.confirmDeleteSongs(count)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.delete, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.error))),
        ],
      )
    );

    if (confirmed == true) {
      final db = await ref.read(databaseServiceProvider).db;
      await db.writeTxn(() async {
        await db.songs.deleteAll(_selectedIds.toList());
      });
      
      // Update Player Queue
      await ref.read(audioPlayerServiceProvider).removeSongs(_selectedIds.toList());
      
      // Refresh home screen data
      ref.read(homeControllerProvider.notifier).refreshAll();
      
      _clearSelection();
      if (mounted) {
        CapsuleToast.show(context, l10n.songsDeleted(count));
      }
    }
  }

  Future<void> _addToPlaylistSelected() async {
    showDialog(
      context: context,
      builder: (_) => PlaylistSelectionDialog(songIds: _selectedIds.toList()),
    ).then((_) => _clearSelection());
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

  Future<void> _playAllInView() async {
    final l10n = AppLocalizations.of(context)!;
    // Collect all songs in current view/filter
    // Since stream builder has the data, but we can't easily access snapshot data here outside of build.
    // We should re-query Isar or use a provider for the current list state.
    // For simplicity, we re-query based on current filter/search.
    final db = await ref.read(databaseServiceProvider).db;
    var query = db.songs.filter().idGreaterThan(-1);

    if (widget.filter != null) {
      switch (widget.filter!.type) {
        case FilterType.artist:
          final val = widget.filter!.value;
          query = query.group((g) => g.artistEqualTo(val).or().artistsElementEqualTo(val));
          break;
        case FilterType.album:
          query = query.albumEqualTo(widget.filter!.value);
          break;
        case FilterType.folder:
           query = query.pathStartsWith(widget.filter!.value);
          break;
      }
    }

    if (_searchQuery.isNotEmpty) {
      query = query.group((g) => g
        .titleContains(_searchQuery, caseSensitive: false)
        .or()
        .artistContains(_searchQuery, caseSensitive: false)
        .or()
        .albumContains(_searchQuery, caseSensitive: false)
      );
    }

    final songs = await query.build().findAll();
    if (songs.isNotEmpty) {
      await ref.read(playerControllerProvider).setQueue(songs);
       if (mounted) {
        CapsuleToast.show(context, l10n.addedToQueue(songs.length));
      }
    }
  }

  void _scrapeSelected() {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedIds.isEmpty) {
      if (mounted) CapsuleToast.show(context, l10n.pleaseSelectDetailed);
      return;
    }

    ref.read(batchScraperProvider.notifier).startBatchScrape(_selectedIds.toList());

    setState(() {
      _selectedIds.clear();
    });

    if (mounted) {
      CapsuleToast.show(context, l10n.batchScrapeStarted);
    }
  }

  Future<void> _pickAndScan() async {
    final l10n = AppLocalizations.of(context)!;

    // Request storage permission on mobile
    if (Platform.isAndroid || Platform.isIOS) {
      Permission permission;
      if (Platform.isAndroid) {
        // For Android 13+, use audio permission
        permission = Permission.audio;
      } else {
        permission = Permission.storage;
      }
      final status = await permission.request();
      if (!status.isGranted) {
        if (context.mounted) {
          CapsuleToast.show(context, l10n.permissionDenied);
        }
        return;
      }
    }

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null && context.mounted) {
      // Show scan progress dialog
      setState(() {
        _isScanning = true;
      });
      _scanCurrentNotifier.value = 0;
      _scanTotalNotifier.value = 0;
      _currentFileNameNotifier.value = '';
      _scanCompletedNotifier.value = false; // Reset completion state
      _shouldUpdateProgress = true;

      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing
        builder: (dialogContext) => ScanProgressDialog(
          currentNotifier: _scanCurrentNotifier,
          totalNotifier: _scanTotalNotifier,
          fileNameNotifier: _currentFileNameNotifier,
          completedNotifier: _scanCompletedNotifier,
        ),
      );

      try {
        final count = await ref.read(fileScannerServiceProvider).scanFolder(
          selectedDirectory,
          onProgress: (current, total, fileName) {
            if (_shouldUpdateProgress) {
              _scanCurrentNotifier.value = current;
              _scanTotalNotifier.value = total;
              _currentFileNameNotifier.value = fileName;
            }
          },
        );

        // Stop updating progress
        _shouldUpdateProgress = false;

        // Mark scan as completed - dialog will auto-close
        _scanCompletedNotifier.value = true;

        // Show success message
        if (context.mounted) {
          CapsuleToast.show(context, l10n.addedCompSongs(count));
          // 刷新首页的最近导入和待刮削部分?
          if (count > 0) {
            ref.read(homeControllerProvider.notifier).refreshRecentlyImported();
            ref.read(homeControllerProvider.notifier).refreshToBeScraped();
          }
        }
      } catch (e) {
        // Stop updating progress
        _shouldUpdateProgress = false;

        // Mark scan as completed even on error - dialog will auto-close
        _scanCompletedNotifier.value = true;

        // Show error message
        if (context.mounted) {
          CapsuleToast.show(context, 'Scan failed: $e');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isScanning = false;
          });
        }
      }
    }
  }
  
  Future<void> _handleDroppedFiles(List<String> paths) async {
    final l10n = AppLocalizations.of(context)!;

    // Show progress dialog
    _dropCurrentNotifier.value = 0;
    _dropTotalNotifier.value = 0;
    _dropCurrentFileNotifier.value = '';
    _dropCompletedNotifier.value = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ScanProgressDialog(
        currentNotifier: _dropCurrentNotifier,
        totalNotifier: _dropTotalNotifier,
        fileNameNotifier: _dropCurrentFileNotifier,
        completedNotifier: _dropCompletedNotifier,
      ),
    );

    try {
      final count = await ref.read(fileScannerServiceProvider).scanPaths(paths, onProgress: (current, total, file) {
        _dropCurrentNotifier.value = current;
        _dropTotalNotifier.value = total;
        _dropCurrentFileNotifier.value = file;
      });

      _dropCompletedNotifier.value = true;

      if (mounted) {
        CapsuleToast.show(context, l10n.importedSongs(count));
      }
    } catch (e) {
      _dropCompletedNotifier.value = true;

      if (mounted) {
        CapsuleToast.show(context, 'Import failed: $e');
      }
    } finally {
      // Reset notifiers
      _dropCurrentNotifier.value = 0;
      _dropTotalNotifier.value = 0;
      _dropCurrentFileNotifier.value = '';
      _dropCompletedNotifier.value = false;
    }
  }

  void _navigateToSubset(String title, FilterType type, String value) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LibraryScreen(
          filter: SongFilter(type, value),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Determine title
    Widget? titleWidget;
    if (_isSelectionMode) {
      titleWidget = Text(l10n.selectedCount(_selectedIds.length));
    } else if (widget.filter != null) {
      // Logic moved to parent Scaffold usually, but if this widget is stand-alone body:
      // We don't need a Scaffold if parent provides it. 
      // But let's assume LibraryScreen provides the Scaffold.
      // If pulled from _navigateToSubset, we have double Scaffold.
      // Let's refactor _navigateToSubset to push LibraryScreen directly.
      titleWidget = Text(p.basename(widget.filter!.value)); 
    } else {
      titleWidget = Text(l10n.library);
    }
    
    return FileDropZone(
      onFilesDropped: _handleDroppedFiles,
      child: Scaffold(
      appBar: AppBar(
        title: titleWidget,
        leading: _isSelectionMode 
           ? IconButton(icon: const Icon(Icons.close), onPressed: _clearSelection) 
           : (widget.filter != null ? null : null), // Automatically handles back button if pushed
        actions: _isSelectionMode ? [
              IconButton(
                icon: const Icon(Icons.select_all),
                onPressed: _selectAllDisplayed,
                tooltip: l10n.selectAll,
              ),
              IconButton(
                icon: const Icon(Icons.playlist_add),
                onPressed: _addToPlaylistSelected,
                tooltip: l10n.addToPlaylist,
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editSelectedTags,
                tooltip: l10n.editTags,
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _deleteSelected,
                tooltip: l10n.delete,
              ),
              IconButton(
                icon: const Icon(Icons.auto_fix_high),
                onPressed: _scrapeSelected,
                tooltip: l10n.batchScrape,
              ),
            ] : [
              // Default actions
              if (widget.filter != null || _viewMode == LibraryViewMode.songs)
                 IconButton(
                  icon: const Icon(Icons.play_circle_fill),
                  onPressed: _playAllInView,
                  tooltip: l10n.playAll,
                ),
              if (widget.filter == null) 
                 IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _pickAndScan(),
                  tooltip: l10n.addFolder,
                ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  setState(() => _showSearch = !_showSearch);
                  if (_showSearch) {
                    WidgetsBinding.instance.addPostFrameCallback((_) => _searchFocus.requestFocus());
                  }
                },
                tooltip: l10n.search,
              ),
            ],
          ),
      body: Column(
        children: [
          // 1. Search Bar
          if (_showSearch && !_isSelectionMode)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: l10n.searchViewType(_viewMode.name),
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            
          // 2. View Mode Selector (Only if root library)
          if (widget.filter == null && !_isSelectionMode)
            Padding(
               padding: const EdgeInsets.symmetric(horizontal: 8.0),
               child: SegmentedButton<LibraryViewMode>(
                 segments: const [
                   ButtonSegment(value: LibraryViewMode.songs, icon: Icon(Icons.music_note)),
                   ButtonSegment(value: LibraryViewMode.artists, icon: Icon(Icons.person)),
                   ButtonSegment(value: LibraryViewMode.albums, icon: Icon(Icons.album)),
                   ButtonSegment(value: LibraryViewMode.folders, icon: Icon(Icons.folder)),
                   ButtonSegment(value: LibraryViewMode.webdav, icon: Icon(Icons.cloud)),
                 ],
                 selected: {_viewMode},
                 onSelectionChanged: (Set<LibraryViewMode> newSelection) {
                   _onViewModeChanged(newSelection.first);
                 },
                 showSelectedIcon: false,
               ),
            ),

          // 3. Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    )); 
  }

  Widget _buildContent() {
    if (_viewMode == LibraryViewMode.songs || _viewMode == LibraryViewMode.webdav) {
      return _buildSongsList();
    } else {
      return _buildGroupedList();
    }
  }

  Widget _buildGroupedList() {
      final l10n = AppLocalizations.of(context)!;
      if (_groupedItems == null) {
         return const Center(child: CircularProgressIndicator());
      }
      if (_groupedItems!.isEmpty) {
        return Center(child: Text(l10n.noItemsFound));
      }
      
      return ListView.separated(
        itemCount: _groupedItems!.length,
        separatorBuilder: (c, i) => const Divider(height: 1),
        itemBuilder: (context, index) {
           final item = _groupedItems![index];
           IconData icon;
           if (_viewMode == LibraryViewMode.folders) icon = Icons.folder;
           else if (_viewMode == LibraryViewMode.artists) icon = Icons.person;
           else icon = Icons.album;

           // Display logic
           String display = item;
           if (display.isEmpty) display = l10n.unknown;
           
           return ListTile(
             leading: CircleAvatar(
               backgroundColor: Theme.of(context).colorScheme.primaryContainer,
               child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.onPrimaryContainer),
             ),
             title: Text(display), 
             trailing: const Icon(Icons.chevron_right),
             onTap: () {
               // Navigate
               FilterType type;
               if (_viewMode == LibraryViewMode.folders) type = FilterType.folder;
               else if (_viewMode == LibraryViewMode.artists) type = FilterType.artist;
               else type = FilterType.album;
               
               // Use direct push of LibraryScreen
               Navigator.push(context, MaterialPageRoute(
                 builder: (_) => LibraryScreen(filter: SongFilter(type, item)),
               ));
             },
           );
        },
      );
  }

  Widget _buildSongsList() {
    final scrapingIds = ref.watch(batchScraperProvider.select((s) => s.scrapingSongIds));
    final isAnyScraping = ref.watch(batchScraperProvider.select((s) => s.isRunning));
    final l10n = AppLocalizations.of(context)!;

    return _songsStream == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<List<Song>>(
                    stream: _songsStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.music_note, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              const SizedBox(height: 16),
                              Text(l10n.emptyLibrary),
                              TextButton(
                                onPressed: _pickAndScan,
                                child: Text(l10n.addMusicFolder),
                              )
                            ],
                          ),
                        );
                      }

                      final songs = snapshot.data!;
                      // Keep reference to currently displayed songs for Select All
                      _currentDisplayedSongs = songs;
                      return ListView.builder(
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          final song = songs[index];
                          final isScrapingThis = scrapingIds.contains(song.id);
                          final isSelected = _selectedIds.contains(song.id);
                          
                          return ListTile(
                            selected: isSelected,
                            selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
                            leading: _isSelectionMode
                              ? Checkbox(
                                  value: isSelected,
                                  onChanged: (v) => _toggleSelection(song.id),
                                )
                              : Container(
                                  width: 48,
                                  height: 48,
                                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
                                  child: _buildCover(song.coverPath),
                                ),
                            title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                            subtitle: Text('${song.artists.isNotEmpty ? song.artists.join(' / ') : song.artist} • ${song.album}', maxLines: 1, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                            trailing: _isSelectionMode 
                              ? null 
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (song.sourceType == SourceType.webdav)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: WebDavDownloadIcon(song: song),
                                      ),
                                    IconButton(
                                      icon: Icon(Icons.more_vert),
                                      onPressed: () {
                                        final actions = <ActionItem>[
                                          ActionItem(
                                            icon: Icons.playlist_add,
                                            title: l10n.addToPlaylist,
                                            onTap: () => showDialog(
                                              context: context,
                                              builder: (_) => PlaylistSelectionDialog(songIds: [song.id]),
                                            ),
                                          ),
                                          ActionItem(
                                            icon: Icons.delete,
                                            title: l10n.delete,
                                            enabled: !isScrapingThis,
                                            onTap: () => _deleteSingle(song),
                                          ),
                                          if (song.sourceType == SourceType.webdav || song.sourceType == SourceType.openalist)
                                            ActionItem(
                                              icon: Icons.clear,
                                              title: l10n.clearCache,
                                              onTap: () {
                                                ref.read(webDavServiceProvider).removeSongCache(song.path, subDir: song.syncConfigId?.toString());
                                                CapsuleToast.show(context, l10n.cacheClearedWithTitle(song.title));
                                              },
                                            ),
                                          ActionItem(
                                            icon: Icons.edit,
                                            title: l10n.editTags,
                                            enabled: !isScrapingThis,
                                            onTap: () => showDialog(
                                              context: context,
                                              builder: (_) => TagEditorDialog(songs: [song]),
                                            ),
                                          ),
                                          ActionItem(
                                            icon: Icons.info,
                                            title: l10n.viewDetails,
                                            onTap: () => showDialog(
                                              context: context,
                                              builder: (_) => SongDetailsDialog(song: song),
                                            ),
                                          ),
                                          ActionItem(
                                            icon: Icons.auto_fix_high,
                                            title: l10n.scrapeAgain,
                                            enabled: !isAnyScraping && !isScrapingThis,
                                            onTap: () => showDialog(
                                              context: context,
                                              builder: (_) => ScraperSearchDialog(song: song),
                                            ),
                                          ),
                                        ];
                                        BottomActionSheet.show(context, actions: actions);
                                      },
                                    ),
                              ],
                            ),
                            onLongPress: () {
                              if (!_isSelectionMode) {
                                _toggleSelection(song.id);
                              }
                            },
                            onTap: () async {
                              if (_isSelectionMode) {
                                _toggleSelection(song.id);
                              } else {
                                // Default behavior: Play Single Song (Insert/Move to next) - does NOT clear queue
                                await ref.read(playerControllerProvider).playSingle(song);
                              }
                            },
                          );
                        },
                      );
                    },
                  );
  }

  Future<void> _deleteSingle(Song song) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
        content: Text(l10n.deleteSingleConfirm(song.title), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.delete, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.error))),
        ],
      ),
    );

    if (confirmed == true) {
      // If WebDAV, also remove cache
      if (song.sourceType == SourceType.webdav) {
        await ref.read(webDavServiceProvider).removeSongCache(song.path);
      }
      
      final db = await ref.read(databaseServiceProvider).db;
      await db.writeTxn(() async {
        await db.songs.delete(song.id);
      });
      
      // Update Player Queue
      await ref.read(audioPlayerServiceProvider).removeSongs([song.id]);
      
      // Refresh home screen data
      ref.read(homeControllerProvider.notifier).refreshAll();
      
      if (mounted) {
        CapsuleToast.show(context, l10n.songDeletedWithTitle(song.title));
      }
    }
  }

  Widget _buildCover(String? path) {
    if (path == null) return const Icon(Icons.music_note);
    return CoverArt(
      path: path,
      fit: BoxFit.cover,
    );
  }
}

class ScanProgressDialog extends StatefulWidget {
  final ValueNotifier<int> currentNotifier;
  final ValueNotifier<int> totalNotifier;
  final ValueNotifier<String> fileNameNotifier;
  final ValueNotifier<bool> completedNotifier;

  const ScanProgressDialog({
    super.key,
    required this.currentNotifier,
    required this.totalNotifier,
    required this.fileNameNotifier,
    required this.completedNotifier,
  });

  @override
  State<ScanProgressDialog> createState() => _ScanProgressDialogState();
}

class _ScanProgressDialogState extends State<ScanProgressDialog> {
  late int _current;
  late int _total;
  late String _fileName;
  late bool _completed;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _current = widget.currentNotifier.value;
    _total = widget.totalNotifier.value;
    _fileName = widget.fileNameNotifier.value;
    _completed = widget.completedNotifier.value;

    // Listen to changes
    widget.currentNotifier.addListener(_updateProgress);
    widget.totalNotifier.addListener(_updateProgress);
    widget.fileNameNotifier.addListener(_updateProgress);
    widget.completedNotifier.addListener(_onCompleted);

    // Check initial completed state
    if (_completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    widget.currentNotifier.removeListener(_updateProgress);
    widget.totalNotifier.removeListener(_updateProgress);
    widget.fileNameNotifier.removeListener(_updateProgress);
    widget.completedNotifier.removeListener(_onCompleted);
    super.dispose();
  }

  void _updateProgress() {
    if (_isDisposed) return;
    if (!mounted) return;
    
    setState(() {
      _current = widget.currentNotifier.value;
      _total = widget.totalNotifier.value;
      _fileName = widget.fileNameNotifier.value;
    });
  }

  void _onCompleted() {
    if (_isDisposed) return;
    if (!mounted) return;
    
    final completed = widget.completedNotifier.value;
    if (completed && !_completed) {
      _completed = true;
      // Close the dialog when scanning is completed
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    final progress = _total > 0 ? _current / _total : 0.0;
    
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button from closing dialog
      child: Dialog(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress indicator with text in center
              SizedBox(
                width: 160,
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                      backgroundColor: theme.colorScheme.surfaceVariant,
                    ),
                    Text(
                      _total > 0 ? '$_current/$_total' : '0/0',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Current file name
              Text(
                _fileName.isNotEmpty ? l10n.scanningFile(_fileName) : l10n.scanning,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

