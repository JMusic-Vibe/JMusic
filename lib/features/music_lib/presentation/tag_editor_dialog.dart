import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/widgets/capsule_toast.dart';
import 'package:jmusic/features/music_lib/data/tag_editing_service.dart';
import 'package:jmusic/features/music_lib/domain/entities/song.dart';
import 'package:jmusic/l10n/app_localizations.dart';

class TagEditorDialog extends ConsumerStatefulWidget {
  final List<Song> songs;

  const TagEditorDialog({super.key, required this.songs});

  @override
  ConsumerState<TagEditorDialog> createState() => _TagEditorDialogState();
}

class _TagEditorDialogState extends ConsumerState<TagEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleCtrl;
  late TextEditingController _artistCtrl;
  late TextEditingController _albumCtrl;
  late TextEditingController _yearCtrl;
  late TextEditingController _genreCtrl;

  bool _multiTitle = false;
  bool _multiArtist = false;
  bool _multiAlbum = false;
  bool _multiYear = false;
  bool _multiGenre = false;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final songs = widget.songs;
    if (songs.isEmpty) return;

    // Helper to check consistency
    bool allSame(String Function(Song) selector) {
      final first = selector(songs.first);
      return songs.every((s) => selector(s) == first);
    }

    // Title
    if (songs.length == 1) {
      _titleCtrl = TextEditingController(text: songs.first.title);
    } else {
      _multiTitle = !allSame((s) => s.title);
      _titleCtrl = TextEditingController(text: _multiTitle ? '' : songs.first.title);
    }

    // Artist
    _multiArtist = !allSame((s) => s.artist);
    _artistCtrl = TextEditingController(text: _multiArtist ? '' : songs.first.artist);

    // Album
    _multiAlbum = !allSame((s) => s.album);
    _albumCtrl = TextEditingController(text: _multiAlbum ? '' : songs.first.album);

    // Year
    // Handle Year which is int?
    bool allYearSame = true;
    final firstYear = songs.first.year;
    for (var s in songs) {
       if (s.year != firstYear) {
         allYearSame = false;
         break;
       }
    }
    _multiYear = !allYearSame;
    _yearCtrl = TextEditingController(text: _multiYear ? '' : (firstYear?.toString() ?? ''));

    // Genre
    _multiGenre = !allSame((s) => s.genre ?? '');
    _genreCtrl = TextEditingController(text: _multiGenre ? '' : (songs.first.genre ?? ''));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _artistCtrl.dispose();
    _albumCtrl.dispose();
    _yearCtrl.dispose();
    _genreCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final service = ref.read(tagEditingServiceProvider);
      
      // Determine what to update
      // Only update fields that were 'Keep Original' (empty in multi mode) IF user typed something?
      // Actually standard behavior: 
      // If it Was Multi and Is Empty -> No Change.
      // If it Was Multi and Has Text -> Update All to Text.
      // If it Was Single -> Update to Text.
      
      String? newTitle = _shouldUpdate(_multiTitle, _titleCtrl.text) ? _titleCtrl.text.trim() : null;
      String? newArtist = _shouldUpdate(_multiArtist, _artistCtrl.text) ? _artistCtrl.text.trim() : null;
      String? newAlbum = _shouldUpdate(_multiAlbum, _albumCtrl.text) ? _albumCtrl.text.trim() : null;
      
      String? newGenre = _shouldUpdate(_multiGenre, _genreCtrl.text) ? _genreCtrl.text.trim() : null;
      
      int? newYear;
      if (_shouldUpdate(_multiYear, _yearCtrl.text)) {
        newYear = int.tryParse(_yearCtrl.text.trim());
      }

      if (widget.songs.length == 1) {
        // Single mode: update everything that is not null. 
        // For single mode, even empty string checks apply (allow clearing?).
        // For simplicity: Update if controller text is different from original?
        // Let's just pass values.
        // For single, _shouldUpdate might send null if it was multi (impossible).
        // Let's simplify logic.
        final s = widget.songs.first;
        await service.updateSong(s,
          title: _titleCtrl.text.trim(),
          artist: _artistCtrl.text.trim(),
          album: _albumCtrl.text.trim(),
          year: int.tryParse(_yearCtrl.text.trim()),
          genre: _genreCtrl.text.trim(),
        );
      } else {
        // Batch mode
        await service.updateSongs(widget.songs,
           artist: newArtist,
           album: newAlbum,
           year: newYear,
           genre: newGenre,
           // Batched title update is usually rare unless it's "Track 1", but usually distinct.
           // If user set title in batch, apply it.
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
        CapsuleToast.show(context, 'Updated ${widget.songs.length} songs');
      }
    } catch (e) {
      if (mounted) {
        CapsuleToast.show(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Helper to decide if we should send this value to update
  bool _shouldUpdate(bool isMulti, String text) {
    if (!isMulti) return true; // It was consistent, so new value (even if empty/same) overrides
    // It was multi (inconsistent), so only update if user entered something?
    // Usually UI shows "<Multiple Values>" placeholder. If user clears it, what happens?
    // My UI shows empty string for Multi.
    // If user leaves it empty, we assume "No Change".
    // If user types "Various", we update all.
    return text.isNotEmpty; 
  }

  InputDecoration _decoration(BuildContext context, String label, bool isMulti) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      hintText: isMulti ? '<Multiple Values>' : null,
      suffixIcon: isMulti ? const Icon(Icons.copy_all, size: 16) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBatch = widget.songs.length > 1;
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(
        l10n.editTags,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: min(400, MediaQuery.of(context).size.width * 0.9),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isBatch) // Typically don't batch edit titles
                  TextFormField(
                    controller: _titleCtrl,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                    decoration: _decoration(context, 'Title', _multiTitle),
                  ),
                if (!isBatch) const SizedBox(height: 16),
                
                TextFormField(
                  controller: _artistCtrl,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                  decoration: _decoration(context, 'Artist', _multiArtist),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _albumCtrl,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                  decoration: _decoration(context, 'Album', _multiAlbum),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _yearCtrl,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                        decoration: _decoration(context, 'Year', _multiYear),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                          controller: _genreCtrl,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                          decoration: _decoration(context, 'Genre', _multiGenre),
                        ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                Text(
                  isBatch
                      ? 'Note: Leaving a "Multiple Values" field empty will keep original values.'
                      : 'Changes will be saved to database and file tags (if supported).',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.save),
        ),
      ],
    );
  }
}

