import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/widgets/capsule_toast.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';
import 'package:jmusic/features/scraper/data/lyrics_service.dart';
import 'package:jmusic/features/scraper/presentation/scraper_providers.dart';
import 'package:jmusic/features/player/presentation/player_providers.dart';
import 'package:jmusic/l10n/app_localizations.dart';

class ScraperLyricsMatchDialog extends ConsumerStatefulWidget {
  final Song song;
  final bool asPage;
  const ScraperLyricsMatchDialog({
    super.key,
    required this.song,
    this.asPage = false,
  });

  @override
  ConsumerState<ScraperLyricsMatchDialog> createState() =>
      _ScraperLyricsMatchDialogState();
}

class _ScraperLyricsMatchDialogState
    extends ConsumerState<ScraperLyricsMatchDialog> {
  final _titleCtrl = TextEditingController();
  final _artistCtrl = TextEditingController();
  final _albumCtrl = TextEditingController();
  bool _loading = true;
  List<LyricsResult> _candidates = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _titleCtrl.text = widget.song.title;
    _artistCtrl.text = widget.song.artists.isNotEmpty
        ? widget.song.artists.join(' / ')
        : widget.song.artist;
    _albumCtrl.text = widget.song.album;
    _loadCandidates();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _artistCtrl.dispose();
    _albumCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCandidates() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final svc = ref.read(lyricsServiceProvider);
      final res = await svc.fetchAllCandidates(
          title: _normalizeQueryParam(_titleCtrl.text) ?? '',
          artist: _normalizeQueryParam(_artistCtrl.text) ?? '',
          album: _normalizeQueryParam(_albumCtrl.text));
      setState(() {
        _candidates = res;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted)
        setState(() {
          _loading = false;
        });
    }
  }

  String? _normalizeQueryParam(String? input) {
    if (input == null) return null;
    final v = input.trim();
    if (v.isEmpty) return null;
    final lower = v.toLowerCase();
    if (lower.contains('unknown') || lower.contains('unknow')) return null;
    if (v.contains('未知')) return null;
    return v;
  }

  String _formatDuration(int? ms) {
    if (ms == null) return '-';
    final seconds = (ms / 1000).round();
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}:${s.toString().padLeft(2, '0')}';
  }

  int? _calcDurationFromLyrics(String? lyrics) {
    if (lyrics == null || lyrics.isEmpty) return null;
    final tagPattern = RegExp(
        r'\[(\d{1,2}):(\d{2})(?:[\.:](\d{1,3}))?(?:,(\d{1,2}):(\d{2})(?:[\.:](\d{1,3}))?)?\]');
    final times = <int>[];
    for (final match in tagPattern.allMatches(lyrics)) {
      final startMs = _timeToMilliseconds(
        match.group(1) ?? '0',
        match.group(2) ?? '0',
        match.group(3),
      );
      final endMs = _timeToMilliseconds(
        match.group(4) ?? match.group(1) ?? '0',
        match.group(5) ?? match.group(2) ?? '0',
        match.group(6) ?? match.group(3),
      );
      times.add(startMs);
      times.add(endMs);
    }
    return _pickDurationMs(times);
  }

  int? _pickDurationMs(List<int> times) {
    if (times.isEmpty) return null;
    times.sort();
    final maxMs = times.last;
    if (times.length < 2) return maxMs > 0 ? maxMs : null;
    final secondMax = times[times.length - 2];
    // Ignore exaggerated tail timestamps (e.g., last line stretched for sync).
    if (maxMs - secondMax > 60000) {
      return secondMax > 0 ? secondMax : null;
    }
    return maxMs > 0 ? maxMs : null;
  }

  int _timeToMilliseconds(String min, String sec, String? frac) {
    final minutes = int.tryParse(min) ?? 0;
    final seconds = int.tryParse(sec) ?? 0;
    final milliRaw = frac?.padRight(3, '0') ?? '0';
    final millis = int.tryParse(milliRaw) ?? 0;
    return minutes * 60 * 1000 + seconds * 1000 + millis;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final content = Container(
      width: 640,
      height: 520,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.manualMatchLyrics,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              labelText: l10n.songTitleLabel,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _loadCandidates(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _artistCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.artistLabel,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _loadCandidates(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _albumCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.albumLabel,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _loadCandidates(),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: IconButton(
                  onPressed: _loadCandidates,
                  icon: const Icon(Icons.search),
                  tooltip: l10n.search,
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(child: Center(child: Text('Error: $_error')))
          else if (_candidates.isEmpty)
            Expanded(child: Center(child: Text(l10n.noLyricsFound)))
          else
            Expanded(
              child: ListView.separated(
                itemCount: _candidates.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final c = _candidates[index];
                  final candidateSource = _buildCandidateSourceLabel(l10n, c);
                  final candidateDurationMs = _calcDurationFromLyrics(c.text);
                  final durationText =
                      l10n.lyricsDuration(_formatDuration(candidateDurationMs));
                  final titleDisplay = c.title ?? _titleCtrl.text.trim();
                  final artistDisplayItem = c.artist ?? _artistCtrl.text.trim();
                  final albumDisplay = c.album ?? _albumCtrl.text.trim();
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    title: Text(candidateSource,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('${l10n.songTitleLabel}: $titleDisplay',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface)),
                        Text('${l10n.artistLabel}: $artistDisplayItem',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface)),
                        Text('${l10n.albumLabel}: $albumDisplay',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface)),
                        const SizedBox(height: 2),
                        Text(durationText,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l10n.confirm),
                            content: SizedBox(
                              width: 400,
                              height: 300,
                              child: SingleChildScrollView(
                                  child: Text(c.text ?? l10n.noLyricsFound)),
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(l10n.cancel)),
                              FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(l10n.confirm)),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await ref
                              .read(scraperControllerProvider)
                              .updateSongMetadata(
                                widget.song.id,
                                title: _titleCtrl.text.trim(),
                                artist: _artistCtrl.text.trim(),
                                album: _albumCtrl.text.trim(),
                                lyrics: c.text,
                                lyricsDurationMs:
                                    candidateDurationMs ?? c.durationMs,
                              );
                          CapsuleToast.show(
                              context, l10n.scrapeCompleteWithLyrics);
                          ref.refresh(queueProvider);
                          ref.refresh(currentMediaItemProvider);
                          if (mounted) Navigator.pop(context);
                        }
                      },
                      child: Text(l10n.confirm),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );

    if (widget.asPage) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.manualMatchLyrics)),
        body: Center(child: content),
      );
    }

    return Dialog(child: content);
  }

  String _buildCandidateSourceLabel(
      AppLocalizations l10n, LyricsResult candidate) {
    final rawSource = candidate.source;
    final localized = rawSource == 'lrclib'
        ? l10n.scraperSourceLrclib
        : rawSource == 'rangotec'
            ? l10n.scraperSourceRangotec
            : rawSource == 'itunes'
                ? l10n.scraperSourceItunes
                : rawSource;
    final labelSource = (localized != null && localized.isNotEmpty)
        ? localized
        : (rawSource?.toUpperCase() ?? 'unknown');
    return l10n.scraperSourceLabel(labelSource);
  }
}
