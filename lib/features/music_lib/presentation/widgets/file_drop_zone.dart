import 'dart:async';
import 'package:flutter/material.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class FileDropZone extends StatefulWidget {
  final Widget child;
  final Future<void> Function(List<String> paths) onFilesDropped;

  const FileDropZone({
    super.key,
    required this.child,
    required this.onFilesDropped,
  });

  @override
  State<FileDropZone> createState() => _FileDropZoneState();
}

class _FileDropZoneState extends State<FileDropZone> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return DropRegion(
      formats: Formats.standardFormats,
      hitTestBehavior: HitTestBehavior.opaque,
      onDropOver: (event) {
        if (event.session.items.isEmpty) {
          return DropOperation.none;
        }
        if (event.session.items.any((item) => item.canProvide(Formats.fileUri))) {
            return DropOperation.copy;
        }
        return DropOperation.none;
      },
      onDropEnter: (event) {
        setState(() {
          _isHovering = true;
        });
      },
      onDropLeave: (event) {
        setState(() {
          _isHovering = false;
        });
      },
      onPerformDrop: (event) async {
        setState(() {
          _isHovering = false;
        });

        await _handleDrop(event.session.items);
      },
      child: Stack(
        children: [
          widget.child,
          if (_isHovering)
            Positioned.fill(
              child: Container(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(0.2),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_to_photos, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          '松开以导入音频',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleDrop(List<DropItem> items) async {
    final paths = <String>[];
    final futures = <Future<void>>[];

    for (final item in items) {
      final reader = item.dataReader;
      if (reader != null && reader.canProvide(Formats.fileUri)) {
        final completer = Completer<void>();
        reader.getValue<Uri>(Formats.fileUri, (Uri? uri) {
          if (uri != null) {
            try {
               paths.add(uri.toFilePath());
            } catch (e) {
               // ignore
            }
          }
          completer.complete();
        }, onError: (e) {
          completer.complete();
        });
        futures.add(completer.future);
      }
    }

    await Future.wait(futures);

    if (paths.isNotEmpty) {
      await widget.onFilesDropped(paths);
    }
  }
}

