List<String> parseArtists(String? input) {
  if (input == null) return ['Unknown Artist'];
  String s = input.trim();
  if (s.isEmpty) return ['Unknown Artist'];

  // Normalize common unicode punctuation
  s = s.replaceAll('\u2018', "'")
       .replaceAll('\u2019', "'")
       .replaceAll('\u201C', '"')
       .replaceAll('\u201D', '"')
       .replaceAll('（', '(')
       .replaceAll('）', ')')
       .replaceAll('，', ',');

  // Move parenthetical contents out so features like "(feat. X)" are captured
  s = s.replaceAllMapped(RegExp(r'\((.*?)\)'), (m) => ' ${m[1]} ');

  // Split by feat/ft/featuring first to separate main artists and featured artists
  final featParts = s.split(RegExp(r'\s*(?:feat\.?|ft\.?|featuring)\s*', caseSensitive: false));

  final separators = RegExp(r'\s*(?:/|&|,|;|\+|\s+and\s+|\s+x\s+|×|・|、)\s*', caseSensitive: false);

  final List<String> results = [];

  for (final part in featParts) {
    final sub = part.split(separators);
    for (final item in sub) {
      final name = item.trim();
      if (name.isEmpty) continue;
      // Avoid duplicates while preserving order
      if (!results.any((e) => e.toLowerCase() == name.toLowerCase())) {
        results.add(name);
      }
    }
  }

  if (results.isEmpty) return ['Unknown Artist'];
  return results;
}

String primaryArtistFrom(String? input) {
  final parsed = parseArtists(input);
  return parsed.isNotEmpty ? parsed.first : 'Unknown Artist';
}

