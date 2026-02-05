class LyricLine {
  final Duration time;
  final String text;

  const LyricLine({required this.time, required this.text});
}

List<LyricLine> parseLrc(String raw) {
  final lines = raw.split(RegExp(r'\r?\n'));
  final parsed = <LyricLine>[];
  final timeTag = RegExp(r'[\[<](\d{1,2}):(\d{2})(?:[\.:](\d{1,3}))?(?:-\d+)?(?:\s*,\s*(\d{1,2}):(\d{2})(?:[\.:](\d{1,3}))?)?[\]>]');
  final bareTimeTag = RegExp(r'^(\d{1,2}):(\d{2})(?:[\.:](\d{1,3}))?\s+');
  final metaTag = RegExp(r'^\[(ti|ar|al|by|offset|re|ve):', caseSensitive: false);

  Duration _parseTime(String? minStr, String? secStr, String? fracStr) {
    final min = int.tryParse(minStr ?? '') ?? 0;
    final sec = int.tryParse(secStr ?? '') ?? 0;
    final fracRaw = fracStr ?? '0';
    final frac = int.tryParse(fracRaw) ?? 0;
    final millis = fracRaw.length == 3
        ? frac
        : fracRaw.length == 2
            ? frac * 10
            : fracRaw.length == 1
                ? frac * 100
                : 0;
    return Duration(minutes: min, seconds: sec, milliseconds: millis);
  }

  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;
    if (metaTag.hasMatch(trimmed)) continue;

    final matches = timeTag.allMatches(trimmed).toList();
    final bareMatch = matches.isEmpty ? bareTimeTag.firstMatch(trimmed) : null;
    final text = matches.isNotEmpty
      ? trimmed.replaceAll(timeTag, '').trim()
      : (bareMatch != null ? trimmed.replaceFirst(bareTimeTag, '').trim() : trimmed.replaceAll(timeTag, '').trim());

    if (matches.isEmpty) {
      if (bareMatch != null) {
        final time = _parseTime(bareMatch.group(1), bareMatch.group(2), bareMatch.group(3));
        if (text.isNotEmpty) {
          parsed.add(LyricLine(time: time, text: text));
        }
      } else if (text.isNotEmpty) {
        parsed.add(LyricLine(time: Duration.zero, text: text));
      }
      continue;
    }

    for (final match in matches) {
      final time = _parseTime(match.group(1), match.group(2), match.group(3));
      parsed.add(LyricLine(time: time, text: text));
    }
  }

  parsed.sort((a, b) => a.time.compareTo(b.time));
  return parsed;
}
