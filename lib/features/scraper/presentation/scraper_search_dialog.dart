import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/widgets/cover_art.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';
import 'package:jmusic/features/scraper/data/musicbrainz_service.dart';
import 'package:jmusic/features/scraper/domain/musicbrainz_result.dart';
import 'package:jmusic/features/scraper/presentation/scraper_providers.dart';
import 'package:jmusic/features/player/presentation/player_providers.dart';
import 'package:jmusic/l10n/app_localizations.dart';
import 'package:jmusic/core/services/preferences_service.dart';

class ScraperSearchDialog extends ConsumerStatefulWidget {
  final Song song;

  const ScraperSearchDialog({super.key, required this.song});

  @override
  ConsumerState<ScraperSearchDialog> createState() => _ScraperSearchDialogState();
}

class _ScraperSearchDialogState extends ConsumerState<ScraperSearchDialog> {
  final _titleCtrl = TextEditingController();
  final _artistCtrl = TextEditingController();
  final _albumCtrl = TextEditingController();
  List<MusicBrainzResult>? _results;
  bool _isLoading = false;
  bool _isProcessingSelection = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl.text = widget.song.title;
    // 根据偏好决定预填 Artist 字段（默认使用主歌手）
    final usePrimary = ref.read(preferencesServiceProvider).scraperUsePrimaryArtist;
    _artistCtrl.text = usePrimary ? widget.song.artist : (widget.song.artists.isNotEmpty ? widget.song.artists.join(' / ') : widget.song.artist);
    _albumCtrl.text = widget.song.album;
    _doSearch();
  }

  Future<void> _doSearch() async {
    final title = _titleCtrl.text.trim();
    final artist = _artistCtrl.text.trim();
    final album = _albumCtrl.text.trim();
    if (title.isEmpty) return;

    setState(() => _isLoading = true);

    // 分别传入 title 和 artist，正确地使用 MusicBrainz API 的搜索参数
    final results = await ref.read(musicBrainzServiceProvider).searchRecording(
      title,
      artist.isNotEmpty ? artist : null,
      album.isNotEmpty ? album : null,
    );
    
    // 并行获取封面 fetch covers concurrently 
    // 注意：MusicBrainz API limit is strict (1 req/sec typically), so be careful.
    // 我们仅在用户点击详情或者展示时获取，或者这里不做批量获取。
    
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  Future<void> _onResultSelected(MusicBrainzResult result) async {
      if (_isProcessingSelection) return;
      setState(() => _isProcessingSelection = true);

      try {
        // 获取封面 URL (Cover Art Archive)
        String? coverUrl;
        if (result.releaseId != null) {
            print('[SearchDialog] Selected result has releaseId: ${result.releaseId}');
            // Show loading for cover?
            try {
               coverUrl = await ref.read(musicBrainzServiceProvider).getCoverArtUrl(result.releaseId!);
               print('[SearchDialog] Got coverUrl: $coverUrl');
            } catch (e) {
               print('[SearchDialog] Error fetching cover: $e');
            }
        } else {
            print('[SearchDialog] Result has NO releaseId');
        }

        if (!mounted) return;

        // 弹窗确认
        final l10n = AppLocalizations.of(context)!;
        final confirm = await showDialog<bool>(
          context: context, 
          builder: (context) => AlertDialog(
              title: Text(l10n.confirm, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      if (coverUrl != null) 
                          SizedBox(
                            height: 100, 
                            width: 100, 
                            child: CoverArt(
                              path: coverUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                      Text('Title: ${result.title}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                      Text('Artist: ${result.artist}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                      Text('Album: ${result.album}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                  ],
              ),
              actions: [
                  TextButton(onPressed: ()=>Navigator.pop(context, false), child: Text(l10n.cancel)),
                  FilledButton(onPressed: ()=>Navigator.pop(context, true), child: Text(l10n.confirm)),
              ],
          )
        );

        if (confirm == true && mounted) {
           await ref.read(scraperControllerProvider).updateSongMetadata(
               widget.song.id, 
               title: result.title, 
               artist: result.artist, 
               album: result.album,
               mbId: result.id,
               coverUrl: coverUrl,
               year: int.tryParse(result.date?.split('-').first ?? ''),
           );
           // 强制刷新播放相关的 Provider，以同步更新队列和当前歌曲信息
           ref.refresh(queueProvider);
           ref.refresh(currentMediaItemProvider);
           if (mounted) Navigator.pop(context); // Close search dialog
        }
      } finally {
        if (mounted) {
          setState(() => _isProcessingSelection = false);
        }
      }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        height: 600,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 标题输入框
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: 'Song Title (歌曲名)',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _doSearch(),
            ),
            const SizedBox(height: 12),
            // 艺术家输入框和搜索按 - 并排排列
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _artistCtrl,
                    decoration: InputDecoration(
                      labelText: 'Artist (艺术家)',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _doSearch(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _albumCtrl,
                    decoration: InputDecoration(
                      labelText: 'Album (专辑)',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _doSearch(),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 56, // 与 TextField 高度一致
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: IconButton(
                    onPressed: _doSearch,
                    icon: const Icon(Icons.search),
                    tooltip: '搜索',
                  ),
                )
              ],
            ),
            if (_isProcessingSelection)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: LinearProgressIndicator(),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _results == null 
                    ? const Center(child: Text('搜索以查看结果'))
                    : ListView.separated(
                        separatorBuilder: (_, __) => const Divider(),
                        itemCount: _results!.length,
                        itemBuilder: (context, index) {
                          final item = _results![index];
                          return ListTile(
                            title: Text(item.title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                            subtitle: Text('${item.artist} - ${item.album} (${item.date ?? '?'})'),
                            trailing: const Icon(Icons.check_circle_outlined),
                            // Disable interaction while processing selection
                            enabled: !_isProcessingSelection, 
                            onTap: () => _onResultSelected(item),
                          );
                        },
                      ),
            )
          ],
        ),
      ),
    );
  }
}

