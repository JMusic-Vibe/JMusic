import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/services/database_service.dart';
import 'package:jmusic/core/widgets/capsule_toast.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';
import 'package:jmusic/features/scraper/data/musicbrainz_service.dart';
import 'package:jmusic/features/scraper/presentation/scrape_progress_dialog.dart';
import 'package:jmusic/features/scraper/presentation/scraper_providers.dart';
import 'package:jmusic/features/scraper/presentation/scraper_search_dialog.dart';
import 'package:jmusic/features/scraper/presentation/batch_scraper_service.dart';
import 'package:jmusic/l10n/app_localizations.dart';

class ScraperCenterScreen extends ConsumerStatefulWidget {
  const ScraperCenterScreen({super.key});

  @override
  ConsumerState<ScraperCenterScreen> createState() => _ScraperCenterScreenState();
}

class _ScraperCenterScreenState extends ConsumerState<ScraperCenterScreen> {
  final Set<int> _selectedIds = {};
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  
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
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  bool get _isSelectionMode => _selectedIds.isNotEmpty;

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
        if (_selectedIds.length == songs.length) {
          _selectedIds.clear();
        } else {
          _selectedIds.addAll(songs.map((e) => e.id));
        }
     });
  }

  void _scrapeSelected() {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedIds.isEmpty) {
      if (mounted) CapsuleToast.show(context, l10n.pleaseSelectDetailed); 
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
    final unscrapedAsync = ref.watch(unscrapedSongsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: _isSelectionMode
            ? IconButton(icon: const Icon(Icons.close), onPressed: _clearSelection)
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
            : Text(_isSelectionMode ? l10n.selectedCount(_selectedIds.length) : unscrapedAsync.maybeWhen(
                data: (songs) => '${l10n.scraperCenter} (${songs.length})',
                orElse: () => l10n.scraperCenter,
              )),
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.select_all),
                  onPressed: () {
                     unscrapedAsync.whenData((songs) {
                        final filtered = _filterSongs(songs);
                        _selectAll(filtered);
                     });
                  },
                  tooltip: l10n.selectAll,
                ),
                IconButton(
                  icon: const Icon(Icons.auto_fix_high),
                  onPressed: _scrapeSelected,
                  tooltip: l10n.batchScrape,
                ),
              ]
            : [
                if (!_showSearch)
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      setState(() => _showSearch = true);
                      WidgetsBinding.instance.addPostFrameCallback((_) => _searchFocus.requestFocus());
                    },
                    tooltip: l10n.search,
                  ),
                IconButton(
                  tooltip: l10n.refresh,
                  onPressed: () => ref.refresh(unscrapedSongsProvider),
                  icon: const Icon(Icons.refresh),
                ),
              ],
      ),
      body: unscrapedAsync.when(
        data: (songs) {
          final filteredSongs = _filterSongs(songs);
          
          if (filteredSongs.isEmpty) {
             if (_searchQuery.isNotEmpty) {
                return Center(child: Text(l10n.noMatchingSongs));
             }
             if (songs.isEmpty) {
               return Center(child: Text(l10n.allSongsScraped, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)));
             }
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: filteredSongs.length,
                  itemBuilder: (context, index) {
                    final song = filteredSongs[index];
                    final isSelected = _selectedIds.contains(song.id);
                    
                    return ListTile(
                      leading: _isSelectionMode 
                          ? Checkbox(value: isSelected, onChanged: (v) => _toggleSelection(song.id))
                          : const Icon(Icons.music_off_outlined),
                      title: Text(song.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.normal, color: Theme.of(context).colorScheme.onSurface)),
                      subtitle: Text('${song.artists.isNotEmpty ? song.artists.join(' / ') : song.artist} - ${song.album}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      selected: isSelected,
                      onLongPress: () {
                          // 长按进入选择模式，或在选择模式下切换
                          _toggleSelection(song.id);
                      },
                      onTap: () {
                          if (_isSelectionMode) {
                            _toggleSelection(song.id);
                          } else {
                             // 普通点击可以打开手动匹配对话框，保持原有逻辑作为备份
                             showDialog(
                                context: context,
                                builder: (_) => ScraperSearchDialog(song: song),
                             );
                          }
                      },
                      trailing: _isSelectionMode 
                          ? null 
                          : TextButton(
                              child: Text('匹配', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => ScraperSearchDialog(song: song),
                                );
                              },
                            ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  List<Song> _filterSongs(List<Song> songs) {
    if (_searchQuery.isEmpty) return songs;
    final q = _searchQuery.toLowerCase();
    return songs.where((s) => 
      s.title.toLowerCase().contains(q) || 
      ((s.artist ?? '').toLowerCase().contains(q)) ||
      (s.artists.any((a) => a.toLowerCase().contains(q))) ||
      (s.album ?? '').toLowerCase().contains(q)
    ).toList();
  }
}

