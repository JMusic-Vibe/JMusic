import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/widgets/cover_art.dart';
import 'package:jmusic/features/scraper/data/artist_sources/artist_scraper_service.dart';
import 'package:jmusic/features/scraper/data/artist_sources/artist_models.dart';
import 'package:jmusic/features/scraper/presentation/scraper_providers.dart';
import 'package:jmusic/l10n/app_localizations.dart';
import 'package:jmusic/core/widgets/capsule_toast.dart';
import 'package:jmusic/core/services/preferences_service.dart';

class ArtistSearchDialog extends ConsumerStatefulWidget {
  final String artistName;
  final bool asPage;

  const ArtistSearchDialog({
    super.key,
    required this.artistName,
    this.asPage = false,
  });

  @override
  ConsumerState<ArtistSearchDialog> createState() => _ArtistSearchDialogState();
}

class _ArtistSearchDialogState extends ConsumerState<ArtistSearchDialog> {
  final _nameCtrl = TextEditingController();
  List<ArtistSearchResult>? _results;
  bool _isLoading = false;
  bool _isProcessingSelection = false;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.artistName;
    _doSearch();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _doSearch() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _isLoading = true);
    final prefs = ref.read(preferencesServiceProvider);
    final useMb = prefs.scraperArtistSourceMusicBrainz;
    final useItunes = prefs.scraperArtistSourceItunes;
    final useQQ = prefs.scraperArtistSourceQQMusic;
    if (!useMb && !useItunes && !useQQ) {
      setState(() => _isLoading = false);
      if (mounted) {
        CapsuleToast.show(context, l10n.scraperSourceAtLeastOne);
      }
      return;
    }
    final service = ref.read(artistScraperServiceProvider);
    final results = await service.searchArtists(
      name,
      useMusicBrainz: useMb,
      useItunes: useItunes,
      useQQ: useQQ,
    );
    if (!mounted) return;
    setState(() {
      _results = results;
      _isLoading = false;
    });

    // Try to fill missing images for first few results asynchronously
    if (_results != null && _results!.isNotEmpty) {
      final svc = ref.read(artistScraperServiceProvider);
      final toCheck = _results!.take(10).toList();
      for (var i = 0; i < toCheck.length; i++) {
        final r = toCheck[i];
        if (r.imageUrl == null || r.imageUrl!.isEmpty) {
          Future(() async {
            String? img;
            if (r.source == ArtistSource.musicBrainz) {
              img = await svc.fetchArtistImageUrlById(r.id);
            } else if (r.source == ArtistSource.itunes) {
              img = await svc.fetchArtistImageUrlFromItunes(r.name);
            } else if (r.source == ArtistSource.qqMusic) {
              img = await svc.fetchArtistImageUrlFromQQ(r.name);
            }
            if (img != null && img.isNotEmpty) {
              if (!mounted) return;
              setState(() {
                final idx = _results!.indexWhere((e) => e.id == r.id && e.source == r.source);
                if (idx != -1) {
                  _results![idx] = ArtistSearchResult(
                    id: r.id,
                    name: r.name,
                    source: r.source,
                    imageUrl: img,
                    disambiguation: r.disambiguation,
                    type: r.type,
                    country: r.country,
                  );
                }
              });
            }
          });
        }
      }
    }
  }

  Future<void> _onResultSelected(ArtistSearchResult result) async {
    if (_isProcessingSelection) return;
    setState(() => _isProcessingSelection = true);
    try {
      final service = ref.read(artistScraperServiceProvider);
      String? imageUrl = result.imageUrl;
      if (imageUrl == null || imageUrl.isEmpty) {
        if (result.source == ArtistSource.musicBrainz) {
          imageUrl = await service.fetchArtistImageUrlById(result.id);
        } else if (result.source == ArtistSource.itunes) {
          imageUrl = await service.fetchArtistImageUrlFromItunes(result.name);
        } else if (result.source == ArtistSource.qqMusic) {
          imageUrl = await service.fetchArtistImageUrlFromQQ(result.name);
        }
      }
      final sourceLabel = _sourceLabel(result.source);

      if (!mounted) return;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.confirm,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                SizedBox(
                  height: 100,
                  width: 100,
                  child: CoverArt(
                      path: imageUrl, fit: BoxFit.cover, isVideo: false),
                ),
              Text(result.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface)),
              if (sourceLabel != null)
                Text(
                  l10n.scraperSourceLabel(sourceLabel),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              if (result.disambiguation != null &&
                  result.disambiguation!.isNotEmpty)
                Text(result.disambiguation!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
              Text(
                [result.type, result.country]
                    .where((e) => e != null && e!.isNotEmpty)
                    .join(' · '),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
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

      if (confirm == true && imageUrl != null && imageUrl.isNotEmpty) {
        await ref.read(artistScraperControllerProvider).saveArtistSelection(
              name: widget.artistName,
              mbId: result.source == ArtistSource.musicBrainz ? result.id : '',
              imageUrl: imageUrl,
            );
        if (mounted) {
          CapsuleToast.show(context, l10n.scrapeArtistAvatarsResult(1));
          Navigator.pop(context);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingSelection = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: 560,
      height: 560,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: l10n.artistNameLabel,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _doSearch(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _doSearch,
                  icon: const Icon(Icons.search),
                  label: Text(l10n.search),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results == null
                    ? Center(child: Text(l10n.searchUnarchived))
                    : ListView.separated(
                        separatorBuilder: (_, __) => const Divider(),
                        itemCount: _results!.length,
                        itemBuilder: (context, index) {
                          final item = _results![index];
                          final sourceLabel = _sourceLabel(item.source);
                          final subtitleParts = <String>[];
                          if (sourceLabel != null) {
                            subtitleParts
                                .add(l10n.scraperSourceLabel(sourceLabel));
                          }
                          if (item.type != null && item.type!.isNotEmpty) {
                            subtitleParts.add(item.type!);
                          }
                          if (item.country != null &&
                              item.country!.isNotEmpty) {
                            subtitleParts.add(item.country!);
                          }
                          if (item.disambiguation != null &&
                              item.disambiguation!.isNotEmpty) {
                            subtitleParts.add(item.disambiguation!);
                          }
                          Widget leading;
                          if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
                            leading = ClipOval(
                              child: SizedBox(
                                width: 44,
                                height: 44,
                                child: CoverArt(path: item.imageUrl, fit: BoxFit.cover, isVideo: false),
                              ),
                            );
                          } else {
                            // Fallback: show a circle with initial
                            leading = CircleAvatar(
                              radius: 22,
                              child: Text(item.name.isNotEmpty ? item.name[0].toUpperCase() : '?'),
                            );
                          }

                          return ListTile(
                            leading: leading,
                            title: Text(item.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            subtitle: Text(subtitleParts.join(' · ')),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _onResultSelected(item),
                          );
                        },
                      ),
          ),
        ],
      ),
    );

    if (widget.asPage) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.manualMatchArtist)),
        body: content,
      );
    }

    return Dialog(child: content);
  }

  String? _sourceLabel(ArtistSource source) {
    switch (source) {
      case ArtistSource.musicBrainz:
        return l10n.scraperSourceMusicBrainz;
      case ArtistSource.itunes:
        return l10n.scraperSourceItunes;
      case ArtistSource.qqMusic:
        return l10n.scraperSourceQQMusic;
    }
  }
}
